"""Tests for organization data layer."""

import pytest
from prisma.enums import OrganizationRole, OrganizationStatus, OrganizationTier
from prisma.models import Organization, OrganizationInvitation, OrganizationMember, User

from backend.data.organization import (
    OrganizationCreate,
    OrganizationMemberCreate,
    accept_invitation,
    add_organization_member,
    check_user_permission,
    create_invitation,
    create_organization,
    get_organization_by_slug,
    get_user_organizations,
    remove_organization_member,
    update_member_role,
)
from backend.data.user import DEFAULT_USER_ID
from backend.util.test import SpinTestServer

# Test data constants
TEST_ORG_SLUG = "test-org-multi-tenant"
TEST_ORG_NAME = "Test Corp Multi-Tenant"
TEST_NEW_MEMBER_ID = "test-org-new-member"
TEST_INVITED_USER_ID = "test-org-invited-user"


async def ensure_test_users():
    """Create test users if they don't exist."""
    for user_id in [TEST_NEW_MEMBER_ID, TEST_INVITED_USER_ID]:
        existing = await User.prisma().find_unique(where={"id": user_id})
        if not existing:
            await User.prisma().create(
                data={
                    "id": user_id,
                    "email": f"{user_id}@test.example.com",
                    "name": f"Test User {user_id}",
                }
            )


async def cleanup_test_users():
    """Clean up test users."""
    for user_id in [TEST_NEW_MEMBER_ID, TEST_INVITED_USER_ID]:
        try:
            await User.prisma().delete(where={"id": user_id})
        except Exception:
            pass  # User may not exist


async def cleanup_test_organizations():
    """Clean up test data before/after tests."""
    # Delete invitations first (FK constraint)
    await OrganizationInvitation.prisma().delete_many(
        where={"Organization": {"is": {"slug": {"startswith": "test-"}}}}
    )
    # Delete members
    await OrganizationMember.prisma().delete_many(
        where={"Organization": {"is": {"slug": {"startswith": "test-"}}}}
    )
    # Delete organizations
    await Organization.prisma().delete_many(where={"slug": {"startswith": "test-"}})


@pytest.mark.asyncio(loop_scope="session")
async def test_create_organization(server: SpinTestServer):
    """Test creating a new organization."""
    await cleanup_test_organizations()
    await ensure_test_users()

    org_data = OrganizationCreate(
        name=TEST_ORG_NAME,
        slug=TEST_ORG_SLUG,
        tier=OrganizationTier.STANDARD,
    )

    org = await create_organization(org_data, DEFAULT_USER_ID)

    assert org is not None
    assert org.name == TEST_ORG_NAME
    assert org.slug == TEST_ORG_SLUG
    assert org.tier == OrganizationTier.STANDARD
    assert org.status == OrganizationStatus.ACTIVE


@pytest.mark.asyncio(loop_scope="session")
async def test_get_organization_by_slug(server: SpinTestServer):
    """Test retrieving organization by slug."""
    org = await get_organization_by_slug(TEST_ORG_SLUG)

    assert org is not None
    assert org.slug == TEST_ORG_SLUG


@pytest.mark.asyncio(loop_scope="session")
async def test_owner_membership_created(server: SpinTestServer):
    """Test that organization creator is added as owner."""
    org = await get_organization_by_slug(TEST_ORG_SLUG)
    assert org is not None

    members = await OrganizationMember.prisma().find_many(
        where={"organizationId": org.id}
    )

    assert len(members) == 1
    assert members[0].userId == DEFAULT_USER_ID
    assert members[0].role == OrganizationRole.OWNER


@pytest.mark.asyncio(loop_scope="session")
async def test_add_organization_member(server: SpinTestServer):
    """Test adding a member to organization."""
    org = await get_organization_by_slug(TEST_ORG_SLUG)
    assert org is not None

    member_data = OrganizationMemberCreate(
        organization_id=org.id,
        user_id=TEST_NEW_MEMBER_ID,
        role=OrganizationRole.MEMBER,
    )

    member = await add_organization_member(member_data)

    assert member is not None
    assert member.role == OrganizationRole.MEMBER
    assert member.organizationId == org.id


@pytest.mark.asyncio(loop_scope="session")
async def test_update_member_role(server: SpinTestServer):
    """Test updating a member's role."""
    org = await get_organization_by_slug(TEST_ORG_SLUG)
    assert org is not None

    updated = await update_member_role(
        organization_id=org.id,
        user_id=TEST_NEW_MEMBER_ID,
        new_role=OrganizationRole.ADMIN,
    )

    assert updated is not None
    assert updated.role == OrganizationRole.ADMIN


@pytest.mark.asyncio(loop_scope="session")
async def test_check_user_permission(server: SpinTestServer):
    """Test permission checking."""
    org = await get_organization_by_slug(TEST_ORG_SLUG)
    assert org is not None

    # Owner should have OWNER role
    has_owner = await check_user_permission(
        org.id, DEFAULT_USER_ID, [OrganizationRole.OWNER]
    )
    assert has_owner is True

    # Admin should have ADMIN role
    has_admin = await check_user_permission(
        org.id, TEST_NEW_MEMBER_ID, [OrganizationRole.ADMIN]
    )
    assert has_admin is True

    # Member should NOT have OWNER role
    has_owner_wrong = await check_user_permission(
        org.id, TEST_NEW_MEMBER_ID, [OrganizationRole.OWNER]
    )
    assert has_owner_wrong is False


@pytest.mark.asyncio(loop_scope="session")
async def test_get_user_organizations(server: SpinTestServer):
    """Test getting user's organizations."""
    orgs = await get_user_organizations(DEFAULT_USER_ID)

    assert len(orgs) >= 1
    org_slugs = [m.Organization.slug for m in orgs if m.Organization]
    assert TEST_ORG_SLUG in org_slugs


@pytest.mark.asyncio(loop_scope="session")
async def test_create_and_accept_invitation(server: SpinTestServer):
    """Test invitation flow."""
    org = await get_organization_by_slug(TEST_ORG_SLUG)
    assert org is not None

    invitation = await create_invitation(
        organization_id=org.id,
        email="invitee@example.com",
        role=OrganizationRole.MEMBER,
        invited_by=DEFAULT_USER_ID,
    )

    assert invitation is not None
    assert invitation.token is not None
    assert invitation.email == "invitee@example.com"

    # Accept the invitation
    member = await accept_invitation(
        token=invitation.token,
        user_id=TEST_INVITED_USER_ID,
    )

    assert member is not None
    assert member.organizationId == org.id
    assert member.role == OrganizationRole.MEMBER


@pytest.mark.asyncio(loop_scope="session")
async def test_remove_organization_member(server: SpinTestServer):
    """Test removing a member."""
    org = await get_organization_by_slug(TEST_ORG_SLUG)
    assert org is not None

    # Remove the invited user
    success = await remove_organization_member(org.id, TEST_INVITED_USER_ID)
    assert success is True

    # Verify member is gone
    has_perm = await check_user_permission(
        org.id, TEST_INVITED_USER_ID, [OrganizationRole.MEMBER]
    )
    assert has_perm is False


@pytest.mark.asyncio(loop_scope="session")
async def test_cleanup(server: SpinTestServer):
    """Clean up test data after all tests."""
    await cleanup_test_organizations()
    await cleanup_test_users()

    # Verify cleanup
    org = await get_organization_by_slug(TEST_ORG_SLUG)
    assert org is None
