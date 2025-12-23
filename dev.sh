#!/bin/bash

# Phoenix Local Development Script
# Based on app/README.md

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

# Check Docker for PostgreSQL
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Please start Docker Desktop first."
  exit 1
fi



# Start PostgreSQL
echo "=== Starting PostgreSQL ==="
docker compose up db -d
sleep 3

# Wait for DB
echo "=== Waiting for PostgreSQL ==="
for i in {1..30}; do
  if docker exec phoenix-db-1 pg_isready -U postgres > /dev/null 2>&1; then
    echo "PostgreSQL ready!"
    break
  fi
  sleep 1
done

# Setup environment
export PHOENIX_SQL_DATABASE_URL="postgresql://postgres:postgres@localhost:5432/postgres"

cd app

# Create .env if not exists
if [ ! -f .env ]; then
  echo "Creating .env from .env.example..."
  cp .env.example .env
fi

# Install dependencies
echo "=== Installing dependencies ==="
pnpm install --frozen-lockfile

# Build (required before first run)
echo "=== Building ==="
pnpm run build

# Start dev (uses mprocs to run frontend + backend together)
echo "=== Starting Phoenix ==="
echo "Access: http://localhost:6006"
echo ""
pnpm run dev
