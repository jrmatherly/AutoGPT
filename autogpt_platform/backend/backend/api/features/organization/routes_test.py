"""Tests for Organization API routes."""

from datetime import datetime, timezone
from unittest.mock import AsyncMock

import fastapi
import fastapi.testclient
import pytest
import pytest_mock
from prisma.enums import OrganizationRole, OrganizationStatus, OrganizationTier

from .routes import router as organization_router

app = fastapi.FastAPI()
app.include_router(organization_router)

client = fastapi.testclient.TestClient(app)

# Test data constants
TEST_ORG_ID = "test-org-id-123"
TEST_ORG_SLUG = "test-api-org"
TEST_ORG_NAME = "Test API Organization"


class MockOrganization:
    """Mock organization for testing."""

    def __init__(self, **kwargs):
        self.id = kwargs.get("id", TEST_ORG_ID)
        self.name = kwargs.get("name", TEST_ORG_NAME)
        self.slug = kwargs.get("slug", TEST_ORG_SLUG)
        self.description = kwargs.get("description", None)
        self.logoUrl = kwargs.get("logoUrl", None)
        self.status = kwargs.get("status", OrganizationStatus.ACTIVE)
        self.tier = kwargs.get("tier", OrganizationTier.FREE)
        self.ssoEnabled = kwargs.get("ssoEnabled", False)
        self.createdAt = kwargs.get("createdAt", datetime.now(timezone.utc))
        self.updatedAt = kwargs.get("updatedAt", datetime.now(timezone.utc))


class MockMember:
    """Mock member for testing."""

    def __init__(self, **kwargs):
        self.id = kwargs.get("id", "member-id-123")
        self.userId = kwargs.get("userId", "test-user-id")
        self.organizationId = kwargs.get("organizationId", TEST_ORG_ID)
        self.role = kwargs.get("role", OrganizationRole.OWNER)
        self.createdAt = kwargs.get("createdAt", datetime.now(timezone.utc))
        self.acceptedAt = kwargs.get("acceptedAt", datetime.now(timezone.utc))
        self.User = kwargs.get("User", None)
        self.Organization = kwargs.get("Organization", None)


class MockInvitation:
    """Mock invitation for testing."""

    def __init__(self, **kwargs):
        self.id = kwargs.get("id", "invitation-id-123")
        self.email = kwargs.get("email", "invite@example.com")
        self.role = kwargs.get("role", OrganizationRole.MEMBER)
        self.invitedBy = kwargs.get("invitedBy", "test-user-id")
        self.createdAt = kwargs.get("createdAt", datetime.now(timezone.utc))
        self.expiresAt = kwargs.get("expiresAt", datetime.now(timezone.utc))


@pytest.fixture(autouse=True)
def setup_app_auth(mock_jwt_user):
    """Setup auth overrides for all tests in this module."""
    from autogpt_libs.auth.jwt_utils import get_jwt_payload

    app.dependency_overrides[get_jwt_payload] = mock_jwt_user["get_jwt_payload"]
    yield
    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_create_organization(
    mocker: pytest_mock.MockFixture,
    test_user_id: str,
):
    """Test creating a new organization via API."""
    mock_org = MockOrganization()
    mocker.patch(
        "backend.api.features.organization.routes.create_organization",
        new=AsyncMock(return_value=mock_org),
    )

    response = client.post(
        "/organizations",
        json={
            "name": TEST_ORG_NAME,
            "slug": TEST_ORG_SLUG,
            "description": "Test organization for API tests",
        },
    )

    assert response.status_code == 201
    data = response.json()
    assert data["name"] == TEST_ORG_NAME
    assert data["slug"] == TEST_ORG_SLUG
    assert data["status"] == "ACTIVE"
    assert data["tier"] == "FREE"


@pytest.mark.asyncio
async def test_list_my_organizations(
    mocker: pytest_mock.MockFixture,
    test_user_id: str,
):
    """Test listing user's organizations."""
    mock_member = MockMember(
        userId=test_user_id,
        Organization=MockOrganization(),
    )
    mocker.patch(
        "backend.api.features.organization.routes.get_user_organizations",
        new=AsyncMock(return_value=[mock_member]),
    )

    response = client.get("/organizations")

    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) == 1
    assert data[0]["organization"]["slug"] == TEST_ORG_SLUG


