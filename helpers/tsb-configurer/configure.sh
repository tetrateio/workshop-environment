#! /bin/bash
set -x

tctl_login(){
    echo "Logging into TSB mgmt cluster..."
    tctl config clusters set default --bridge-address $1
    tctl login --org $4 --tenant something --username $2 --password $3
    sleep 3
    tctl get Clusters
}

apply_config() {
    export REPO=$(yq eval .repo /etc/tsb/tsb-creds.yaml)
    export BRANCH=$(yq eval .branch /etc/tsb/tsb-creds.yaml)
    export REPOPATH=$(yq eval .path /etc/tsb/tsb-creds.yaml)
    if [ -d "/tmp/tsb/repo" ]; then
        cd /tmp/tsb/repo
        git pull
    else 
        git clone $REPO /tmp/tsb/repo
        cd /tmp/tsb/repo
        git checkout $BRANCH
    fi
    

    echo "Applying TSB config:"
    tree /tmp/tsb/repo/$REPOPATH
    tctl apply -f /tmp/tsb/repo/$REPOPATH   
}

export TSB_URL_HOST=$(yq eval .tsb.host /etc/tsb/tsb-creds.yaml)
export TSB_URL_PORT=$(yq eval .tsb.port /etc/tsb/tsb-creds.yaml)
export TSB_USER=$(yq eval .tsb.user /etc/tsb/tsb-creds.yaml)
export TSB_PWD=$(yq eval .tsb.pwd /etc/tsb/tsb-creds.yaml)
export TSB_ORG=$(yq eval .tsb.org /etc/tsb/tsb-creds.yaml)
tctl_login $TSB_URL_HOST:$TSB_URL_PORT $TSB_USER $TSB_PWD $TSB_ORG
tctl version

result=$(tctl get organizations $TSB_ORG )
if [ $? -eq 0 ]; then
    echo "****** TSB Logged in ******"
    while [ true ]
    do
        apply_config
        sleep 5
    done
else
    echo "TSB Login failed; possible tctl is not configured properly"
fi