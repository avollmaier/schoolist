#!/bin/sh

echo "\n🏴️ Destroying Kubernetes cluster...\n"

minikube stop --profile schoolist

minikube delete  --profile schoolist

echo "\n🏴️ Cluster destroyed\n"
