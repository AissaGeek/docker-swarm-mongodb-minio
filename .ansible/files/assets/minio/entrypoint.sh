#!/bin/bash
set -e
# Start MinIO with the dynamically configured FTP address
minio server --console-address :9001 http://minio{1...4}/minio-data \
    --ftp="address=${MINIO_FTP_EXTERNAL_IP}:${MINIO_FTP_PORT}" \
    --ftp="passive-port-range=${MINIO_FTP_PASV_RANGE}"