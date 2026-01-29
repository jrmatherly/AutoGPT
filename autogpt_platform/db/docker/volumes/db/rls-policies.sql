-- Row-Level Security Policies for Multi-Tenant Isolation
-- Defense-in-depth: These policies enforce tenant isolation even if application code has bugs.
-- The backend service role bypasses RLS; these protect against direct DB access scenarios.
--
-- USAGE: Run this script AFTER Prisma migrations have created the tables.
--        cd autogpt_platform && make apply-rls
--        Or: docker exec supabase-db psql -U postgres -d postgres -f /path/to/rls-policies.sql
--
-- This script is idempotent - safe to run multiple times.

-- Helper function to get current user's organization IDs
-- Uses Supabase auth.uid() to identify the authenticated user
CREATE OR REPLACE FUNCTION "platform".get_user_organization_ids()
RETURNS SETOF TEXT AS $$
  SELECT "organizationId"
  FROM "platform"."OrganizationMember"
  WHERE "userId" = auth.uid()::text
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ============================================================================
-- AgentGraph RLS Policies
-- Users can only access graphs in organizations they belong to
-- Note: organizationId is nullable for backward compatibility with existing data
-- ============================================================================

ALTER TABLE "platform"."AgentGraph" ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (idempotent)
DROP POLICY IF EXISTS "Users can view graphs in their organizations" ON "platform"."AgentGraph";
DROP POLICY IF EXISTS "Users can insert graphs in their organizations" ON "platform"."AgentGraph";
DROP POLICY IF EXISTS "Users can update graphs in their organizations" ON "platform"."AgentGraph";
DROP POLICY IF EXISTS "Users can delete graphs in their organizations" ON "platform"."AgentGraph";
DROP POLICY IF EXISTS "Service role has full access to AgentGraph" ON "platform"."AgentGraph";

-- Allow access to graphs in user's organizations OR graphs without an organization (legacy)
CREATE POLICY "Users can view graphs in their organizations"
  ON "platform"."AgentGraph" FOR SELECT
  USING (
    "organizationId" IS NULL
    OR "organizationId" IN (SELECT "platform".get_user_organization_ids())
  );

CREATE POLICY "Users can insert graphs in their organizations"
  ON "platform"."AgentGraph" FOR INSERT
  WITH CHECK (
    "organizationId" IS NULL
    OR "organizationId" IN (SELECT "platform".get_user_organization_ids())
  );

CREATE POLICY "Users can update graphs in their organizations"
  ON "platform"."AgentGraph" FOR UPDATE
  USING (
    "organizationId" IS NULL
    OR "organizationId" IN (SELECT "platform".get_user_organization_ids())
  );

CREATE POLICY "Users can delete graphs in their organizations"
  ON "platform"."AgentGraph" FOR DELETE
  USING (
    "organizationId" IS NULL
    OR "organizationId" IN (SELECT "platform".get_user_organization_ids())
  );

-- Service role bypass for backend operations
CREATE POLICY "Service role has full access to AgentGraph"
  ON "platform"."AgentGraph" FOR ALL
  USING (auth.role() = 'service_role');

-- ============================================================================
-- AgentGraphExecution RLS Policies
-- Users can only access executions for graphs in their organizations
-- Execution inherits access from its parent AgentGraph
-- ============================================================================

ALTER TABLE "platform"."AgentGraphExecution" ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (idempotent)
DROP POLICY IF EXISTS "Users can view executions in their organizations" ON "platform"."AgentGraphExecution";
DROP POLICY IF EXISTS "Users can insert executions in their organizations" ON "platform"."AgentGraphExecution";
DROP POLICY IF EXISTS "Users can update executions in their organizations" ON "platform"."AgentGraphExecution";
DROP POLICY IF EXISTS "Users can delete executions in their organizations" ON "platform"."AgentGraphExecution";
DROP POLICY IF EXISTS "Service role has full access to AgentGraphExecution" ON "platform"."AgentGraphExecution";

CREATE POLICY "Users can view executions in their organizations"
  ON "platform"."AgentGraphExecution" FOR SELECT
  USING (
    "agentGraphId" IN (
      SELECT id FROM "platform"."AgentGraph"
      WHERE "organizationId" IS NULL
        OR "organizationId" IN (SELECT "platform".get_user_organization_ids())
    )
  );

CREATE POLICY "Users can insert executions in their organizations"
  ON "platform"."AgentGraphExecution" FOR INSERT
  WITH CHECK (
    "agentGraphId" IN (
      SELECT id FROM "platform"."AgentGraph"
      WHERE "organizationId" IS NULL
        OR "organizationId" IN (SELECT "platform".get_user_organization_ids())
    )
  );

