"""Organization API routes for multi-tenant operations."""

import logging
from typing import Annotated

from autogpt_libs.auth import get_user_id, requires_user
from fastapi import APIRouter, HTTPException, Security, status
from prisma.enums import OrganizationRole

from backend.data.organization import (
    OrganizationCreate,
    OrganizationUpdate,
    accept_invitation,
    check_user_permission,
    create_invitation,
    create_organization,
    get_invitation_by_token,
    get_member,
    get_organization_by_id,
    get_organization_by_slug,
    get_organization_members,
    get_pending_invitations,
    get_user_organizations,
    remove_organization_member,
    update_member_role,
    update_organization,
)

from .model import (
    AcceptInvitationResponse,
    InviteMemberRequest,
    OrganizationCreateRequest,
    OrganizationInvitationResponse,
    OrganizationMemberResponse,
    OrganizationResponse,
    OrganizationUpdateRequest,
    UpdateMemberRoleRequest,
    UserOrganizationResponse,
)

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/organizations",
    tags=["organizations"],
    dependencies=[Security(requires_user)],
)

# Role constants for authorization
OWNER_ONLY = [OrganizationRole.OWNER]
ADMIN_OR_OWNER = [OrganizationRole.OWNER, OrganizationRole.ADMIN]
ANY_MEMBER = [
    OrganizationRole.OWNER,
    OrganizationRole.ADMIN,
    OrganizationRole.MEMBER,
    OrganizationRole.VIEWER,
]


def _org_to_response(org) -> OrganizationResponse:
    """Convert Prisma Organization to response model."""
    return OrganizationResponse(
        id=org.id,
        name=org.name,
        slug=org.slug,
        description=org.description,
        logo_url=org.logoUrl,
        status=org.status,
        tier=org.tier,
        sso_enabled=org.ssoEnabled,
        created_at=org.createdAt,
        updated_at=org.updatedAt,
    )


def _member_to_response(member) -> OrganizationMemberResponse:
    """Convert Prisma OrganizationMember to response model."""
    user = getattr(member, "User", None)
    return OrganizationMemberResponse(
        id=member.id,
        user_id=member.userId,
        organization_id=member.organizationId,
        role=member.role,
        user_email=user.email if user else None,
        user_name=user.name if user else None,
        created_at=member.createdAt,
        accepted_at=member.acceptedAt,
    )


def _invitation_to_response(inv) -> OrganizationInvitationResponse:
    """Convert Prisma OrganizationInvitation to response model."""
    return OrganizationInvitationResponse(
        id=inv.id,
        email=inv.email,
        role=inv.role,
        invited_by=inv.invitedBy,
        created_at=inv.createdAt,
        expires_at=inv.expiresAt,
    )


async def require_org_permission(
    organization_id: str,
    user_id: str,
    required_roles: list[OrganizationRole],
) -> None:
    """Verify user has required permission, raise 403 if not."""
    has_permission = await check_user_permission(
        organization_id, user_id, required_roles
    )
    if not has_permission:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to perform this action",
        )


# ============================================================================
# Organization CRUD
# ============================================================================


@router.post(
    "",
    response_model=OrganizationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create Organization",
)
async def create_org(
    request: OrganizationCreateRequest,
    user_id: Annotated[str, Security(get_user_id)],
):
    """Create a new organization. The creator becomes the owner."""
    try:
        org_data = OrganizationCreate(
            name=request.name,
            slug=request.slug,
            description=request.description,
            tier=request.tier,
        )
        org = await create_organization(org_data, user_id)
        logger.info(f"User {user_id} created organization {org.id} ({org.slug})")
        return _org_to_response(org)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get(
    "",
    response_model=list[UserOrganizationResponse],
    summary="List My Organizations",
)
async def list_my_organizations(
    user_id: Annotated[str, Security(get_user_id)],
):
    """Get all organizations the current user belongs to."""
    memberships = await get_user_organizations(user_id)
    return [
        UserOrganizationResponse(
            organization=_org_to_response(m.Organization),
            role=m.role,
            is_default=False,  # TODO: check against user.defaultOrganizationId
        )
        for m in memberships
        if m.Organization
    ]


@router.get(
    "/{organization_id}",
    response_model=OrganizationResponse,
    summary="Get Organization",
)
async def get_org(
    organization_id: str,
    user_id: Annotated[str, Security(get_user_id)],
):
    """Get organization details. User must be a member."""
    await require_org_permission(organization_id, user_id, ANY_MEMBER)

    org = await get_organization_by_id(organization_id)
    if not org:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Organization not found"
        )
    return _org_to_response(org)


@router.get(
    "/slug/{slug}",
    response_model=OrganizationResponse,
    summary="Get Organization by Slug",
)
async def get_org_by_slug(
    slug: str,
    user_id: Annotated[str, Security(get_user_id)],
):
    """Get organization by URL slug. User must be a member."""
    org = await get_organization_by_slug(slug)
    if not org:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Organization not found"
        )

    await require_org_permission(org.id, user_id, ANY_MEMBER)
    return _org_to_response(org)


