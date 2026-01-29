-- CreateEnum
CREATE TYPE "platform"."AuditAction" AS ENUM (
    'ORG_CREATED',
    'ORG_UPDATED',
    'ORG_DELETED',
    'ORG_SSO_CONFIGURED',
    'ORG_SCIM_CONFIGURED',
    'MEMBER_ADDED',
    'MEMBER_REMOVED',
    'MEMBER_ROLE_CHANGED',
    'MEMBER_INVITED',
    'INVITATION_ACCEPTED',
    'AGENT_CREATED',
    'AGENT_UPDATED',
    'AGENT_DELETED',
    'AGENT_EXECUTED',
    'AGENT_SHARED',
    'LOGIN_SUCCESS',
    'LOGIN_FAILED',
    'LOGOUT',
    'SSO_LOGIN',
    'API_KEY_CREATED',
    'API_KEY_REVOKED',
    'ADMIN_IMPERSONATION',
    'SETTINGS_CHANGED'
);

-- CreateTable
CREATE TABLE "platform"."AuditLog" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actorId" TEXT,
    "actorEmail" TEXT,
    "actorIp" TEXT,
    "action" "platform"."AuditAction" NOT NULL,
    "resource" TEXT NOT NULL,
    "resourceId" TEXT,
    "organizationId" TEXT,
    "details" JSONB,
    "userAgent" TEXT,
    "requestId" TEXT,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "AuditLog_organizationId_createdAt_idx" ON "platform"."AuditLog"("organizationId", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_actorId_createdAt_idx" ON "platform"."AuditLog"("actorId", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_action_createdAt_idx" ON "platform"."AuditLog"("action", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_resourceId_idx" ON "platform"."AuditLog"("resourceId");

-- AddForeignKey
ALTER TABLE "platform"."AuditLog" ADD CONSTRAINT "AuditLog_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "platform"."Organization"("id") ON DELETE SET NULL ON UPDATE CASCADE;
