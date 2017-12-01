#!/usr/bin/env bash
rm Gemfile.lock
(sleep 15 && open http://localhost:4000) &
docker-compose up --build
docker-compose down
