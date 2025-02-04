#!/bin/bash
set -e

echo "Waiting for MongoDB to be available ..."
until mongo --host localhost --quiet --eval "db.adminCommand('ping')" $> /dev/null; do
    sleep 1;
done

echo "Waiting for primary to be elected ..."
until mongo --host localhost --quiet --eval "db.isMaster().ismaster" |grep true &> /dev/null; do
  sleep 1;
done

echo "Primary is elected. Running initialization script ..."

mongo --host localhost /docker-entrypoint-initdb.d/mongo-init.js

echo "Initialization complete !"