CREATE POLICY "Users can update executions in their organizations"
  ON "platform"."AgentGraphExecution" FOR UPDATE
  USING (
    "agentGraphId" IN (
      SELECT id FROM "platform"."AgentGraph"
      WHERE "organizationId" IS NULL
        OR "organizationId" IN (SELECT "platform".get_user_organization_ids())
    )
  );

CREATE POLICY "Users can delete executions in their organizations"
  ON "platform"."AgentGraphExecution" FOR DELETE
  USING (
    "agentGraphId" IN (
      SELECT id FROM "platform"."AgentGraph"
      WHERE "organizationId" IS NULL
        OR "organizationId" IN (SELECT "platform".get_user_organization_ids())
    )
  );

-- Service role bypass for backend operations
CREATE POLICY "Service role has full access to AgentGraphExecution"
  ON "platform"."AgentGraphExecution" FOR ALL
  USING (auth.role() = 'service_role');

-- ============================================================================
-- AuditLog RLS Policies
-- Users can only view audit logs for their organizations
-- Note: organizationId is nullable for system-wide events
-- ============================================================================

ALTER TABLE "platform"."AuditLog" ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (idempotent)
DROP POLICY IF EXISTS "Users can view audit logs in their organizations" ON "platform"."AuditLog";
DROP POLICY IF EXISTS "Service role has full access to AuditLog" ON "platform"."AuditLog";

-- Users can view audit logs for their organizations
-- System-wide events (null organizationId) are only visible to service role
CREATE POLICY "Users can view audit logs in their organizations"
  ON "platform"."AuditLog" FOR SELECT
  USING (
    "organizationId" IS NOT NULL
    AND "organizationId" IN (SELECT "platform".get_user_organization_ids())
  );

-- Only backend can create audit logs (via service role)
-- No INSERT policy for regular users

-- Service role bypass for backend operations
CREATE POLICY "Service role has full access to AuditLog"
  ON "platform"."AuditLog" FOR ALL
  USING (auth.role() = 'service_role');

-- ============================================================================
-- OrganizationMember RLS Policies
-- Users can view members of organizations they belong to
-- ============================================================================

ALTER TABLE "platform"."OrganizationMember" ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (idempotent)
DROP POLICY IF EXISTS "Users can view members in their organizations" ON "platform"."OrganizationMember";
DROP POLICY IF EXISTS "Service role has full access to OrganizationMember" ON "platform"."OrganizationMember";

CREATE POLICY "Users can view members in their organizations"
  ON "platform"."OrganizationMember" FOR SELECT
  USING (
    "organizationId" IN (SELECT "platform".get_user_organization_ids())
  );

-- Only backend can manage members (via service role)
-- No INSERT/UPDATE/DELETE policies for regular users

-- Service role bypass for backend operations
CREATE POLICY "Service role has full access to OrganizationMember"
  ON "platform"."OrganizationMember" FOR ALL
  USING (auth.role() = 'service_role');

-- ============================================================================
-- Organization RLS Policies
-- Users can view organizations they belong to
-- ============================================================================

ALTER TABLE "platform"."Organization" ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (idempotent)
DROP POLICY IF EXISTS "Users can view their organizations" ON "platform"."Organization";
DROP POLICY IF EXISTS "Service role has full access to Organization" ON "platform"."Organization";

CREATE POLICY "Users can view their organizations"
  ON "platform"."Organization" FOR SELECT
  USING (
    id IN (SELECT "organizationId" FROM "platform"."OrganizationMember" WHERE "userId" = auth.uid()::text)
  );

-- Only backend can manage organizations (via service role)
-- No INSERT/UPDATE/DELETE policies for regular users

-- Service role bypass for backend operations
CREATE POLICY "Service role has full access to Organization"
  ON "platform"."Organization" FOR ALL
  USING (auth.role() = 'service_role');

-- ============================================================================
-- OrganizationInvitation RLS Policies
-- Users can view invitations for organizations they admin
-- ============================================================================

ALTER TABLE "platform"."OrganizationInvitation" ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (idempotent)
DROP POLICY IF EXISTS "Admins can view invitations in their organizations" ON "platform"."OrganizationInvitation";
DROP POLICY IF EXISTS "Service role has full access to OrganizationInvitation" ON "platform"."OrganizationInvitation";

CREATE POLICY "Admins can view invitations in their organizations"
  ON "platform"."OrganizationInvitation" FOR SELECT
  USING (
    "organizationId" IN (
      SELECT "organizationId" FROM "platform"."OrganizationMember"
      WHERE "userId" = auth.uid()::text
        AND role IN ('OWNER', 'ADMIN')
    )
  );

-- Only backend can manage invitations (via service role)
-- No INSERT/UPDATE/DELETE policies for regular users

-- Service role bypass for backend operations
CREATE POLICY "Service role has full access to OrganizationInvitation"
  ON "platform"."OrganizationInvitation" FOR ALL
  USING (auth.role() = 'service_role');
