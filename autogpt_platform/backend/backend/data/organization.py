"""
Organization data layer for multi-tenant operations.

Provides CRUD operations for organizations, members, and invitations.
All operations include proper authorization checks.
"""

import secrets
from datetime import datetime, timedelta, timezone
from typing import Optional

from prisma.enums import OrganizationRole, OrganizationStatus, OrganizationTier
from prisma.models import Organization, OrganizationInvitation, OrganizationMember
from pydantic import BaseModel, Field

from backend.data.db import prisma


# ============================================================================
# Request/Response Models
# ============================================================================


class OrganizationCreate(BaseModel):
    """Data for creating a new organization."""

    name: str = Field(min_length=1, max_length=100)
    slug: str = Field(min_length=1, max_length=50, pattern=r"^[a-z0-9-]+$")
    description: Optional[str] = None
    tier: OrganizationTier = OrganizationTier.FREE


class OrganizationUpdate(BaseModel):
    """Data for updating an organization."""

    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = None
    logo_url: Optional[str] = None
    settings: Optional[dict] = None


class OrganizationMemberCreate(BaseModel):
    """Data for adding a member."""

    organization_id: str
    user_id: str
    role: OrganizationRole = OrganizationRole.MEMBER
    scim_external_id: Optional[str] = None


# ============================================================================
# Organization CRUD
# ============================================================================


async def create_organization(
    data: OrganizationCreate,
    owner_id: str,
) -> Organization:
    """
    Create a new organization and add the creator as owner.

    Args:
        data: Organization creation data
        owner_id: User ID of the organization creator

    Returns:
        Created organization with owner membership

    Raises:
        ValueError: If slug is already taken
    """
    # Check slug uniqueness
    existing = await prisma.organization.find_unique(where={"slug": data.slug})
    if existing:
        raise ValueError(f"Organization slug '{data.slug}' is already taken")

    # Create organization with owner in a transaction
    async with prisma.tx() as tx:
        org = await tx.organization.create(
            data={
                "name": data.name,
                "slug": data.slug,
                "description": data.description,
                "tier": data.tier,
                "status": OrganizationStatus.ACTIVE,
            }
        )

        # Add creator as owner
        await tx.organizationmember.create(
            data={
                "organizationId": org.id,
                "userId": owner_id,
                "role": OrganizationRole.OWNER,
                "acceptedAt": datetime.now(timezone.utc),
            }
        )

        return org


async def get_organization_by_id(
    organization_id: str,
) -> Optional[Organization]:
    """Get organization by ID."""
    return await prisma.organization.find_unique(where={"id": organization_id})


async def get_organization_by_slug(
    slug: str,
) -> Optional[Organization]:
    """Get organization by URL slug."""
    return await prisma.organization.find_unique(where={"slug": slug})


async def get_organization_by_sso_domain(
    domain: str,
) -> Optional[Organization]:
    """Get organization by SSO email domain for auto-routing."""
    return await prisma.organization.find_first(
        where={
            "ssoDomain": domain,
            "ssoEnabled": True,
            "status": OrganizationStatus.ACTIVE,
        }
    )


async def update_organization(
    organization_id: str,
    data: OrganizationUpdate,
) -> Optional[Organization]:
    """Update organization details."""
    update_data = data.model_dump(exclude_none=True)
    if not update_data:
        return await get_organization_by_id(organization_id)

    # Convert snake_case to camelCase for Prisma
    prisma_data = {}
    if "name" in update_data:
        prisma_data["name"] = update_data["name"]
    if "description" in update_data:
        prisma_data["description"] = update_data["description"]
    if "logo_url" in update_data:
        prisma_data["logoUrl"] = update_data["logo_url"]
    if "settings" in update_data:
        prisma_data["settings"] = update_data["settings"]

    if not prisma_data:
        return await get_organization_by_id(organization_id)

    return await prisma.organization.update(
        where={"id": organization_id},
        data=prisma_data,
    )


# ============================================================================
# Member Operations
# ============================================================================


async def get_user_organizations(
    user_id: str,
) -> list[OrganizationMember]:
    """Get all organizations a user belongs to."""
    return await prisma.organizationmember.find_many(
        where={"userId": user_id},
        include={"Organization": True},
    )


async def get_organization_members(
    organization_id: str,
) -> list[OrganizationMember]:
    """Get all members of an organization."""
    return await prisma.organizationmember.find_many(
        where={"organizationId": organization_id},
        include={"User": True},
        order={"createdAt": "asc"},
    )


async def get_member(
    organization_id: str,
    user_id: str,
) -> Optional[OrganizationMember]:
    """Get a specific member record."""
    return await prisma.organizationmember.find_unique(
        where={
            "organizationId_userId": {
                "organizationId": organization_id,
                "userId": user_id,
            }
        }
    )


