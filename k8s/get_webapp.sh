#!/bin/bash

echo "Trying to get service external IP and curl"

for i in {1..5}; do
  echo "Attempt $i..."

  EXTERNAL_IP=$(kubectl get svc webapp-svc -n webapp -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
  if [[ -z "$EXTERNAL_IP" ]]; then
    EXTERNAL_IP=$(kubectl get svc webapp-svc -n webapp -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
  fi

  if [[ -n "$EXTERNAL_IP" ]]; then
    echo "External IP found: $EXTERNAL_IP"
    if curl -sSf http://$EXTERNAL_IP; then
      echo "Service is healthy!"
      exit 0
    else
      echo "Health check failed."
    fi
  else
    echo "External IP not yet assigned."
  fi

  sleep 15
done

echo "Service is not healthy or external IP not available after 5 attempts."
exit 1