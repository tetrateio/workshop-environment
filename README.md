# Workshop 101 Environment
Gitops Repo for building environment configurations for the [TSB 101 Workshop.](https://github.com/tetrateio/workshop-101).

## Prerequisites
- Tetrate Hosted TSB env linked to Tetrate PoC Azure AD.  [See this env for an example](https://github.com/tetrateio/tetrate/blob/master/cloud/projects/organization/configuration/index.ts#L139-L161)  The cluster names defined in TSB in the hosted environment will differ for every environment.  As such, you will need to rename the clusters in your kubernetes config context to match the consistent naming used in the workshop environment:  
**Azure Tier 1: tier1**  
**Azure East: cloud-a-01**  
**Azure West: cloud-a-02**   
**AWS East: cloud-b-01**  
To rename use kubectx:    
```bash  
kubectx tier1=<AZURE_TIER1_CLUSTER_NAME>  
kubectx cloud-a-01=<AZURE_EAST_CLUSTER_NAME>  
kubectx cloud-a-02=<AZURE_WEST_CLUSTER_NAME>  
kubectx cloud-b-01=<AWS_EAST_CLUSTER_NAME>  
```

- Import Users/Groups into AD.  [See this worksheet for examples of how to do this](https://docs.google.com/spreadsheets/d/1l1hoYYM4VuMAAnS9s1cAETAP7kXPB41A9Az3C-iSCEQ/edit#gid=222245595)  You'll need to use the complete the user-import and group-import tabs and export as a CSV.  The output in Azure AD from importing users needs to be used as an input to group-import.
- Create Jumpboxes.  Use the [TSB-Workshop-Template](https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#LaunchTemplateDetails:launchTemplateId=lt-00618441ea7d113be) AWS Launch Template for creating the jumpboxes.
- Complete the `Attendee List` sheet in the the Google Worksheet from step one.  Export this as a CSV.

## Steps to Build Environment
- Clone & checkout the [Workshop-101](https://github.com/tetrateio/workshop-environment/tree/workshop-101) branch of Tetrate Workshop Environment repo.  
```bash
git clone git@github.com:tetrateio/workshop-environment.git --branch workshop-101
cd workshop-environment  
```

- Install tools
```bash
source ./scripts/install-tools.sh
```

- Bootstrap ArgoCD.  You must first set `ARGO_PWD` env variable.  It will be installed into the cluster your current kubeconfig is pointing to.  Typically this should be placed in your Tier1 Kubernetes Cluster.
```bash
export ARGO_PWD=mypassword
source ./scripts/bootstrap.sh
```

- Add each cluster to ArgoCD.  These command will add each workshop cluster as a deployment target in ArgoCD.  
```bash
source ./scripts/add-cluster-to-argo.sh tier1
source ./scripts/add-cluster-to-argo.sh cloud-a-01
source ./scripts/add-cluster-to-argo.sh cloud-a-02
source ./scripts/add-cluster-to-argo.sh cloud-b-01
```

- Configure Application(s) in ArgoCD:
```bash
export BASE64_GCP_JSON_CRED=$(cat <PATH-TO-GCP-JSON-CREDENTIAL> | base64)
# Tier1
argocd app create tier1-app-of-apps \
  --repo https://github.com/tetrateio/workshop-environment \
  --revision workshop-101 \
  --dest-name in-cluster \
  --label cluster=tier1 \
  --sync-policy automated \
  --path cd/clusters/tier1 \
  --helm-set gcpJsonCredential=$BASE64_GCP_JSON_CRED
# Cloud A 01
argocd app create cloud-a-01-app-of-apps \
  --repo https://github.com/tetrateio/workshop-environment \
  --revision workshop-101 \
  --dest-name in-cluster \
  --label cluster=cloud-a-01 \
  --sync-policy automated \
  --path cd/clusters/cloud-a-01 \
  --helm-set gcpJsonCredential=$BASE64_GCP_JSON_CRED
# Cloud A 02
argocd app create cloud-a-02-app-of-apps \
  --repo https://github.com/tetrateio/workshop-environment \
  --revision workshop-101 \
  --dest-name in-cluster \
  --label cluster=cloud-a-02 \
  --sync-policy automated \
  --path cd/clusters/cloud-a-02 \
  --helm-set gcpJsonCredential=$BASE64_GCP_JSON_CRED
# Cloud B 01
argocd app create cloud-b-01-app-of-apps \
  --repo https://github.com/tetrateio/workshop-environment \
  --revision workshop-101 \
  --dest-name in-cluster \
  --label cluster=cloud-b-01 \
  --sync-policy automated \
  --path cd/clusters/cloud-b-01 \
  --helm-set gcpJsonCredential=$BASE64_GCP_JSON_CRED
```

- Prepare Jumpboxes, Tenants, etc by executing the script: [scripts/prepare-user-env.sh](scripts/prepare-user-env.sh).  To execute this script you'll need a few env vars set:  
```bash
export KUBE_CONFIG=<PATH TO KUBECONFIG FILE FOR JUMPBOXES>
export AWS_PEM=<PATH TO TSB WORKSHOP AWS PEM>
```
```bash
source scripts/prepare-user-env.sh <PATH_TO_ATTENDEE_CSV>
```

## Misc Notes & TODOs
- Tetrate org is assumed to be `workshop`.  If different this needs to be updated in `scripts/tenant.yaml` as well a large number of YAML files in the workshop labs.
- TSB MP Address is set in the cloud-init for the launch template.  May need to be updated.  This is also hardcoded in a few places in the workshop steps
- TSB Cluster name mappings (e.g. cloud-a-01 == SOME_TSB_CLUSTER_NAME) is set in the cloud-init for the launch template.  This will need to be updated as different TSB HOsted environments are used.