async def add_organization_member(
    data: OrganizationMemberCreate,
) -> OrganizationMember:
    """Add a user as a member of an organization."""
    return await prisma.organizationmember.create(
        data={
            "organizationId": data.organization_id,
            "userId": data.user_id,
            "role": data.role,
            "scimExternalId": data.scim_external_id,
            "acceptedAt": datetime.now(timezone.utc),
        }
    )


async def remove_organization_member(
    organization_id: str,
    user_id: str,
) -> bool:
    """
    Remove a member from an organization.

    Returns:
        True if member was removed, False if not found
    """
    try:
        await prisma.organizationmember.delete(
            where={
                "organizationId_userId": {
                    "organizationId": organization_id,
                    "userId": user_id,
                }
            }
        )
        return True
    except Exception:
        return False


async def update_member_role(
    organization_id: str,
    user_id: str,
    new_role: OrganizationRole,
) -> Optional[OrganizationMember]:
    """Update a member's role in the organization."""
    return await prisma.organizationmember.update(
        where={
            "organizationId_userId": {
                "organizationId": organization_id,
                "userId": user_id,
            }
        },
        data={"role": new_role},
    )


async def check_user_permission(
    organization_id: str,
    user_id: str,
    required_roles: list[OrganizationRole],
) -> bool:
    """
    Check if user has one of the required roles in the organization.

    Args:
        organization_id: Organization to check
        user_id: User to check
        required_roles: List of acceptable roles

    Returns:
        True if user has permission, False otherwise
    """
    member = await get_member(organization_id, user_id)
    if not member:
        return False
    return member.role in required_roles


# ============================================================================
# Invitation Operations
# ============================================================================

INVITATION_EXPIRY_DAYS = 7


async def create_invitation(
    organization_id: str,
    email: str,
    role: OrganizationRole,
    invited_by: str,
) -> OrganizationInvitation:
    """
    Create an invitation to join an organization.

    Args:
        organization_id: Organization to invite to
        email: Email address to invite
        role: Role to assign when accepted
        invited_by: User ID of the inviter

    Returns:
        Created invitation with unique token
    """
    # Generate secure token
    token = secrets.token_urlsafe(32)
    expires_at = datetime.now(timezone.utc) + timedelta(days=INVITATION_EXPIRY_DAYS)

    # Upsert to handle re-invitations
    return await prisma.organizationinvitation.upsert(
        where={
            "organizationId_email": {
                "organizationId": organization_id,
                "email": email,
            }
        },
        data={
            "create": {
                "organizationId": organization_id,
                "email": email,
                "role": role,
                "token": token,
                "invitedBy": invited_by,
                "expiresAt": expires_at,
            },
            "update": {
                "role": role,
                "token": token,
                "invitedBy": invited_by,
                "expiresAt": expires_at,
                "acceptedAt": None,
                "declinedAt": None,
            },
        },
    )


async def get_invitation_by_token(
    token: str,
) -> Optional[OrganizationInvitation]:
    """Get invitation by token."""
    return await prisma.organizationinvitation.find_unique(
        where={"token": token},
        include={"Organization": True},
    )


async def accept_invitation(
    token: str,
    user_id: str,
) -> Optional[OrganizationMember]:
    """
    Accept an invitation and add user to organization.

    Args:
        token: Invitation token
        user_id: User accepting the invitation

    Returns:
        Created member record, or None if invitation invalid/expired
    """
    invitation = await get_invitation_by_token(token)

    if not invitation:
        return None

    # Check expiry
    if invitation.expiresAt < datetime.now(timezone.utc):
        return None

    # Check if already accepted
    if invitation.acceptedAt:
        return None

    # Create member and mark invitation as accepted in transaction
    async with prisma.tx() as tx:
        member = await tx.organizationmember.create(
            data={
                "organizationId": invitation.organizationId,
                "userId": user_id,
                "role": invitation.role,
                "invitedBy": invitation.invitedBy,
                "invitedAt": invitation.createdAt,
                "acceptedAt": datetime.now(timezone.utc),
            }
        )

        await tx.organizationinvitation.update(
            where={"id": invitation.id},
            data={"acceptedAt": datetime.now(timezone.utc)},
        )

        return member


async def get_pending_invitations(
    organization_id: str,
) -> list[OrganizationInvitation]:
    """Get all pending invitations for an organization."""
    return await prisma.organizationinvitation.find_many(
        where={
            "organizationId": organization_id,
            "acceptedAt": None,
            "declinedAt": None,
            "expiresAt": {"gt": datetime.now(timezone.utc)},
        },
        order={"createdAt": "desc"},
    )
