# deploy.sh

#!/bin/bash

echo "Starting Kubernetes deployment..."

# Apply secrets first
echo "Applying secrets..."
kubectl apply -f secrets/gmail-secret.yaml
kubectl apply -f secrets/mysql-secret.yaml

# Apply Redis deployment
echo "Deploying Redis..."
kubectl apply -f redis/redis-deployment.yaml

# Wait for Redis to be ready
echo "Waiting for Redis to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/redis

# Apply database manifests (if exists)
if [ -d "database" ]; then
    echo "Deploying database..."
    kubectl apply -f database/
    echo "Waiting for database to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/mysql
fi

# Apply CRUD API
if [ -d "crud-api" ]; then
    echo "Deploying CRUD API..."
    kubectl apply -f crud-api/migration-job.yaml
    kubectl apply -f crud-api/crud-api-manifest.yaml
    echo "Waiting for CRUD API to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/crud-api
fi

# Apply Email API
echo "Deploying Email API..."
kubectl apply -f email-api/email-api-manifest.yaml

# Wait for Email API to be ready
echo "Waiting for Email API to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/email-api
kubectl wait --for=condition=available --timeout=300s deployment/email-worker

# Apply Frontend
echo "Deploying Frontend..."
kubectl apply -f frontend/frontend-manifest.yaml

# Wait for Frontend to be ready
echo "Waiting for Frontend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend

# Apply networking manifests (if exists)
if [ -d "networking" ]; then
    echo "Applying networking configurations..."
    kubectl apply -f networking/
fi

echo "Deployment completed!"
echo "Checking pod status..."
kubectl get pods
echo ""
echo "Services:"
kubectl get services
