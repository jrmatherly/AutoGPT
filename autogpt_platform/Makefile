.PHONY: start-core stop-core logs-core format lint migrate run-backend run-frontend load-store-agents \
	drift-scan drift-scan-backend drift-scan-frontend drift-scan-libs drift-status drift-check drift-approve \
	drift-callgraph drift-analyze drift-coupling drift-coupling-cycles drift-coupling-hotspots \
	drift-test-topology drift-error-gaps drift-deep drift-full apply-rls verify-rls

# Run just Supabase + Redis + RabbitMQ
start-core:
	docker compose up -d deps

# Stop core services
stop-core:
	docker compose stop 

reset-db:
	docker compose stop db
	rm -rf db/docker/volumes/db/data
	cd backend && poetry run prisma migrate deploy
	cd backend && poetry run prisma generate
	cd backend && poetry run gen-prisma-stub
	
# View logs for core services
logs-core:
	docker compose logs -f deps

# Run formatting and linting for backend and frontend
format:
	cd backend && poetry run format
	cd frontend && pnpm format
	cd frontend && pnpm lint

init-env:
	cp -n .env.default .env || true
	cd backend && cp -n .env.default .env || true
	cd frontend && cp -n .env.default .env || true


# Run migrations for backend
migrate:
	cd backend && poetry run prisma migrate deploy
	cd backend && poetry run prisma generate
	cd backend && poetry run gen-prisma-stub

# Apply Row-Level Security policies for multi-tenant isolation
# Run this AFTER migrations to enable RLS on organization-scoped tables
apply-rls:
	@echo "Applying RLS policies to database..."
	docker exec supabase-db psql -U postgres -d postgres -f /docker-entrypoint-initdb.d/rls-policies.sql
	@echo "RLS policies applied successfully."

# Verify RLS policies are active
verify-rls:
	@echo "Checking RLS policies..."
	docker exec supabase-db psql -U postgres -d postgres -c "\
		SELECT schemaname, tablename, policyname, permissive, roles, cmd \
		FROM pg_policies \
		WHERE schemaname = 'platform' \
		ORDER BY tablename, policyname;"

run-backend:
	cd backend && poetry run app

run-frontend:
	cd frontend && pnpm dev

test-data:
	cd backend && poetry run python test/test_data_creator.py

load-store-agents:
	cd backend && poetry run load-store-agents

# ============================================================================
# Drift - Codebase Pattern Analysis
# ============================================================================

# Scan all projects
drift-scan:
	@echo "Scanning backend..."
	cd backend && drift scan backend/
	@echo "Scanning frontend..."
	cd frontend && drift scan src/
	@echo "Scanning libs..."
	cd autogpt_libs && drift scan .

# Scan individual projects
drift-scan-backend:
	cd backend && drift scan backend/ --verbose

drift-scan-frontend:
	cd frontend && drift scan src/ --verbose

drift-scan-libs:
	cd autogpt_libs && drift scan . --verbose

# Show drift status for all projects
drift-status:
	@echo "=== Backend ===" && cd backend && drift status --detailed || true
	@echo "\n=== Frontend ===" && cd frontend && drift status --detailed || true
	@echo "\n=== Libs ===" && cd autogpt_libs && drift status --detailed || true

# Check for violations (useful for CI)
drift-check:
	cd backend && drift check
	cd frontend && drift check
	cd autogpt_libs && drift check

# Approve all high-confidence patterns (95%+ confidence per config)
drift-approve:
	@echo "Approving patterns for backend..."
	cd backend && drift approve all --yes
	@echo "Approving patterns for frontend..."
	cd frontend && drift approve all --yes
	@echo "Approving patterns for libs..."
	cd autogpt_libs && drift approve all --yes

# Build call graphs for impact analysis
drift-callgraph:
	@echo "Building call graph for backend..."
	cd backend && drift callgraph build
	@echo "Building call graph for frontend..."
	cd frontend && drift callgraph build
	@echo "Building call graph for libs..."
	cd autogpt_libs && drift callgraph build

# Run language-specific analysis
drift-analyze:
	@echo "=== Python Analysis (Backend) ===" && cd backend && drift py status || true
	@echo "\n=== TypeScript Analysis (Frontend) ===" && cd frontend && drift ts status || true
	@echo "\n=== Python Analysis (Libs) ===" && cd autogpt_libs && drift py status || true

# Build module coupling graphs
drift-coupling:
	@echo "Building coupling graph for backend..."
	cd backend && drift coupling build
	@echo "Building coupling graph for frontend..."
	cd frontend && drift coupling build
	@echo "Building coupling graph for libs..."
	cd autogpt_libs && drift coupling build

