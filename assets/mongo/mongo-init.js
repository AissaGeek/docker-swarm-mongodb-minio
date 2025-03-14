let maxAttempts = 30;
let attempt = 0;
let success = false;

while (attempt < maxAttempts && !success) {
    try {
        // Check if we're on primary
        let isMaster = db.isMaster();
        if (!isMaster.ismaster) {
            print("Not connected to primary, waiting... (Attempt " + (attempt + 1) + "/" + maxAttempts + ")");
            sleep(2000);
            attempt++;
            continue;
        }

        // Your existing code here
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

        success = true;
    } catch (err) {
        print("Error: " + err);
        if (attempt < maxAttempts - 1) {
            print("Retrying in 2 seconds...");
            sleep(2000);
        }
        attempt++;
    }
}

if (!success) {
    print("Failed to initialize after " + maxAttempts + " attempts");
    quit(1);
}