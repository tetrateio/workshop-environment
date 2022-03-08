#!/usr/bin/env bash
: ${KUBE_CONFIG?"KUBE_CONFIG environment variable not set.  This points to kubeconfig that will be uploaded to jumpboxes"}
: ${AWS_PEM?"AWS_PEM environment variable not set.  This is used to scp into jumpboxes"}
: ${1?"Must supply attendee CSV path as an argument"}

FOO_NO_WHITESPACE="$(echo -e "${FOO}" | tr -d '[:space:]')"
while IFS="," read -r ATTENDEE ATTENDEE_EMAIL AD_EMAIL AD_UID PREFIX JUMPBOX_IP READY
do
  export READY_TRIMMED="$(echo -e "${READY}" | tr -d '[:space:]')"
  if [[ $READY_TRIMMED == "Yes" ]]; then
    echo "Attendee: $ATTENDEE"
    echo "Attendee Email: $ATTENDEE_EMAIL"
    echo "Azure AD Email: $AD_EMAIL"
    echo "Azure AZ UID: $AD_UID"
    echo "Env Prefix: $PREFIX"
    echo "Jumpbox: $JUMPBOX_IP"

    # Upload Kubeconfig
    scp -i $AWS_PEM -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $KUBE_CONFIG ec2-user@$JUMPBOX_IP:~/.kube/

    # Prepare PREFIX
    echo "export PREFIX=$PREFIX" > /tmp/VARS
    scp -i $AWS_PEM -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/VARS ec2-user@$JUMPBOX_IP:~/
    ssh -n -i $AWS_PEM -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$JUMPBOX_IP 'cat VARS >> ~/.bash_profile'

    # Prepare Tenant & User Access
    PREFIX=$PREFIX AD_UID=$AD_UID envsubst < scripts/tenant.yaml | tctl apply -f -

  else
    echo "Skipping env for attendee: $ATTENDEE.  Not Ready"
  fi 
done < <(tail -n +2 $1)
