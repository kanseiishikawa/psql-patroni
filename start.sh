#!/usr/bin/env bash
set -x
docker compose down --remove-orphans -v
docker build -t test-psql .
docker-compose up -d
docker ps -a
