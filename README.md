# Workshop Environments
Baseline Gitops Repo for building environment configurations

## Prerequisites
TSB MP
Existing workload clusters
Props filled out & checked in

## Steps to Build Environment
todo... be more verbose

- Install tools
```bash
source ./scripts/install-tools.sh
```

- Bootstrap ArgoCD.  You must first set `ARGO_PWD` env variable.  It will be installed into cluster your current kubeconfig is pointing to.
```bash
export ARGO_PWD=mypassword
source ./scripts/bootstrap.sh
```

- Add cluster to ArgoCD.  This command will add the cluster in your current kubeconfig as a deployment target in ArgoCD.  Usually, you'll want to alias your cluster to a simple and readable name using `kubectx`.
```bash
kubectx <ALIAS>=$(kubectx -c)  # Note this may not be needed in your env
source ./scripts/add-cluster-to-argo.sh
```

- Create & checkout a new branch of Tetrate Workshop Environment repo.  
```bash
git clone https://github.com/tetrateio/workshop-environment --branch <BRANCH_NAME>
```

- Edit your env config templates.  You'll want to create your env configs and templates in the `/cd/clusters` directory.  There are examples in `/cd/example-clusters`.

- Configure Application in ArgoCD using the Web UI.