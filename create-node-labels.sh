#!/bin/bash

# Assign worker role to node01
echo "Assigning worker role to node01..."
kubectl label node node01 node-role.kubernetes.io/worker=worker
echo "Role assigned"

number=1
# Assign custom label to all nodes
echo "Getting all nodes..."
nodes=($(kubectl get nodes | awk '{if (NR!=1) {print $1}}'))

for node in "${nodes[@]}"; do
  echo "Assigning custom label to node $node..."
  kubectl label node $node kubernetes.io/test=node$number
  echo "Label assigned"
  number=$((number + 1))
done
