"""Pydantic models for Organization API."""

from datetime import datetime
from typing import Optional

from prisma.enums import OrganizationRole, OrganizationStatus, OrganizationTier
from pydantic import BaseModel, Field


# ============================================================================
# Request Models
# ============================================================================


class OrganizationCreateRequest(BaseModel):
    """Request to create a new organization."""

    name: str = Field(min_length=1, max_length=100)
    slug: str = Field(
        min_length=1,
        max_length=50,
        pattern=r"^[a-z0-9-]+$",
        description="URL-friendly identifier (lowercase letters, numbers, hyphens)",
    )
    description: Optional[str] = None
    tier: OrganizationTier = OrganizationTier.FREE


class OrganizationUpdateRequest(BaseModel):
    """Request to update organization details."""

    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = None
    logo_url: Optional[str] = None


class InviteMemberRequest(BaseModel):
    """Request to invite a new member."""

    email: str
    role: OrganizationRole = OrganizationRole.MEMBER


class UpdateMemberRoleRequest(BaseModel):
    """Request to update a member's role."""

    role: OrganizationRole


# ============================================================================
# Response Models
# ============================================================================


class OrganizationResponse(BaseModel):
    """Organization details response."""

    id: str
    name: str
    slug: str
    description: Optional[str] = None
    logo_url: Optional[str] = None
    status: OrganizationStatus
    tier: OrganizationTier
    sso_enabled: bool = False
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class OrganizationMemberResponse(BaseModel):
    """Organization member details."""

    id: str
    user_id: str
    organization_id: str
    role: OrganizationRole
    user_email: Optional[str] = None
    user_name: Optional[str] = None
    created_at: datetime
    accepted_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class OrganizationInvitationResponse(BaseModel):
    """Pending invitation details."""

    id: str
    email: str
    role: OrganizationRole
    invited_by: str
    created_at: datetime
    expires_at: datetime

    class Config:
        from_attributes = True


class UserOrganizationResponse(BaseModel):
    """User's organization membership info."""

    organization: OrganizationResponse
    role: OrganizationRole
    is_default: bool = False


class AcceptInvitationResponse(BaseModel):
    """Response after accepting an invitation."""

    organization: OrganizationResponse
    role: OrganizationRole
    message: str = "Successfully joined organization"
