// Authenticate admin user to create a user in the Mongo database
db = db.getSiblingDB('admin');

db.auth(
    process.env.MONGO_INITDB_ROOT_USERNAME,
    process.env.MONGO_INITDB_ROOT_PASSWORD
);
// Create an ibf database for ibf application
db = db.getSiblingDB(process.env.MONGO_DATABASE)
// Check if user already exists
let userExists = db.getUser(process.env.MONGO_USERNAME)

if (!userExists) {
    // if user doesn't exist in database, then it must be created
    db.createUser({
        user: process.env.MONGO_USERNAME,
        pwd: process.env.MONGO_PASSWORD,
        roles: [
            {role: "userAdminAnyDatabase", db: "admin"},
            {role: "readWriteAnyDatabase", db: "admin"},
            {role: "clusterMonitor", db: "admin"}
        ]

    });
} else {
    print("user already exists !")
}
