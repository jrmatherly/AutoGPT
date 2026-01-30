#!/bin/bash
# Supabase Automated Backup Script
#
# This script performs automated backups of:
# - PostgreSQL database (compressed SQL dump)
# - Docker volumes (db_data, storage)
#
# Usage:
#   ./backup-database.sh [--upload-s3]
#
# Options:
#   --upload-s3    Upload backups to S3 bucket (requires AWS CLI configured)
#
# Cron example (daily at 2 AM):
#   0 2 * * * /path/to/scripts/backup-database.sh >> /var/log/supabase-backup.log 2>&1

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/var/backups/supabase}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
UPLOAD_S3=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --upload-s3)
            UPLOAD_S3=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--upload-s3]"
            echo ""
            echo "Options:"
            echo "  --upload-s3    Upload backups to S3 bucket"
            echo ""
            echo "Environment variables:"
            echo "  BACKUP_DIR         Backup directory (default: /var/backups/supabase)"
            echo "  RETENTION_DAYS     Days to keep backups (default: 30)"
            echo "  S3_BUCKET          S3 bucket name for uploads (required if --upload-s3)"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}=== Supabase Automated Backup ===${NC}"
echo "Timestamp: $TIMESTAMP"
echo "Backup directory: $BACKUP_DIR"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}✗ ERROR: Docker is not running${NC}"
    exit 1
fi

# Check if Supabase containers are running
if ! docker compose ps | grep -q "supabase-db"; then
    echo -e "${RED}✗ ERROR: Supabase database container is not running${NC}"
    exit 1
fi

# Backup PostgreSQL database
echo -e "${BLUE}Backing up PostgreSQL database...${NC}"
POSTGRES_BACKUP="$BACKUP_DIR/postgres_${TIMESTAMP}.sql.gz"

if docker exec supabase-db pg_dump -U postgres -d postgres | gzip > "$POSTGRES_BACKUP"; then
    POSTGRES_SIZE=$(du -h "$POSTGRES_BACKUP" | cut -f1)
    echo -e "${GREEN}✓ PostgreSQL backup completed: $POSTGRES_SIZE${NC}"
else
    echo -e "${RED}✗ PostgreSQL backup failed${NC}"
    exit 1
fi

# Backup database volume
echo -e "${BLUE}Backing up database volume...${NC}"
DB_VOLUME_BACKUP="$BACKUP_DIR/db_data_${TIMESTAMP}.tar.gz"

if docker run --rm \
    -v supabase_db_data:/data:ro \
    -v "$BACKUP_DIR":/backup \
    alpine tar czf /backup/db_data_${TIMESTAMP}.tar.gz -C /data .; then
    DB_VOLUME_SIZE=$(du -h "$DB_VOLUME_BACKUP" | cut -f1)
    echo -e "${GREEN}✓ Database volume backup completed: $DB_VOLUME_SIZE${NC}"
else
    echo -e "${RED}✗ Database volume backup failed${NC}"
    exit 1
fi

# Backup storage volume
echo -e "${BLUE}Backing up storage volume...${NC}"
STORAGE_BACKUP="$BACKUP_DIR/storage_${TIMESTAMP}.tar.gz"

if docker run --rm \
    -v supabase_storage:/data:ro \
    -v "$BACKUP_DIR":/backup \
    alpine tar czf /backup/storage_${TIMESTAMP}.tar.gz -C /data .; then
    STORAGE_SIZE=$(du -h "$STORAGE_BACKUP" | cut -f1)
    echo -e "${GREEN}✓ Storage volume backup completed: $STORAGE_SIZE${NC}"
else
    echo -e "${RED}✗ Storage volume backup failed${NC}"
    exit 1
fi

# Create backup manifest
MANIFEST_FILE="$BACKUP_DIR/backup_manifest_${TIMESTAMP}.txt"
cat > "$MANIFEST_FILE" <<EOF
Supabase Backup Manifest
========================
Timestamp: $TIMESTAMP
Date: $(date)

Files:
- postgres_${TIMESTAMP}.sql.gz ($POSTGRES_SIZE)
- db_data_${TIMESTAMP}.tar.gz ($DB_VOLUME_SIZE)
- storage_${TIMESTAMP}.tar.gz ($STORAGE_SIZE)

Docker Compose Version:
$(docker compose version)

Supabase Version:
$(docker compose ps --format json | jq -r '.[] | select(.Name == "supabase-db") | .Image')

Total Backup Size: $(du -sh "$BACKUP_DIR" | cut -f1)
EOF

echo -e "${GREEN}✓ Backup manifest created${NC}"

# Upload to S3 if requested
if [ "$UPLOAD_S3" = true ]; then
    if [ -z "${S3_BUCKET:-}" ]; then
        echo -e "${RED}✗ ERROR: S3_BUCKET environment variable not set${NC}"
        exit 1
    fi

    if ! command -v aws &> /dev/null; then
        echo -e "${RED}✗ ERROR: AWS CLI not installed${NC}"
        exit 1
    fi

    echo -e "${BLUE}Uploading backups to S3...${NC}"

    S3_PATH="s3://$S3_BUCKET/supabase-backups/$TIMESTAMP/"

    if aws s3 sync "$BACKUP_DIR" "$S3_PATH" \
        --exclude "*" \
        --include "*_${TIMESTAMP}.*" \
        --storage-class STANDARD_IA; then
        echo -e "${GREEN}✓ Uploaded to $S3_PATH${NC}"
    else
        echo -e "${RED}✗ S3 upload failed${NC}"
        exit 1
    fi
fi

# Clean up old backups
echo -e "${BLUE}Cleaning up backups older than $RETENTION_DAYS days...${NC}"
DELETED_COUNT=$(find "$BACKUP_DIR" -name "*.gz" -mtime +$RETENTION_DAYS -delete -print | wc -l)
find "$BACKUP_DIR" -name "backup_manifest_*.txt" -mtime +$RETENTION_DAYS -delete

if [ "$DELETED_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Deleted $DELETED_COUNT old backup files${NC}"
else
    echo -e "${YELLOW}No old backups to delete${NC}"
fi

echo ""
echo -e "${GREEN}=== Backup completed successfully ===${NC}"
echo "Location: $BACKUP_DIR"
echo "Files:"
echo "  - postgres_${TIMESTAMP}.sql.gz"
echo "  - db_data_${TIMESTAMP}.tar.gz"
echo "  - storage_${TIMESTAMP}.tar.gz"
echo "  - backup_manifest_${TIMESTAMP}.txt"

# Return success
exit 0
