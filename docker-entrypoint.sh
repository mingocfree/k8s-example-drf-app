#!/bin/bash

echo "Starting collectstatic"
python3 manage.py collectstatic --noinput

echo "Starting server & celery server"
daphne -b 0.0.0.0 -p 80 apps.asgi:application -v 0
