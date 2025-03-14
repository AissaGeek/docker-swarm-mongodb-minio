# docker-swarm-mongodb-minio

Fully automated deployment of distributed MongoDB and MinIO across Docker Swarm workers

## Project Overview

This project provides Docker Compose configurations for setting up two modern, distributed services:
- **Distributed MinIO Cluster**: A scalable object storage solution.
- **MongoDB Replica Set**: A high-availability MongoDB deployment with an integrated web-based management tool.

Both configurations are designed for seamless deployment in a Docker Swarm environment.

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
  - [MinIO Distributed Cluster](#minio-distributed-cluster)
  - [MongoDB Replica Set](#mongodb-replica-set)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Features

### Distributed MinIO Cluster
- **Scalability**: Run multiple MinIO instances to achieve a distributed object storage system.
- **Health Checks**: Each container is monitored to ensure the service remains live.
- **Custom Entrypoint & Environment Configuration**: Easily configurable using external scripts and environment files.
- **Future Enhancements**: Planned integration with a reverse proxy for load balancing and centralized access.

### MongoDB Replica Set
- **High Availability**: Deploys a MongoDB replica set for data redundancy and automatic failover.
- **Security**: Uses key-based authentication for secure inter-node communication.
- **Administration**: Comes with a web-based Mongo Express dashboard for monitoring and managing the database.
- **Automated Initialization**: Includes scripts and mechanisms to set up replication quickly and effortlessly.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

Make sure your system meets the requirements for running multiple containers and that all necessary files and scripts are placed in the expected directories.

## Setup Instructions

### MinIO Distributed Cluster

1. **Configuration**  
   The setup includes multiple MinIO instances configured to work as a distributed cluster. The configuration injects custom environment variables and entrypoints to steer the container behavior.

2. **Running the Cluster**  
   Navigate to the directory containing the MinIO configuration file and run:
   
   ```bash
   docker-compose -f docker-compose-minio-distributed.yml up -d
   ```
   
   This command launches the MinIO containers in detached mode. One instance will expose the main port for accessing the dashboard, while additional ports are used for internal functionalities.

3. **Verification**  
   - Confirm container startup with `docker-compose ps`.
   - Check individual container logs if any issues arise.

### MongoDB Replica Set

1. **Configuration**  
   The MongoDB setup deploys a replica set with multiple nodes and includes a shared configuration for secure key-based authentication. An additional initialization container helps bootstrap the replica set and configures the Mongo Express interface.

2. **Running the Cluster**  
   In the directory with the MongoDB configurations, execute:
   
   ```bash
   docker-compose -f docker-compose-mongo-rs.yml up -d
   ```
   
   This command starts all MongoDB containers along with the Mongo Express dashboard accessible via a web browser.

3. **Verification**
   This command below allows to check if the cluster is healthy
   ```bash
   docker exec -it container-id  mongosh -u admin -p admin  --eval "rs.status()" |grep health 
   ```
   The output must be :
    ```commandline
      health: 1,
      health: 1,
      health: 1,
    ```
4. **Administration**  
   Once the containers are running, access Mongo Express through your browser for database management and monitoring.

## Usage

- **MinIO Dashboard**:  
  Access the MinIO management interface via `http://localhost:9000` (or the appropriate IP/port if deployed on a swarm cluster).

- **Mongo Express Dashboard**:  
  Open `http://localhost:8081` in your browser to interact with Mongo Express.

- **Container Management**:  
  To stop the services, run:

  ```bash
  docker-compose -f docker-compose-minio-distributed.yml down
  docker-compose -f docker-compose-mongo-rs.yml down
  ```

- **Logs and Diagnostics**:  
  Use `docker-compose logs [service_name]` to inspect the logs of any service.

## Troubleshooting

- **Startup Issues**  
  Ensure all necessary configuration files and scripts are in place, and that no other services are conflicting with the used ports.

- **Custom Adjustments**  
  Feel free to modify environment variables and volume mappings to fit your setup needs. Detailed changes are documented within the configuration files.

- **Additional Help**  
  Refer to the Docker and Docker Compose documentation for further assistance:
  - [Docker Documentation](https://docs.docker.com/)
  - [Docker Compose Documentation](https://docs.docker.com/compose/)

## License

This project is licensed under your chosen terms. See the LICENSE file for more information.