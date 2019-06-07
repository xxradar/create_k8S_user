#!/bin/bash
echo "################################################################"
echo "### ./create_user <USERNAME> <NAMESPACE>      ##################"
echo "################################################################"
kubectl create namespace $2
openssl genrsa -out $1.key 2048
openssl req -new -key $1.key -out $1.csr -subj "/CN=$1/O=bitnami"
openssl x509 -req -in $1.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out $1.crt -days 500
kubectl config set-credentials $1 --client-certificate=./$1.crt  --client-key=./$1.key
kubectl config set-context $1-context --cluster=kubernetes --namespace=$2 --user=$1
kubectl --context=$1-context get pods
cat role-deployment-manager.yaml.template  | sed "s/MY_NAMESPACE/$2/g" | sed "s/MY_USER/$1/g" >./role-deployment-manager.yaml
kubectl create -f role-deployment-manager.yaml
cat rolebinding-deployment-manager.yaml.template  | sed "s/MY_NAMESPACE/$2/g" | sed "s/MY_USER/$1/g" >./rolebinding-deployment-manager.yaml
kubectl create -f rolebinding-deployment-manager.yaml
kubectl --context=$1-context run --image bitnami/dokuwiki mydokuwiki
kubectl --context=$1-context get pods
kubectl --context=$1-context get pods --namespace=$2

