# Audit Log Migration Fix - Database Error Analysis

**Date:** 2026-01-30
**Migration:** `20260129010121_add_audit_log`
**Error:** P3018 - Type "AuditAction" already exists
**Status:** ✅ RESOLVED - Solution provided

---

## Error Analysis

### The Problem

**Error Message:**
```
Error: P3018
Migration name: 20260129010121_add_audit_log
Database error code: 42710
Database error: ERROR: type "AuditAction" already exists
```

### Root Cause

The migration **partially executed** and then failed:

| Component | Status | Evidence |
|-----------|--------|----------|
| **AuditAction enum** | ✅ **EXISTS** in `platform` schema | `SELECT typname FROM pg_type` shows it exists |
| **AuditLog table** | ❌ **MISSING** | `\dt platform.AuditLog` shows no table |
| **Migration record** | ⚠️ **INCOMPLETE** | `finished_at IS NULL`, `applied_steps_count = 0` |

### What Happened

1. Migration started: `2026-01-30 08:11:48.865201 UTC`
2. Step 1 executed: `CREATE TYPE "platform"."AuditAction"` ✅ **Succeeded**
3. Migration crashed or was interrupted **before completing**
4. Step 2 never executed: `CREATE TABLE "platform"."AuditLog"` ❌ **Missing**
5. Prisma marked migration as **failed** in `_prisma_migrations`
6. Subsequent `prisma migrate` commands refuse to run

### Database State

```sql
-- ✅ ENUM EXISTS
platform.AuditAction (enum with 25 values)

-- ❌ TABLE MISSING
platform.AuditLog (does not exist)

-- ⚠️ MIGRATION INCOMPLETE
_prisma_migrations.20260129010121_add_audit_log
  started_at: 2026-01-30 08:11:48.865201+00
  finished_at: NULL
  applied_steps_count: 0
```

---

## Solution Options

### Option 1: Mark Migration as Failed and Retry (RECOMMENDED)

This is the safest approach for development databases.

**Steps:**

1. **Mark the migration as rolled back:**
   ```bash
   docker exec supabase-db psql -U postgres -d postgres -c "
     UPDATE _prisma_migrations
     SET finished_at = NOW(),
         rolled_back_at = NOW(),
         logs = 'Manually rolled back incomplete migration'
     WHERE migration_name = '20260129010121_add_audit_log';
   "
   ```

2. **Drop the partially created enum:**
   ```bash
   docker exec supabase-db psql -U postgres -d postgres -c "
     DROP TYPE IF EXISTS platform.AuditAction CASCADE;
   "
   ```

3. **Re-run migrations:**
   ```bash
   cd /Users/jason/dev/AutoGPT/autogpt_platform
   mise run db:migrate
   ```

**Why This Works:**
- Marks the migration as completed (but rolled back)
- Removes the partially created enum
- Allows Prisma to re-apply the migration cleanly
- Safe for development environments

---

### Option 2: Manually Complete the Migration

If you want to keep the existing enum and just complete the migration.

**Steps:**

1. **Check current enum values:**
   ```bash
   docker exec supabase-db psql -U postgres -d postgres -c "
     SELECT enumlabel
     FROM pg_enum e
     JOIN pg_type t ON e.enumtypid = t.oid
     WHERE t.typname = 'AuditAction'
     ORDER BY enumsortorder;
   "
   ```

2. **Manually apply remaining migration steps:**
   ```bash
   docker exec supabase-db psql -U postgres -d postgres <<'SQL'
   -- CreateTable (if not exists)
   CREATE TABLE IF NOT EXISTS "platform"."AuditLog" (
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
   CREATE INDEX IF NOT EXISTS "AuditLog_organizationId_createdAt_idx"
   ON "platform"."AuditLog"("organizationId", "createdAt");

   CREATE INDEX IF NOT EXISTS "AuditLog_actorId_createdAt_idx"
   ON "platform"."AuditLog"("actorId", "createdAt");

   CREATE INDEX IF NOT EXISTS "AuditLog_action_createdAt_idx"
   ON "platform"."AuditLog"("action", "createdAt");

   CREATE INDEX IF NOT EXISTS "AuditLog_resourceId_idx"
   ON "platform"."AuditLog"("resourceId");

   -- AddForeignKey
   DO $$
   BEGIN
       IF NOT EXISTS (
           SELECT 1 FROM pg_constraint
           WHERE conname = 'AuditLog_organizationId_fkey'
       ) THEN
           ALTER TABLE "platform"."AuditLog"
           ADD CONSTRAINT "AuditLog_organizationId_fkey"
           FOREIGN KEY ("organizationId")
           REFERENCES "platform"."Organization"("id")
           ON DELETE SET NULL
           ON UPDATE CASCADE;
       END IF;
   END $$;
   SQL
   ```

3. **Mark migration as completed:**
   ```bash
   docker exec supabase-db psql -U postgres -d postgres -c "
     UPDATE _prisma_migrations
     SET finished_at = NOW(),
         applied_steps_count = 1
     WHERE migration_name = '20260129010121_add_audit_log';
   "
   ```

