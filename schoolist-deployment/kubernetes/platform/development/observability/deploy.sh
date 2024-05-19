#!/bin/sh


echo "\n🔭  Observability stack deployment started.\n"

kubectl apply -f resources/namespace.yml

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "\n📦 Installing Tempo..."

helm upgrade --install tempo --namespace=observability-stack grafana/tempo \
  --values helm/tempo-values.yml

echo "\n⌛ Waiting for Tempo to be ready..."

while [ $(kubectl get pod -l app.kubernetes.io/name=tempo -n observability-stack | wc -l) -eq 0 ] ; do
  sleep 5
done

kubectl wait \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=tempo \
  --timeout=360s \
  --namespace=observability-stack

echo "\n📦 Installing Grafana, Loki, Prometheus, and Fluent Bit..."

kubectl apply -f resources/dashboards

helm upgrade --install loki-stack --namespace=observability-stack grafana/loki-stack \
  --values helm/loki-stack-values.yml

sleep 5

echo "\n⌛ Waiting for Fluent Bit to be ready..."

while [ $(kubectl get pod -l app=fluent-bit-loki -n observability-stack | wc -l) -eq 0 ] ; do
  sleep 5
done

kubectl wait \
  --for=condition=ready pod \
  --selector=app=fluent-bit-loki \
  --timeout=360s \
  --namespace=observability-stack

echo "\n⌛ Waiting for Prometheus to be ready..."

while [ $(kubectl get pod -l app=prometheus -n observability-stack | wc -l) -eq 0 ] ; do
  sleep 5
done

kubectl wait \
  --for=condition=ready pod \
  --selector=app=prometheus \
  --timeout=360s \
  --namespace=observability-stack

kubectl port-forward --namespace observability-stack service/loki-stack-prometheus-server 9090:9090 >/dev/null 2>&1 &

echo "\n⌛ Waiting for Loki to be ready..."

while [ $(kubectl get pod -l app=loki -n observability-stack | wc -l) -eq 0 ] ; do
  sleep 5
done

kubectl wait \
  --for=condition=ready pod \
  --selector=app=loki \
  --timeout=360s \
  --namespace=observability-stack

echo "\n⌛ Waiting for Grafana to be ready..."

while [ $(kubectl get pod -l app.kubernetes.io/name=grafana -n observability-stack | wc -l) -eq 0 ] ; do
  sleep 5
done

kubectl wait \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=grafana \
  --timeout=360s \
  --namespace=observability-stack

kubectl port-forward --namespace observability-stack service/loki-stack-grafana 3000:80 >/dev/null 2>&1 &

echo "\n✅  Grafana observability stack has been successfully deployed."

echo "\n🔐 Your Grafana admin credentials...\n"

echo "Admin Username: user"
echo "Admin Password: $(kubectl get secret --namespace observability-stack loki-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)"

echo "\n🔭  Observability stack deployment completed.\n"
