# Advanced Setup

The advanced steps below are intended for people with sysadmin experience. If you are not comfortable with these steps, please refer to the [basic setup guide](../platform/getting-started.md).

> **Recommended:** This guide uses Poetry and Docker commands directly. For a better developer experience, consider using [mise](https://mise.jdx.dev) which provides unified task management. See [Migration Guide](../MISE_MIGRATION.md) for details.

## Introduction

For the advanced setup, first follow the [basic setup guide](../platform/getting-started.md) to get the server up and running. Once you have the server running, you can follow the steps below to configure the server for your specific needs.

## Configuration

### Setting config via environment variables

The server uses environment variables to store configs. You can set these environment variables in a `.env` file in the root of the project. The `.env` file should look like this:

```bash
# .env
KEY1=value1
KEY2=value2
```

The server will automatically load the `.env` file when it starts. You can also set the environment variables directly in your shell. Refer to your operating system's documentation on how to set environment variables in the current session.

The valid options are listed in `.env.default` files in the backend and frontend directories:
- `autogpt_platform/backend/.env.default` → `autogpt_platform/backend/.env`
- `autogpt_platform/frontend/.env.default` → `autogpt_platform/frontend/.env`
- `autogpt_platform/.env.default` → `autogpt_platform/.env` (platform-level config)

```bash
# Copy the backend .env.default file to .env
cd autogpt_platform/backend
cp .env.default .env
```

### Using Mise (Recommended)

Mise provides a better developer experience with unified task management:

```bash
# See all available tasks
mise tasks

# Start infrastructure
mise run docker:up

# Run migrations
mise run db:migrate

# Start backend
mise run backend
```

For complete migration guide, see [docs/MISE_MIGRATION.md](../MISE_MIGRATION.md).

### Secrets directory

The secret directory is located at `./secrets`. You can store any secrets you need in this directory. The server will automatically load the secrets when it starts.

An example for a secret called `my_secret` would look like this:

```bash
# ./secrets/my_secret
my_secret_value
```

This is useful when running on docker so you can copy the secrets into the container without exposing them in the Dockerfile.

## Database selection

### PostgreSQL

We use a Supabase PostgreSQL as the database. Generate the Prisma client with:

```bash
poetry run prisma generate
```

This will generate the Prisma client for PostgreSQL. You will also need to run the PostgreSQL database in a separate container. You can use the `docker-compose.yml` file in the `autogpt_platform` directory to run the services.

```bash
cd autogpt_platform
docker compose up -d
```

**Note:** You can also use mise: `mise run docker:up`

You can then run the migrations from the `backend` directory.

```bash
cd backend
poetry run prisma migrate dev
```

**Note:** You can also use mise: `mise run db:migrate`

## AutoGPT Agent Server Advanced set up

This guide walks you through a dockerized set up, with an external DB (postgres)

### Setup

We use the Poetry to manage the dependencies. To set up the project, follow these steps inside this directory:

0. Install Poetry
    ```sh
    pip install poetry
    ```
    
1. Configure Poetry to use .venv in your project directory
    ```sh
    poetry config virtualenvs.in-project true
    ```

2. Enter the poetry shell

   ```sh
   poetry shell
   ```

3. Install dependencies

   ```sh
   poetry install
   ```

4. Copy .env.default to .env

   ```sh
   cp .env.default .env
   ```

5. Generate the Prisma client

   ```sh
   poetry run prisma generate
   ```

   > In case Prisma generates the client for the global Python installation instead of the virtual environment, the current mitigation is to just uninstall the global Prisma package:
   >
   > ```sh
   > pip uninstall prisma
   > ```
   >
   > Then run the generation again. The path _should_ look something like this:  
   > `<some path>/pypoetry/virtualenvs/backend-TQIRSwR6-py3.12/bin/prisma`

6. Run the infrastructure services

   ```sh
   cd autogpt_platform
   docker compose up -d
   ```

   **Note:** You can also use mise: `mise run docker:up`

7. Run the migrations (from the backend folder)

   ```sh
   cd backend
   poetry run prisma migrate deploy
   ```

   **Note:** You can also use mise: `mise run db:migrate`

### Running The Server

#### Starting the server directly

Run the following command:

```sh
poetry run app
```