**Why This Works:**
- Keeps the existing enum
- Completes the missing table and indexes
- Updates Prisma migration tracking

---

### Option 3: Nuclear Option - Reset Test Database

For development/test databases only, if you don't care about existing data.

**Steps:**

```bash
# Stop database
cd /Users/jason/dev/AutoGPT/autogpt_platform
mise run docker:down

# Delete database volume
rm -rf db/docker/volumes/db/data

# Restart and migrate
mise run docker:up
mise run db:migrate
```

**⚠️ WARNING:** This deletes ALL database data. Only use for test databases.

---

## Recommended Fix (Quick & Safe)

For your development environment, I recommend **Option 1**:

```bash
# 1. Mark migration as rolled back
docker exec supabase-db psql -U postgres -d postgres -c "
  UPDATE _prisma_migrations
  SET finished_at = NOW(),
      rolled_back_at = NOW(),
      logs = 'Manually rolled back incomplete migration - enum existed but table did not'
  WHERE migration_name = '20260129010121_add_audit_log';
"

# 2. Drop the incomplete enum
docker exec supabase-db psql -U postgres -d postgres -c "
  DROP TYPE IF EXISTS platform.AuditAction CASCADE;
"

# 3. Re-run migrations
cd /Users/jason/dev/AutoGPT/autogpt_platform
mise run db:migrate
```

---

## Verification

After applying the fix, verify success:

### 1. Check Migration Status
```bash
docker exec supabase-db psql -U postgres -d postgres -c "
  SELECT migration_name, finished_at, rolled_back_at
  FROM _prisma_migrations
  WHERE migration_name = '20260129010121_add_audit_log';
"
```

**Expected:** Either `finished_at` populated (Option 2) or `rolled_back_at` populated (Option 1)

### 2. Check AuditAction Enum
```bash
docker exec supabase-db psql -U postgres -d postgres -c "
  SELECT nspname, typname
  FROM pg_type t
  JOIN pg_namespace n ON t.typnamespace = n.oid
  WHERE typname = 'AuditAction';
"
```

**Expected:** Shows `platform.AuditAction` (or empty if using Option 1 before re-migration)

### 3. Check AuditLog Table
```bash
docker exec supabase-db psql -U postgres -d postgres -c "\dt platform.AuditLog"
```

**Expected:** Shows the table with proper schema

### 4. Run Tests
```bash
mise run test:backend
```

**Expected:** Tests should run without migration errors

---

## Prevention

### How This Happened

This type of failure occurs when:
1. Migration starts executing
2. Process is interrupted (Ctrl+C, system crash, connection loss)
3. Prisma doesn't get a chance to mark migration as failed/rolled back
4. Database is left in partially migrated state

### Prevention Strategies

1. **Use Transactions** (Prisma does this by default for SQL migrations)
2. **Monitor Migration Logs** - Check for interruptions
3. **Always use mise tasks** - They handle environment setup correctly
4. **Development Snapshots** - Take database snapshots before major migrations

### Prisma Migration Best Practices

```bash
# Always check migration status before applying
prisma migrate status

# Use deploy for production (doesn't prompt, fails fast)
prisma migrate deploy

# Use dev for development (interactive, can reset)
prisma migrate dev
```

---

## Technical Details

### Prisma Migration Tracking

Prisma uses the `_prisma_migrations` table to track migration state:

```sql
CREATE TABLE _prisma_migrations (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    checksum VARCHAR(64) NOT NULL,
    finished_at TIMESTAMP,
    migration_name VARCHAR(255) NOT NULL,
    logs TEXT,
    rolled_back_at TIMESTAMP,
    started_at TIMESTAMP NOT NULL DEFAULT NOW(),
    applied_steps_count INTEGER NOT NULL DEFAULT 0
);
```

**Key Fields:**
- `finished_at`: NULL = migration incomplete
- `rolled_back_at`: NULL = not rolled back
- `applied_steps_count`: 0 = no steps completed (but enum DID create!)

### Why "applied_steps_count = 0" but Enum Exists?

Prisma counts "steps" as complete DDL statements, but the enum creation happened before Prisma could update the counter. This is a known edge case when migrations are interrupted.

---

## Alternative: prisma migrate resolve

Prisma provides a built-in command for this scenario:

```bash
# Mark migration as rolled back
cd /Users/jason/dev/AutoGPT/autogpt_platform/backend
poetry run prisma migrate resolve --rolled-back 20260129010121_add_audit_log

# Then manually clean up
docker exec supabase-db psql -U postgres -d postgres -c "
  DROP TYPE IF EXISTS platform.AuditAction CASCADE;
"

# Re-apply
poetry run prisma migrate deploy
```

**Documentation:** https://pris.ly/d/migrate-resolve

---

## Conclusion

**The migration failed mid-execution**, leaving the database in a partially migrated state:
- ✅ Enum created
- ❌ Table not created
- ⚠️ Migration marked as incomplete

**Recommended Solution:** Use **Option 1** (mark as rolled back, drop enum, re-migrate) for the cleanest fix.

**Estimated Time:** < 2 minutes to fix

**Risk:** Very low - this is a development database and the migration can be safely re-applied.
