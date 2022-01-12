#!/usr/bin/env bash
echo "******************************"
echo "Bootstrapping Mgmt Cluster"
echo "******************************"
: ${ARGO_PWD?"Need to set ARGO_PWD environment variable"}

#Install ArgoCD
kubectl create ns argocd
helm repo add argo https://argoproj.github.io/argo-helm
echo "argopwd: $ARGO_PWD"
export ARGO_PWD_ENCODE=$(htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/')
echo "argopwd encoded: $ARGO_PWD_ENCODE"
helm install argocd argo/argo-cd -f helm-values/argocd-values.yaml -n argocd \
     --set configs.secret.argocdServerAdminPassword=$ARGO_PWD_ENCODE 
while kubectl get po -n argocd -l app.kubernetes.io/component=server | grep Running | wc -l | grep 1 ; [ $? -ne 0 ]; do
    echo ArgoCD Not Running
    sleep 5
done
while kubectl get svc argocd-server -n argocd | grep pending | wc -l | grep 0 ; [ $? -ne 0 ]; do
    echo ArgoCD IP not assigned
    sleep 5
done
ARGO_IP=$(kubectl get svc argocd-server -n argocd -o json --output jsonpath='{.status.loadBalancer.ingress[0].ip}')  
echo "ArgoCD accessible via https://$ARGO_IP, admin/$ARGO_PWD"
argocd login $ARGO_IP --username admin --password $ARGO_PWD