#!/bin/bash
# Health Check Verification Script
#
# This script monitors and reports on the health status of all Supabase services
#
# Usage:
#   ./verify-health.sh [--watch] [--json]
#
# Options:
#   --watch    Continuously monitor health status (updates every 2 seconds)
#   --json     Output in JSON format
#
# Example:
#   ./verify-health.sh
#   ./verify-health.sh --watch
#   ./verify-health.sh --json

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"
WATCH_MODE=false
JSON_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --watch|-w)
            WATCH_MODE=true
            shift
            ;;
        --json|-j)
            JSON_MODE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--watch] [--json]"
            echo ""
            echo "Monitor health status of Supabase services"
            echo ""
            echo "Options:"
            echo "  --watch, -w    Continuously monitor (updates every 2s)"
            echo "  --json, -j     Output in JSON format"
            echo ""
            echo "Examples:"
            echo "  $0              # Show current health status"
            echo "  $0 --watch      # Continuous monitoring"
            echo "  $0 --json       # JSON output for scripting"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

cd "$DOCKER_DIR"

# Function to get health status
get_health_status() {
    if [ "$JSON_MODE" = true ]; then
        docker compose ps --format json | jq -r '.[] | {
            name: .Name,
            status: .State,
            health: .Health
        }'
    else
        clear
        echo -e "${BLUE}=== Supabase Health Status ===${NC}"
        echo -e "$(date '+%Y-%m-%d %H:%M:%S')"
        echo ""

        # Get service status
        SERVICES=$(docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}" | tail -n +2)

        # Count services by health status
        TOTAL=$(echo "$SERVICES" | wc -l)
        HEALTHY=$(echo "$SERVICES" | grep -c "healthy" || true)
        UNHEALTHY=$(echo "$SERVICES" | grep -c "unhealthy" || true)
        STARTING=$(echo "$SERVICES" | grep -c "starting" || true)

        # Print summary
        echo -e "${BLUE}Summary:${NC}"
        echo "  Total services: $TOTAL"
        echo -e "  Healthy: ${GREEN}$HEALTHY${NC}"
        [ $STARTING -gt 0 ] && echo -e "  Starting: ${YELLOW}$STARTING${NC}"
        [ $UNHEALTHY -gt 0 ] && echo -e "  Unhealthy: ${RED}$UNHEALTHY${NC}"
        echo ""

        # Print detailed status
        echo -e "${BLUE}Service Status:${NC}"
        echo "────────────────────────────────────────────────────────────────"

        while IFS=$'\t' read -r name status health; do
            # Color code based on health
            if [[ $health == *"healthy"* ]]; then
                COLOR=$GREEN
                ICON="✓"
            elif [[ $health == *"starting"* ]]; then
                COLOR=$YELLOW
                ICON="⟳"
            elif [[ $health == *"unhealthy"* ]]; then
                COLOR=$RED
                ICON="✗"
            else
                COLOR=$NC
                ICON="?"
            fi

            printf "${COLOR}%-3s %-25s %-20s %s${NC}\n" "$ICON" "$name" "$status" "$health"
        done <<< "$SERVICES"

        echo "────────────────────────────────────────────────────────────────"
        echo ""

        # Show unhealthy services with details
        if [ $UNHEALTHY -gt 0 ]; then
            echo -e "${RED}Unhealthy Services:${NC}"
            UNHEALTHY_SERVICES=$(echo "$SERVICES" | grep "unhealthy" | awk '{print $1}' || true)

            for service in $UNHEALTHY_SERVICES; do
                echo ""
                echo -e "${YELLOW}Service: $service${NC}"

                # Get health check details
                CONTAINER_ID=$(docker compose ps -q "$service" 2>/dev/null || true)
                if [ -n "$CONTAINER_ID" ]; then
                    HEALTH_INFO=$(docker inspect "$CONTAINER_ID" --format='{{json .State.Health}}' 2>/dev/null || echo '{}')

                    # Parse health check info
                    FAILING_STREAK=$(echo "$HEALTH_INFO" | jq -r '.FailingStreak // 0')
                    LAST_OUTPUT=$(echo "$HEALTH_INFO" | jq -r '.Log[-1].Output // "No output"' | head -c 200)

                    echo "  Failing streak: $FAILING_STREAK"
                    echo "  Last check output: $LAST_OUTPUT"

                    # Show recent logs
                    echo ""
                    echo "  Recent logs (last 5 lines):"
                    docker compose logs --tail=5 "$service" 2>/dev/null | sed 's/^/    /'
                fi
            done
            echo ""
        fi

        # Health check configuration summary
        echo -e "${BLUE}Health Check Configuration:${NC}"
        echo "────────────────────────────────────────────────────────────────"
        printf "%-25s %-10s %-10s %-8s %-12s\n" "Service" "Timeout" "Interval" "Retries" "Start Period"
        echo "────────────────────────────────────────────────────────────────"

        for service in $(docker compose ps --services); do
            CONTAINER_ID=$(docker compose ps -q "$service" 2>/dev/null || true)
            if [ -n "$CONTAINER_ID" ]; then
                HEALTH_CONFIG=$(docker inspect "$CONTAINER_ID" --format='{{json .Config.Healthcheck}}' 2>/dev/null || echo '{}')

                TIMEOUT=$(echo "$HEALTH_CONFIG" | jq -r '.Timeout // 0' | awk '{print $1/1000000000 "s"}')
                INTERVAL=$(echo "$HEALTH_CONFIG" | jq -r '.Interval // 0' | awk '{print $1/1000000000 "s"}')
                RETRIES=$(echo "$HEALTH_CONFIG" | jq -r '.Retries // 0')
                START=$(echo "$HEALTH_CONFIG" | jq -r '.StartPeriod // 0' | awk '{print $1/1000000000 "s"}')

                printf "%-25s %-10s %-10s %-8s %-12s\n" "$service" "$TIMEOUT" "$INTERVAL" "$RETRIES" "$START"
            fi
        done

        echo "────────────────────────────────────────────────────────────────"
        echo ""

        if [ "$WATCH_MODE" = false ]; then
            echo "Commands:"
            echo "  Watch mode:    $0 --watch"
            echo "  View logs:     docker compose logs <service>"
            echo "  Restart:       docker compose restart <service>"
        fi
    fi
}

# Main execution
if [ "$WATCH_MODE" = true ]; then
    echo -e "${YELLOW}Entering watch mode (Ctrl+C to exit)...${NC}"
    echo ""

    while true; do
        get_health_status
        sleep 2
    done
else
    get_health_status
fi

exit 0
