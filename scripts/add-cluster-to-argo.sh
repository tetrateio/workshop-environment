#!/usr/bin/env bash
kubectx $1
export CONTEXT=$(kubectl config current-context)
echo "Adding $CONTEXT cluster to ArgoCD"

kubectl create ns argocd #This is needed if we aren't in main cluster
kubectl create serviceaccount argocd -n argocd
kubectl create clusterrolebinding argocd --clusterrole=cluster-admin --serviceaccount=argocd:argocd
export TOKEN_SECRET=$(kubectl get serviceaccount -n argocd argocd -o jsonpath='{.secrets[0].name}')
export TOKEN=$(kubectl get secret -n argocd $TOKEN_SECRET -o jsonpath='{.data.token}' | base64 --decode)
kubectl config set-credentials $CONTEXT-argocd-token-user --token $TOKEN
kubectl config set-context $CONTEXT-argo \
  --user $CONTEXT-argocd-token-user \
  --cluster $(kubectl config get-contexts $CONTEXT --no-headers | awk '{print $3}')
argocd cluster add #Dump configs
argocd cluster add $CONTEXT-argo --name $CONTEXT
argocd cluster list 
kubectl config delete-context $CONTEXT-argo