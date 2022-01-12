# Workshop Environments
Baseline Gitops Repo for building environment configurations

## Prerequisites
TSB MP
Existing workload clusters
Props filled out & checked in

## Steps to Build Environment
- source ./scripts/install-tools.sh
- (target mgmt/tier1 cluster) must set: ARGO_PWD=SOME_VALUE... then source ./scripts/bootstrap.sh
- alias kubectl context for more readable name in argo: kubectx <ALIAS>=<CURRENT_CONTEXT_NAME>.. e.g. `kx tier1=gke_abz-workshop-test_us-east4_tier1`  
- Create & Add k8s service account for argo access & add cluster to argo:  ./scripts/add-cluster-to-argo.sh

- Edit (and checkin) YAML files for gitops env build (Props with # EDIT ME comment)
- Configure Application in ArgoCD
-- gcp json is base64 encoded