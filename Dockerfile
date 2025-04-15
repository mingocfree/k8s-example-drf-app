# ─── Builder Stage ─────────────────────────────────────────────────────────────
FROM python:3.12-slim AS builder

# Install uv into /uv /uvx /bin
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY . /app

# Install dependencies into a venv under /app/.venv
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-editable

# Copy the rest of your source
# ─── Final Stage ───────────────────────────────────────────────────────────────
FROM python:3.12-slim

# Make sure we use the venv’s python & scripts
ENV PATH="/app/.venv/bin:$PATH"

WORKDIR /app

# Copy venv + your source + entrypoint into the final image
COPY --from=builder /app/.venv/lib/python3.12/site-packages/ /usr/local/lib/python3.12/site-packages/
COPY --from=builder /app/ /app/
# Ensure your entrypoint is executable
RUN chmod +x ./docker-entrypoint.sh

# Use the entrypoint to start both Daphne and Celery
ENTRYPOINT ["sh","./docker-entrypoint.sh"]
