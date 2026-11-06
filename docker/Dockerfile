# =============================================================================
# Kambriq API image
#
# WHAT: builds a Docker image that runs the NestJS API (dist/apps/api/main.js).
# WHY:  the same image runs everywhere (my laptop, CI, a server), so "it works
#       on my machine" becomes "it works in the image".
# HOW:  docker build -f docker/Dockerfile -t kambriq-api .   (from the repo root)
#       CI builds it on every push, tests it, and pushes it to GHCR from master.
#
# Every instruction creates a LAYER. Docker caches layers and rebuilds only from
# the first instruction whose input changed, so the order below matters.
# =============================================================================

# Base image: Node.js 26 on Debian "bookworm", "slim" variant (no extra tools).
# WHY Debian (glibc) and not Alpine (musl): Prisma's engines need glibc.
FROM node:26-bookworm-slim

# Install pnpm, the package manager of this monorepo (see "packageManager" in
# package.json, which pnpm then uses to pick its exact version).
RUN npm install -g pnpm

# Every next command runs in this folder inside the image.
WORKDIR /usr/src/app

# Copy ONLY the dependency files first.
# WHY: the slow "pnpm install" layer below is then reused from the cache as long
# as these files don't change, even when the source code changes.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Copy the Prisma schemas before installing.
# WHY: "pnpm install" runs the "postinstall" script, which generates the Prisma
# clients from prisma/*/schema.prisma. Without this folder, it would fail.
COPY prisma ./prisma

# Install all dependencies (and generate the Prisma clients).
# Improvement for later: add --frozen-lockfile, so the build fails instead of
# silently changing versions when package.json and the lockfile disagree.
RUN pnpm install

# Copy the rest of the source code (filtered by .dockerignore: no node_modules,
# no dist, no .git, no .env).
COPY . .

# Compile the API with Nx + webpack into dist/apps/api/.
RUN pnpm build

# Documentation only: the API listens on port 3000 inside the container.
# The real port mapping is done by "docker run -p" or by docker-compose.yml.
EXPOSE 3000

# The command run when a container starts from this image.
# Exec form (a JSON list): node gets the stop signals directly (clean shutdown).
CMD ["node", "dist/apps/api/main.js"]
