#!/bin/bash
# Supabase Database Restore Script
#
# This script restores Supabase backups from:
# - PostgreSQL SQL dump
# - Docker volumes (db_data, storage)
#
# Usage:
#   ./restore-database.sh TIMESTAMP [--from-s3]
#
# Arguments:
#   TIMESTAMP      Backup timestamp (format: YYYYMMDD_HHMMSS)
#
# Options:
#   --from-s3      Download backup from S3 before restoring
#
# Example:
#   ./restore-database.sh 20260129_020000
#   ./restore-database.sh 20260129_020000 --from-s3

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/var/backups/supabase}"
FROM_S3=false

# Parse arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 TIMESTAMP [--from-s3]"
    echo ""
    echo "Example:"
    echo "  $0 20260129_020000"
    echo "  $0 20260129_020000 --from-s3"
    exit 1
fi

TIMESTAMP=$1
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        --from-s3)
            FROM_S3=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}=== Supabase Database Restore ===${NC}"
echo "Timestamp: $TIMESTAMP"
echo "Backup directory: $BACKUP_DIR"
echo ""

# Download from S3 if requested
if [ "$FROM_S3" = true ]; then
    if [ -z "${S3_BUCKET:-}" ]; then
        echo -e "${RED}✗ ERROR: S3_BUCKET environment variable not set${NC}"
        exit 1
    fi

    if ! command -v aws &> /dev/null; then
        echo -e "${RED}✗ ERROR: AWS CLI not installed${NC}"
        exit 1
    fi

    echo -e "${BLUE}Downloading backup from S3...${NC}"
    S3_PATH="s3://$S3_BUCKET/supabase-backups/$TIMESTAMP/"

    if aws s3 sync "$S3_PATH" "$BACKUP_DIR" \
        --exclude "*" \
        --include "*_${TIMESTAMP}.*"; then
        echo -e "${GREEN}✓ Downloaded from $S3_PATH${NC}"
    else
        echo -e "${RED}✗ S3 download failed${NC}"
        exit 1
    fi
fi

# Check if backup files exist
POSTGRES_BACKUP="$BACKUP_DIR/postgres_${TIMESTAMP}.sql.gz"
DB_VOLUME_BACKUP="$BACKUP_DIR/db_data_${TIMESTAMP}.tar.gz"
STORAGE_BACKUP="$BACKUP_DIR/storage_${TIMESTAMP}.tar.gz"

if [ ! -f "$POSTGRES_BACKUP" ]; then
    echo -e "${RED}✗ ERROR: PostgreSQL backup not found: $POSTGRES_BACKUP${NC}"
    exit 1
fi

echo -e "${YELLOW}WARNING: This will overwrite the current database!${NC}"
echo -e "${YELLOW}All current data will be lost!${NC}"
echo ""
read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

# Stop Supabase services
echo -e "${BLUE}Stopping Supabase services...${NC}"
cd "$(dirname "$0")/.."
docker compose down

# Restore database volume (if exists)
if [ -f "$DB_VOLUME_BACKUP" ]; then
    echo -e "${BLUE}Restoring database volume...${NC}"
    docker run --rm \
        -v supabase_db_data:/data \
        -v "$BACKUP_DIR":/backup \
        alpine sh -c "rm -rf /data/* /data/..?* /data/.[!.]* 2>/dev/null || true && tar xzf /backup/db_data_${TIMESTAMP}.tar.gz -C /data"
    echo -e "${GREEN}✓ Database volume restored${NC}"
fi

# Start database service only
echo -e "${BLUE}Starting database service...${NC}"
docker compose up -d db
echo "Waiting for database to be ready..."
sleep 10

# Restore PostgreSQL database
echo -e "${BLUE}Restoring PostgreSQL database...${NC}"
gunzip < "$POSTGRES_BACKUP" | docker exec -i supabase-db psql -U postgres -d postgres
echo -e "${GREEN}✓ PostgreSQL database restored${NC}"

# Restore storage volume (if exists)
if [ -f "$STORAGE_BACKUP" ]; then
    echo -e "${BLUE}Restoring storage volume...${NC}"
    docker run --rm \
        -v supabase_storage:/data \
        -v "$BACKUP_DIR":/backup \
        alpine sh -c "rm -rf /data/* /data/..?* /data/.[!.]* 2>/dev/null || true && tar xzf /backup/storage_${TIMESTAMP}.tar.gz -C /data"
    echo -e "${GREEN}✓ Storage volume restored${NC}"
fi

# Start all services
echo -e "${BLUE}Starting all Supabase services...${NC}"
docker compose up -d

echo ""
echo -e "${GREEN}=== Restore completed successfully ===${NC}"
echo "Verifying services..."
sleep 5
docker compose ps

echo ""
echo -e "${YELLOW}IMPORTANT: Verify your data after restore!${NC}"
echo -e "${YELLOW}Test authentication, database queries, and storage access.${NC}"

exit 0
