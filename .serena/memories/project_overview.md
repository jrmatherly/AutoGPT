# AutoGPT Project Overview

## Purpose
AutoGPT is a powerful platform for building, deploying, and managing continuous AI agents that automate complex workflows. It enables users to create custom AI-powered automation through a visual graph-based editor.

## Project Structure

The repository is a **monorepo** containing two main sections:

### 1. AutoGPT Platform (`autogpt_platform/`)
The modern, actively developed platform with:
- **Backend** (`/backend`): Python FastAPI server with async support
- **Frontend** (`/frontend`): Next.js 15 React application
- **Shared Libraries** (`/autogpt_libs`): Common Python utilities
- **Graph Templates** (`/graph_templates`): Pre-built workflow templates
- **Database** (`/db`): Database Docker configuration

Licensed under **Polyform Shield License**.

### 2. Classic AutoGPT (`classic/`)
The original/legacy components:
- **original_autogpt**: The original standalone AutoGPT agent
- **forge**: Toolkit for building custom agent applications
- **benchmark** (`agbenchmark`): Testing framework for agents
- **frontend**: Classic GUI interface

Licensed under **MIT License**.

## Tech Stack

### Backend (Platform)
- **Framework**: FastAPI with async support
- **Language**: Python 3.10+
- **Database**: PostgreSQL with Prisma ORM (includes pgvector for embeddings)
- **Queue**: RabbitMQ for async task processing
- **Cache**: Redis
- **Auth**: JWT-based with Supabase integration
- **Package Manager**: Poetry
- **Testing**: pytest with snapshot testing

### Frontend (Platform)
- **Framework**: Next.js 15 with App Router (client-first approach)
- **Language**: TypeScript
- **Data Fetching**: Orval-generated React Query hooks from OpenAPI spec
- **State**: React Query for server state, Zustand for complex local state
- **Styling**: Tailwind CSS + shadcn/ui (Radix primitives)
- **Components**: Design system with atoms, molecules, organisms
- **Icons**: Phosphor Icons (only)
- **Testing**: Playwright for E2E, Storybook for components, Vitest for units
- **Package Manager**: pnpm (v10.20.0+)
- **Node**: 22.x

### Classic Components
- Python with Poetry
- Flutter (mobile frontend)
- Various LLM provider integrations

## Key Concepts

1. **Agent Graphs**: Workflow definitions stored as JSON, executed by the backend
2. **Blocks**: Reusable components in `/backend/blocks/` that perform specific tasks
3. **Integrations**: OAuth and API connections stored per user
4. **Store/Marketplace**: Platform for sharing agent templates
5. **Execution Engine**: Separate executor service processes agent workflows

## Architecture Highlights

- **API Layer**: REST and WebSocket endpoints
- **Visual Builder**: Graph editor using @xyflow/react
- **Feature Flags**: LaunchDarkly integration
- **Security**: Cache protection middleware, ClamAV for file uploads
- **Monitoring**: Sentry for error tracking, Prometheus metrics