@router.patch(
    "/{organization_id}",
    response_model=OrganizationResponse,
    summary="Update Organization",
)
async def update_org(
    organization_id: str,
    request: OrganizationUpdateRequest,
    user_id: Annotated[str, Security(get_user_id)],
):
    """Update organization details. Requires admin or owner role."""
    await require_org_permission(organization_id, user_id, ADMIN_OR_OWNER)

    update_data = OrganizationUpdate(
        name=request.name,
        description=request.description,
        logo_url=request.logo_url,
    )
    org = await update_organization(organization_id, update_data)
    if not org:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Organization not found"
        )
    logger.info(f"User {user_id} updated organization {organization_id}")
    return _org_to_response(org)


# ============================================================================
# Member Management
# ============================================================================


@router.get(
    "/{organization_id}/members",
    response_model=list[OrganizationMemberResponse],
    summary="List Members",
)
async def list_members(
    organization_id: str,
    user_id: Annotated[str, Security(get_user_id)],
):
    """List all members of the organization. Any member can view."""
    await require_org_permission(organization_id, user_id, ANY_MEMBER)

    members = await get_organization_members(organization_id)
    return [_member_to_response(m) for m in members]


@router.patch(
    "/{organization_id}/members/{member_user_id}",
    response_model=OrganizationMemberResponse,
    summary="Update Member Role",
)
async def update_member(
    organization_id: str,
    member_user_id: str,
    request: UpdateMemberRoleRequest,
    user_id: Annotated[str, Security(get_user_id)],
):
    """Update a member's role. Requires admin or owner role."""
    await require_org_permission(organization_id, user_id, ADMIN_OR_OWNER)

    # Prevent changing owner role unless you're the owner
    current_member = await get_member(organization_id, member_user_id)
    if current_member and current_member.role == OrganizationRole.OWNER:
        caller = await get_member(organization_id, user_id)
        if not caller or caller.role != OrganizationRole.OWNER:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only owners can modify other owner roles",
            )

    member = await update_member_role(organization_id, member_user_id, request.role)
    if not member:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Member not found"
        )
    logger.info(
        f"User {user_id} updated member {member_user_id} role to {request.role}"
    )
    return _member_to_response(member)


@router.delete(
    "/{organization_id}/members/{member_user_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Remove Member",
)
async def remove_member(
    organization_id: str,
    member_user_id: str,
    user_id: Annotated[str, Security(get_user_id)],
):
    """Remove a member from the organization. Requires admin or owner role."""
    # Users can remove themselves
    if member_user_id != user_id:
        await require_org_permission(organization_id, user_id, ADMIN_OR_OWNER)

    # Prevent removing the last owner
    member = await get_member(organization_id, member_user_id)
    if member and member.role == OrganizationRole.OWNER:
        all_members = await get_organization_members(organization_id)
        owner_count = sum(1 for m in all_members if m.role == OrganizationRole.OWNER)
        if owner_count <= 1:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot remove the last owner. Transfer ownership first.",
            )

    success = await remove_organization_member(organization_id, member_user_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Member not found"
        )
    logger.info(
        f"User {user_id} removed member {member_user_id} from {organization_id}"
    )


# ============================================================================
# Invitations
# ============================================================================


@router.post(
    "/{organization_id}/invitations",
    response_model=OrganizationInvitationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Invite Member",
)
async def invite_member(
    organization_id: str,
    request: InviteMemberRequest,
    user_id: Annotated[str, Security(get_user_id)],
):
    """Invite a user to join the organization by email. Requires admin or owner role."""
    await require_org_permission(organization_id, user_id, ADMIN_OR_OWNER)

    invitation = await create_invitation(
        organization_id=organization_id,
        email=request.email,
        role=request.role,
        invited_by=user_id,
    )
    logger.info(
        f"User {user_id} invited {request.email} to organization {organization_id}"
    )
    return _invitation_to_response(invitation)


@router.get(
    "/{organization_id}/invitations",
    response_model=list[OrganizationInvitationResponse],
    summary="List Pending Invitations",
)
async def list_invitations(
    organization_id: str,
    user_id: Annotated[str, Security(get_user_id)],
):
    """List pending invitations. Requires admin or owner role."""
    await require_org_permission(organization_id, user_id, ADMIN_OR_OWNER)

    invitations = await get_pending_invitations(organization_id)
    return [_invitation_to_response(inv) for inv in invitations]


@router.post(
    "/invitations/{token}/accept",
    response_model=AcceptInvitationResponse,
    summary="Accept Invitation",
)
async def accept_invite(
    token: str,
    user_id: Annotated[str, Security(get_user_id)],
):
    """Accept an invitation using the token."""
    # Get invitation first to get org details
    invitation = await get_invitation_by_token(token)
    if not invitation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Invitation not found or expired",
        )

    member = await accept_invitation(token, user_id)
    if not member:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invitation expired or already accepted",
        )

    org = await get_organization_by_id(invitation.organizationId)
    logger.info(
        f"User {user_id} accepted invitation to organization {invitation.organizationId}"
    )
    return AcceptInvitationResponse(
        organization=_org_to_response(org),
        role=member.role,
    )
