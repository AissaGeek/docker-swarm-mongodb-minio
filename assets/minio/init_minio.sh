#!/bin/bash
set -e


# AMQP configuration
# shellcheck disable=SC2034
AMQP_URL="amqp://ibf_user:ibf_user@localhost:5672/"
# shellcheck disable=SC2034
/usr/bin/mc alias set myminio http://"${MINIO_HOST}":9000 "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}"

# Function to create a bucket if it doesn't exist
create_bucket_if_not_exists() {
    BUCKET_NAME=$1
    if ! /usr/bin/mc ls myminio/"${BUCKET_NAME}" > /dev/null 2>&1; then
        echo "Creating bucket: ${BUCKET_NAME}"
        /usr/bin/mc mb myminio/"${BUCKET_NAME}"
    else
        echo "Bucket ${BUCKET_NAME} already exists"
    fi
}

#!/bin/bash

apply_lifecycle_policy() {
    local DAYS=$1
    local BUCKET_NAME=$2
    local TEMPLATE_PATH="/scripts/lifecycle_deletion.json.template"
    local MODIFIED_POLICY_PATH="/scripts/lifecycle_policy.json"

    if [ -z "$DAYS" ] || [ -z "$BUCKET_NAME" ]; then
        echo "Usage: apply_lifecycle_policy <days> <bucket-name>"
        return 1
    fi
    echo "Setting lifecycle policy to expire objects in $BUCKET_NAME after $DAYS days."
    # Read the template file and replace the placeholder
    while IFS= read -r line || [ -n "$line" ]; do
        echo "${line//PLACEHOLDER_DAYS/$DAYS}"
    done < "$TEMPLATE_PATH" > "$MODIFIED_POLICY_PATH"

    # Apply the lifecycle policy to the bucket
    echo "/usr/bin/mc ilm import myminio/$BUCKET_NAME < $MODIFIED_POLICY_PATH"
    /usr/bin/mc ilm import myminio/"$BUCKET_NAME" < "$MODIFIED_POLICY_PATH"

    echo 'Bucket lifecycle policy configured.'

    # Optionally, remove the temporary modified policy file
    rm $MODIFIED_POLICY_PATH
}

# Check and create buckets as necessary
create_bucket_if_not_exists "raw-files"
create_bucket_if_not_exists "prepared-files"
create_bucket_if_not_exists "history-files"



# Setting a life cycle policy to raw-files bucket
echo "Adding lifecycle policy to buckets"
apply_lifecycle_policy 2 history-files
apply_lifecycle_policy 1 raw-files
echo 'Bucket notification configured.'

echo "Configuring amqp notifications"
# Apply configurations
/usr/bin/mc event add myminio/raw-files arn:minio:sqs::1:amqp --event put --suffix .json --prefix "simple"
/usr/bin/mc event add myminio/raw-files arn:minio:sqs::2:amqp --event put --suffix .xml

echo "AMQP notification configuration completed."
