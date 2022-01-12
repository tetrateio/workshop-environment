#! /bin/bash
set -x

tctl_login(){
    echo "Logging into TSB mgmt cluster..."
    tctl config clusters set default --bridge-address $1
    tctl login --org $4 --tenant something --username $2 --password $3
    sleep 3
    tctl get Clusters
}

cluster_prepare_secrets(){
    echo "Installing MP Cluster Secrets..."
    tctl install manifest control-plane-secrets \
      --cluster $1 | kubectl apply -n istio-system -f -
}

cluster_prepare(){
    echo "Installing Cluster into Mgmt Plane..."
    tctl apply -f /etc/tsb/cluster.yaml
}

check_cluster_registration(){
    echo "Verifying if cluster has already been registered"
    check=$(tctl get cluster $1 ) 
    if [ $? -eq 0 ]; then
      echo "Cluster registered, nothing to do..."
      exit 0
    else
        echo "Cluster not yet registered"
    fi
}

export TSB_URL_HOST=$(yq eval .tsb.host /etc/tsb/tsb-props.yaml)
export TSB_URL_PORT=$(yq eval .tsb.port /etc/tsb/tsb-props.yaml)
export TSB_USER=$(yq eval .tsb.user /etc/tsb/tsb-props.yaml)
export TSB_PWD=$(yq eval .tsb.pwd /etc/tsb/tsb-props.yaml)
export TSB_ORG=$(yq eval .tsb.org /etc/tsb/tsb-props.yaml)
export CLUSTER_NAME=$(yq eval .clusterName /etc/tsb/tsb-props.yaml)
tctl_login $TSB_URL_HOST:$TSB_URL_PORT $TSB_USER $TSB_PWD $TSB_ORG
tctl version

result=$(tctl get organizations $TSB_ORG )
if [ $? -eq 0 ]; then
    check_cluster_registration $CLUSTER_NAME
    cluster_prepare_secrets $CLUSTER_NAME
    if [ $? -eq 0 ]; then
        cluster_prepare
    else
        echo "Unable to generate cluster secrets"
    fi
else
    echo "TSB Login failed; possible tctl is not configured properly"
fi