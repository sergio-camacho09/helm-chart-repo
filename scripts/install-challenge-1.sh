#!/bin/bash
# Preparing environment
echo "Preparing environment..."
./scripts/create-node-labels.sh
echo "Environment ready to use!"

# Let's install a random service (nginx) that will be used by ping's init container
echo "Installing random service..."
helm install nginx ./challenges/challenge-1/random-service/ -f ./challenges/challenge-1/random-service/values.yaml -n applications
echo "Random service installed!"
echo "Checking service status..."
echo "-----------------------------------------------------"
kubectl get pods -n applications
echo "-----------------------------------------------------"
echo "Installing ping service..."
helm install ping ./challenges/challenge-1/ping/ -f ./challenges/challenge-1/ping/values.yaml -n applications
echo "Ping service installed!"
echo "Checking service status..."
echo "-----------------------------------------------------"
kubectl get pods -n applications -o wide -w
