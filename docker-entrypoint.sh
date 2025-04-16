#!/bin/bash

echo "Starting collectstatic"
uv run manage.py collectstatic --noinput

echo "Starting server & celery server"
uv run daphne -b 0.0.0.0 -p 80 apps.asgi:application -v 0
