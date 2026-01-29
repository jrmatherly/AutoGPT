"""Tests for audit logging."""

import pytest
from prisma.enums import AuditAction

from backend.data.audit import (
    AuditContext,
    get_audit_logs,
    get_resource_history,
    get_user_activity,
    log_audit_event,
)
from backend.util.test import SpinTestServer


@pytest.mark.asyncio(loop_scope="session")
async def test_log_audit_event(server: SpinTestServer):
    """Test creating an audit log entry."""
    context = AuditContext(
        actor_id="test-audit-actor-a1",
        actor_email="actor@example.com",
        actor_ip="192.168.1.1",
        organization_id=None,
        user_agent="Test/1.0",
        request_id="req-123",
    )

    log = await log_audit_event(
        action=AuditAction.ORG_CREATED,
        resource="organization",
        resource_id="test-resource-a1",
        context=context,
        details={"name": "Test Org"},
    )

    assert log is not None
    assert log.action == AuditAction.ORG_CREATED
    assert log.actorId == "test-audit-actor-a1"
    assert log.actorEmail == "actor@example.com"
    assert log.actorIp == "192.168.1.1"
    assert log.resource == "organization"
    assert log.resourceId == "test-resource-a1"
    assert log.details == {"name": "Test Org"}
    assert log.userAgent == "Test/1.0"
    assert log.requestId == "req-123"


@pytest.mark.asyncio(loop_scope="session")
async def test_log_system_event(server: SpinTestServer):
    """Test logging a system event (no actor)."""
    context = AuditContext()

    log = await log_audit_event(
        action=AuditAction.AGENT_EXECUTED,
        resource="agent",
        resource_id="agent-sys-a1",
        context=context,
        details={"scheduled": True},
    )

    assert log is not None
    assert log.action == AuditAction.AGENT_EXECUTED
    assert log.actorId is None
    assert log.resource == "agent"


@pytest.mark.asyncio(loop_scope="session")
async def test_get_audit_logs_by_actor(server: SpinTestServer):
    """Test retrieving audit logs filtered by actor."""
    context = AuditContext(actor_id="actor-filter-test-a1")
    await log_audit_event(
        action=AuditAction.LOGIN_SUCCESS,
        resource="user",
        resource_id="actor-filter-a1",
        context=context,
    )

    logs = await get_audit_logs(actor_id="actor-filter-test-a1", limit=10)

    assert isinstance(logs, list)
    assert len(logs) >= 1
    assert all(log.actorId == "actor-filter-test-a1" for log in logs)


@pytest.mark.asyncio(loop_scope="session")
async def test_get_audit_logs_by_action(server: SpinTestServer):
    """Test retrieving audit logs filtered by action type."""
    context = AuditContext(actor_id="action-filter-test-a1")
    await log_audit_event(
        action=AuditAction.API_KEY_REVOKED,
        resource="api_key",
        resource_id="action-filter-a1",
        context=context,
    )

    logs = await get_audit_logs(action=AuditAction.API_KEY_REVOKED, limit=10)

    assert isinstance(logs, list)
    assert len(logs) >= 1
    assert all(log.action == AuditAction.API_KEY_REVOKED for log in logs)


@pytest.mark.asyncio(loop_scope="session")
async def test_get_user_activity(server: SpinTestServer):
    """Test getting activity for a specific user."""
    context = AuditContext(actor_id="user-activity-test-a1")
    await log_audit_event(
        action=AuditAction.AGENT_CREATED,
        resource="agent",
        resource_id="agent-user-activity-a1",
        context=context,
    )

    activity = await get_user_activity("user-activity-test-a1", limit=10)

    assert isinstance(activity, list)
    assert len(activity) >= 1
    assert all(log.actorId == "user-activity-test-a1" for log in activity)


@pytest.mark.asyncio(loop_scope="session")
async def test_get_resource_history(server: SpinTestServer):
    """Test getting history for a specific resource."""
    resource_id = "resource-history-test-a1"
    context = AuditContext(actor_id="history-test-actor-a1")

    await log_audit_event(
        action=AuditAction.AGENT_CREATED,
        resource="agent",
        resource_id=resource_id,
        context=context,
    )
    await log_audit_event(
        action=AuditAction.AGENT_UPDATED,
        resource="agent",
        resource_id=resource_id,
        context=context,
        details={"change": "name"},
    )

    history = await get_resource_history("agent", resource_id)

    assert isinstance(history, list)
    assert len(history) >= 2
    assert all(log.resourceId == resource_id for log in history)


@pytest.mark.asyncio(loop_scope="session")
async def test_audit_log_pagination(server: SpinTestServer):
    """Test pagination of audit logs."""
    context = AuditContext(actor_id="pagination-test-a1")
    for i in range(5):
        await log_audit_event(
            action=AuditAction.SETTINGS_CHANGED,
            resource="settings",
            resource_id=f"setting-page-a1-{i}",
            context=context,
        )

    page1 = await get_audit_logs(actor_id="pagination-test-a1", limit=2, offset=0)
    assert len(page1) == 2

    page2 = await get_audit_logs(actor_id="pagination-test-a1", limit=2, offset=2)
    assert len(page2) >= 1

    page1_ids = {log.id for log in page1}
    page2_ids = {log.id for log in page2}
    assert page1_ids.isdisjoint(page2_ids)
