"""
Audit logging for compliance and security tracking.

All significant actions are logged with:
- Who performed the action (actor)
- What action was performed
- What resource was affected
- When it happened
- Additional context/details
"""

from datetime import datetime
from typing import Optional

from prisma.enums import AuditAction
from prisma.models import AuditLog
from pydantic import BaseModel

from backend.data.db import prisma
from backend.util.json import SafeJson


class AuditContext(BaseModel):
    """Context for audit logging from request."""

    actor_id: Optional[str] = None
    actor_email: Optional[str] = None
    actor_ip: Optional[str] = None
    organization_id: Optional[str] = None
    user_agent: Optional[str] = None
    request_id: Optional[str] = None


async def log_audit_event(
    action: AuditAction,
    resource: str,
    context: AuditContext,
    resource_id: Optional[str] = None,
    details: Optional[dict] = None,
) -> AuditLog:
    """
    Log an audit event.

    Args:
        action: The type of action performed
        resource: The type of resource affected (e.g., "organization", "agent")
        context: Request context including actor and org info
        resource_id: ID of the specific resource affected
        details: Additional details about the action

    Returns:
        Created audit log entry
    """
    # Build data dict, only including non-None optional fields
    # Prisma Python client doesn't accept None for Json fields
    data: dict = {
        "action": action,
        "resource": resource,
    }

    if resource_id:
        data["resourceId"] = resource_id
    if context.actor_id:
        data["actorId"] = context.actor_id
    if context.actor_email:
        data["actorEmail"] = context.actor_email
    if context.actor_ip:
        data["actorIp"] = context.actor_ip
    if context.organization_id:
        data["organizationId"] = context.organization_id
    if context.user_agent:
        data["userAgent"] = context.user_agent
    if context.request_id:
        data["requestId"] = context.request_id
    if details:
        data["details"] = SafeJson(details)

    return await prisma.auditlog.create(data=data)


async def get_audit_logs(
    organization_id: Optional[str] = None,
    actor_id: Optional[str] = None,
    action: Optional[AuditAction] = None,
    resource: Optional[str] = None,
    resource_id: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    limit: int = 100,
    offset: int = 0,
) -> list[AuditLog]:
    """
    Query audit logs with filters.

    Args:
        organization_id: Filter by organization
        actor_id: Filter by who performed the action
        action: Filter by action type
        resource: Filter by resource type
        resource_id: Filter by specific resource
        start_date: Filter events after this date
        end_date: Filter events before this date
        limit: Maximum number of results
        offset: Pagination offset

    Returns:
        List of matching audit log entries
    """
    where: dict = {}

    if organization_id:
        where["organizationId"] = organization_id
    if actor_id:
        where["actorId"] = actor_id
    if action:
        where["action"] = action
    if resource:
        where["resource"] = resource
    if resource_id:
        where["resourceId"] = resource_id

    # Date range filter
    if start_date or end_date:
        where["createdAt"] = {}
        if start_date:
            where["createdAt"]["gte"] = start_date
        if end_date:
            where["createdAt"]["lte"] = end_date

    return await prisma.auditlog.find_many(
        where=where,
        order={"createdAt": "desc"},
        take=limit,
        skip=offset,
    )


async def get_user_activity(
    user_id: str,
    limit: int = 50,
) -> list[AuditLog]:
    """Get recent activity for a specific user."""
    return await prisma.auditlog.find_many(
        where={"actorId": user_id},
        order={"createdAt": "desc"},
        take=limit,
    )


async def get_resource_history(
    resource: str,
    resource_id: str,
) -> list[AuditLog]:
    """Get all audit logs for a specific resource."""
    return await prisma.auditlog.find_many(
        where={
            "resource": resource,
            "resourceId": resource_id,
        },
        order={"createdAt": "desc"},
    )
