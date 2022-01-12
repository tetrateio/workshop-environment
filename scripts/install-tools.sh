#!/usr/bin/env bash
echo "******************************"
echo "Installing bootstrapping tools"
echo "******************************"

install_htpasswd(){
    #htpasswd
    echo "-- Installing htpasswd --"
    case "$1" in
        darwin) brew install httpd
           ;;
        linux) sudo apt install -y apache2-utils
           ;;
        *) echo "Unknown Platform"
           ;;
    esac

    if [ $? -ne 0 ]; then
        echo "Unable to install htpasswd"
        return 0
    else
        # Nothing, we're good
    fi
} 

install_helm(){
    #helm
    echo "-- Installing helm --"
    mkdir -p scratch
    curl -fsSL -o scratch/get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod 700 scratch/get_helm.sh
    ./scratch/get_helm.sh
    if [ $? -ne 0 ]; then
      echo "Unable to install helm"
      return 0
    else
        # Nothing, we're good
    fi
}

install_argocd(){
    #argocd
    echo "-- Installing argocd cli --"
    curl -fsSL -o scratch/argocd https://github.com/argoproj/argo-cd/releases/download/v2.2.2/argocd-$1-amd64
    chmod u+x scratch/argocd
    chmod o+x scratch/argocd
    sudo mv scratch/argocd /usr/local/bin/argocd 
    argocd version --client
    if [ $? -ne 0 ]; then
      echo "Unable to install ArgoCD"
      return 0
    else
        # Nothing, we're good
    fi
}

install_kubectx(){
    #kubectx
    echo "-- Installing kubectx --"
    case "$1" in
        darwin) brew install kubectx
           ;;
        linux) sudo apt install -y kubectx
           ;;
        *) echo "Unknown Platform"
           ;;
    esac

    if [ $? -ne 0 ]; then
        echo "Unable to install kubectx"
        return 0
    else
        # Nothing, we're good
    fi
} 


export PLATFORM=$(uname -a | head -n1 | awk '{print $1;}' | tr '[:upper:]' '[:lower:]')
install_htpasswd $PLATFORM
install_kubectx $PLATFORM
install_helm
install_argocd $PLATFORM