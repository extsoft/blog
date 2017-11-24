#!/usr/bin/env bash
docker-compose down
(sleep 27 && open http://localhost:4000) &
docker-compose up
docker-compose down
