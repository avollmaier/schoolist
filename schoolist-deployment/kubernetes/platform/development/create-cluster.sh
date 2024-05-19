#!/bin/sh

echo "\n📦 Initializing Kubernetes cluster...\n"

minikube start --cpus 16 --memory 12g --driver=podman --container-runtime=cri-o --profile schoolist --container-runtime=containerd --kubernetes-version=v1.30

echo "\n📦 Deploying platform services..."

kubectl apply -f services

while true; do
    read -p "📦 Deploy observability stack? (y/n)" yn
    case $yn in
        [Yy]* ) chmod +x ./observability/deploy.sh;cd observability;./deploy.sh;echo "Observability stack deployed successfully!";break;;
        [Nn]* ) echo "Observability stack deployment canceled.";exit;;
        * ) echo "Please answer yes or no.";;
    esac
done


echo "\n⛵ Happy Sailing!\n"