@pytest.mark.asyncio
async def test_get_organization_by_slug(
    mocker: pytest_mock.MockFixture,
    test_user_id: str,
):
    """Test getting organization by slug."""
    mock_org = MockOrganization()
    mocker.patch(
        "backend.api.features.organization.routes.get_organization_by_slug",
        new=AsyncMock(return_value=mock_org),
    )
    mocker.patch(
        "backend.api.features.organization.routes.check_user_permission",
        new=AsyncMock(return_value=True),
    )

    response = client.get(f"/organizations/slug/{TEST_ORG_SLUG}")

    assert response.status_code == 200
    data = response.json()
    assert data["slug"] == TEST_ORG_SLUG


@pytest.mark.asyncio
async def test_update_organization(
    mocker: pytest_mock.MockFixture,
    test_user_id: str,
):
    """Test updating organization details."""
    mock_org = MockOrganization(name="Updated Test Org Name")
    mocker.patch(
        "backend.api.features.organization.routes.check_user_permission",
        new=AsyncMock(return_value=True),
    )
    mocker.patch(
        "backend.api.features.organization.routes.update_organization",
        new=AsyncMock(return_value=mock_org),
    )

    response = client.patch(
        f"/organizations/{TEST_ORG_ID}",
        json={"name": "Updated Test Org Name"},
    )

    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Updated Test Org Name"


@pytest.mark.asyncio
async def test_list_members(
    mocker: pytest_mock.MockFixture,
    test_user_id: str,
):
    """Test listing organization members."""
    mock_member = MockMember(userId=test_user_id, role=OrganizationRole.OWNER)
    mocker.patch(
        "backend.api.features.organization.routes.check_user_permission",
        new=AsyncMock(return_value=True),
    )
    mocker.patch(
        "backend.api.features.organization.routes.get_organization_members",
        new=AsyncMock(return_value=[mock_member]),
    )

    response = client.get(f"/organizations/{TEST_ORG_ID}/members")

    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["role"] == "OWNER"
    assert data[0]["user_id"] == test_user_id


@pytest.mark.asyncio
async def test_invite_member(
    mocker: pytest_mock.MockFixture,
    test_user_id: str,
):
    """Test inviting a new member."""
    mock_invitation = MockInvitation(email="newmember@example.com")
    mocker.patch(
        "backend.api.features.organization.routes.check_user_permission",
        new=AsyncMock(return_value=True),
    )
    mocker.patch(
        "backend.api.features.organization.routes.create_invitation",
        new=AsyncMock(return_value=mock_invitation),
    )

    response = client.post(
        f"/organizations/{TEST_ORG_ID}/invitations",
        json={"email": "newmember@example.com", "role": "MEMBER"},
    )

    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "newmember@example.com"
    assert data["role"] == "MEMBER"


@pytest.mark.asyncio
async def test_list_invitations(
    mocker: pytest_mock.MockFixture,
    test_user_id: str,
):
    """Test listing pending invitations."""
    mock_invitation = MockInvitation(email="newmember@example.com")
    mocker.patch(
        "backend.api.features.organization.routes.check_user_permission",
        new=AsyncMock(return_value=True),
    )
    mocker.patch(
        "backend.api.features.organization.routes.get_pending_invitations",
        new=AsyncMock(return_value=[mock_invitation]),
    )

    response = client.get(f"/organizations/{TEST_ORG_ID}/invitations")

    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["email"] == "newmember@example.com"


@pytest.mark.asyncio
async def test_duplicate_slug_error(
    mocker: pytest_mock.MockFixture,
    test_user_id: str,
):
    """Test that creating org with duplicate slug fails."""
    mocker.patch(
        "backend.api.features.organization.routes.create_organization",
        new=AsyncMock(side_effect=ValueError("Organization slug 'test-slug' is already taken")),
    )

    response = client.post(
        "/organizations",
        json={"name": "Duplicate Slug Org", "slug": "test-slug"},
    )

    assert response.status_code == 400
    assert "already taken" in response.json()["detail"]


@pytest.mark.asyncio
async def test_permission_denied(
    mocker: pytest_mock.MockFixture,
    test_user_id: str,
):
    """Test that unauthorized access returns 403."""
    mocker.patch(
        "backend.api.features.organization.routes.check_user_permission",
        new=AsyncMock(return_value=False),
    )

    response = client.get(f"/organizations/{TEST_ORG_ID}/members")

    assert response.status_code == 403
    assert "permission" in response.json()["detail"].lower()
