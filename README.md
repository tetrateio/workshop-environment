# Workshop 101 Environment
Gitops Repo for building environment configurations for the [TSB 101 Workshop.](https://github.com/tetrateio/workshop-101).

## Prerequisites
- Tetrate Hosted TSB env linked to Tetrate PoC Azure AD.  [See this env for an example](https://github.com/tetrateio/tetrate/blob/master/cloud/projects/organization/configuration/index.ts#L139-L161)  
The cluster names defined in TSB in the hosted environment will differ for every environment.  As such, you will need to rename the clusters in your kubernetes config context to match the consistent naming used in the workshop environment:  
| Hosted Cluster | Cloud | Region    | Workshop Cluster Name |  
|----------------|-------|-----------|-----------------------|  
| Azure Tier 1   | Azure | eastus2   | tier1                 |  
| Azure East     | Azure | eastus2   | cloud-a-01            |  
| Azure West     | Azure | westus2   | cloud-a-02            |  
| AWS East       | AWS   | us-east-2 | cloud-b-01            |  

- Import Users/Groups into AD.  [See this worksheet for examples of how to do this](https://docs.google.com/spreadsheets/d/1l1hoYYM4VuMAAnS9s1cAETAP7kXPB41A9Az3C-iSCEQ/edit#gid=222245595)
- Create Jumpboxes.  Use the [TSB-Workshop-Template](https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#LaunchTemplateDetails:launchTemplateId=lt-00618441ea7d113be) AWS Launch Template for creating the jumpboxes.
- Prepare Jumpboxes, Tenants, etc by executing the script in [scripts]()

## Steps to Build Environment
- Clone & checkout the [Workshop-101](https://github.com/tetrateio/workshop-environment/tree/workshop-101)a new branch (or fork) of Tetrate Workshop Environment repo.  
```bash
git clone git@github.com:tetrateio/workshop-environment.git --branch workshop-101
cd workshop-environment  
```

- Install tools
```bash
source ./scripts/install-tools.sh
```

- Bootstrap ArgoCD.  You must first set `ARGO_PWD` env variable.  It will be installed into the cluster your current kubeconfig is pointing to.
```bash
export ARGO_PWD=mypassword
source ./scripts/bootstrap.sh
```

- Add each cluster to ArgoCD.  This command will add the cluster in your current kubeconfig as a deployment target in ArgoCD.  Usually, you'll want to alias your cluster to a simple and readable name using `kubectx`.
```bash
kubectx <ALIAS>=$(kubectx -c)  # Note this may not be needed in your env if you have sensible names
source ./scripts/add-cluster-to-argo.sh
```

- Configure Application(s) in ArgoCD:
