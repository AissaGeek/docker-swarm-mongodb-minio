#!/bin/bash
set -e
# Start MinIO with the dynamically configured FTP address
minio server --console-address :9001 \
             http://minio1/data \
             http://minio2/data \
             http://minio3/data \
             http://minio4/data \
    --ftp="address=${MINIO_FTP_EXTERNAL_IP}:${MINIO_FTP_PORT}" \
    --ftp="passive-port-range=${MINIO_FTP_PASV_RANGE}"