#!/bin/bash
#
# Setup for Control Plane (Master) servers

sudo env "PATH=$PATH" kubeadm init --kubernetes-version=1.20.13 \
    --apiserver-advertise-address=$CONTROL_IP \
    --apiserver-cert-extra-sans=$CONTROL_IP \
    --image-repository registry.aliyuncs.com/google_containers \
    --service-cidr=$SERVICE_CIDR \
    --pod-network-cidr=$POD_CIDR \
    --node-name "$NODENAME" --ignore-preflight-errors Swap

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

config_path="/vagrant/configs"

if [ -d $config_path ]; then
  rm -f $config_path/*
else
  mkdir -p $config_path
fi

cp -i /etc/kubernetes/admin.conf $config_path/config
touch $config_path/join.sh
chmod +x $config_path/join.sh

kubeadm token create --print-join-command > $config_path/join.sh


kubectl create -f https://projectcalico.docs.tigera.io/archive/v3.22/manifests/tigera-operator.yaml
curl https://projectcalico.docs.tigera.io/archive/v3.22/manifests/custom-resources.yaml -O
sed -i -e 's|192.168.0.0/16|172.16.0.0/16|g' custom-resources.yaml
kubectl apply -f custom-resources.yaml


sudo -i -u vagrant bash << EOF
whoami
mkdir -p /home/vagrant/.kube
sudo cp -i $config_path/config /home/vagrant/.kube/
sudo chown 1000:1000 /home/vagrant/.kube/config
EOF

kubectl get pods --all-namespaces
