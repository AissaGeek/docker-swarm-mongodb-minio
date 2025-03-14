#!/bin/bash
set -e
# Wait for MongoDB to be ready
until mongosh --host mongo-1 --port 27017 -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --eval "print('ok');" &>/dev/null; do
    echo "Waiting for MongoDB to be ready..."
    sleep 5
done

# Initialize replica set
mongosh --host mongo-1 --port 27017 -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --eval '
try {
  rs.status()
    }
catch(err) {
    rs.initiate({
      _id: "rs0",
      members: [
        {_id: 0, host: "mongo-1:27017", priority: 2},
        {_id: 1, host: "mongo-2:27017", priority: 1},
        {_id: 2, host: "mongo-3:27017", priority: 1}
      ]
})};'

until mongosh --host mongo-1 --port 27017 -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --eval "rs.isMaster().ismaster" | grep -q true; do
    echo "Waiting for MongoDB replica set to initialize and primary to be elected..."
    sleep 5
done

echo "Executing database initiation script ... "
mongosh --host mongo-1 --port 27017 -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin /data/mongo-init.js