# Find dependency cycles
drift-coupling-cycles:
	@echo "=== Backend Cycles ===" && cd backend && drift coupling cycles || true
	@echo "\n=== Frontend Cycles ===" && cd frontend && drift coupling cycles || true
	@echo "\n=== Libs Cycles ===" && cd autogpt_libs && drift coupling cycles || true

# Find highly coupled modules (hotspots)
drift-coupling-hotspots:
	@echo "=== Backend Hotspots ===" && cd backend && drift coupling hotspots || true
	@echo "\n=== Frontend Hotspots ===" && cd frontend && drift coupling hotspots || true
	@echo "\n=== Libs Hotspots ===" && cd autogpt_libs && drift coupling hotspots || true

# Build test topology (maps tests to code)
drift-test-topology:
	@echo "Building test topology for backend..."
	cd backend && drift test-topology build
	@echo "Building test topology for frontend..."
	cd frontend && drift test-topology build
	@echo "Building test topology for libs..."
	cd autogpt_libs && drift test-topology build

# Find error handling gaps
drift-error-gaps:
	@echo "=== Backend Error Handling Gaps ===" && cd backend && drift error-handling gaps | head -50 || true
	@echo "\n=== Frontend Error Handling Gaps ===" && cd frontend && drift error-handling gaps | head -50 || true
	@echo "\n=== Libs Error Handling Gaps ===" && cd autogpt_libs && drift error-handling gaps | head -50 || true

# Deep analysis: coupling, test topology, and error handling
drift-deep:
	$(MAKE) drift-coupling
	$(MAKE) drift-test-topology
	@echo "\nDeep analysis complete."
	@echo "Run 'make drift-coupling-cycles' to view dependency cycles"
	@echo "Run 'make drift-coupling-hotspots' to view highly coupled modules"
	@echo "Run 'make drift-error-gaps' to view error handling gaps"

# Full drift setup: scan, approve, and build call graphs
drift-full:
	$(MAKE) drift-scan
	$(MAKE) drift-approve
	$(MAKE) drift-callgraph
	$(MAKE) drift-deep
	@echo "\nDrift full setup complete. Run 'make drift-status' to verify."

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Core Services:"
	@echo "  start-core        - Start core services (Supabase, Redis, RabbitMQ) in background"
	@echo "  stop-core         - Stop the core services"
	@echo "  reset-db          - Reset the database by deleting the volume"
	@echo "  logs-core         - Tail the logs for core services"
	@echo ""
	@echo "Development:"
	@echo "  run-backend       - Run the backend FastAPI server"
	@echo "  run-frontend      - Run the frontend Next.js development server"
	@echo "  format            - Format & lint backend (Python) and frontend (TypeScript) code"
	@echo "  migrate           - Run backend database migrations"
	@echo "  init-env          - Initialize .env files from defaults"
	@echo ""
	@echo "Testing & Data:"
	@echo "  test-data         - Run the test data creator"
	@echo "  load-store-agents - Load store agents from agents/ folder into test database"
	@echo ""
	@echo "Security:"
	@echo "  apply-rls         - Apply Row-Level Security policies (run after migrate)"
	@echo "  verify-rls        - Verify RLS policies are active in database"
	@echo ""
	@echo "Drift (Pattern Analysis):"
	@echo "  drift-scan            - Scan all projects for patterns"
	@echo "  drift-scan-backend    - Scan backend only (verbose)"
	@echo "  drift-scan-frontend   - Scan frontend only (verbose)"
	@echo "  drift-scan-libs       - Scan libs only (verbose)"
	@echo "  drift-status          - Show drift status for all projects"
	@echo "  drift-check           - Check for violations (CI-friendly)"
	@echo "  drift-approve         - Approve all discovered patterns (95%+ confidence)"
	@echo "  drift-callgraph       - Build call graphs for impact analysis"
	@echo "  drift-analyze         - Run language-specific analysis (Python/TypeScript)"
	@echo ""
	@echo "Drift (Deep Analysis):"
	@echo "  drift-coupling        - Build module coupling graphs"
	@echo "  drift-coupling-cycles - Find dependency cycles"
	@echo "  drift-coupling-hotspots - Find highly coupled modules"
	@echo "  drift-test-topology   - Build test topology (maps tests to code)"
	@echo "  drift-error-gaps      - Find error handling gaps"
	@echo "  drift-deep            - Run all deep analysis (coupling, test-topology)"
	@echo ""
	@echo "Drift (Combined):"
	@echo "  drift-full            - Full setup: scan, approve, callgraph, and deep analysis"
