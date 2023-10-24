#!/bin/bash
#
# Common setup for all servers (Control Plane and Nodes)

sudo zypper update
sudo zypper refresh

#ensure the swap is disable
sudo swapoff -a
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

sudo zypper install -y docker
#enable the docker service started on boot
sudo systemctl enable docker
sudo systemctl start docker

sudo docker ps

sudo zypper install -y jq


sudo zypper install -y conntrack-tools
sudo zypper install -y cri-o
sudo systemctl enable crio.service

export local_ip="$(ip --json a s | jq -r '.[] | if .ifname == "eth1" then .addr_info[] | if .family == "inet" then .local else empty end else empty end')"
sudo -E bash -c 'cat > /etc/default/kubelet << EOF
KUBELET_EXTRA_ARGS=--node-ip=$local_ip
${ENVIRONMENT}
EOF'

sudo zypper install -y kubernetes1.20-kubelet
sudo zypper install -y kubernetes1.20-kubeadm
sudo zypper install -y kubernetes1.20-client


#enable the kubelet service started on boot
sudo systemctl enable kubelet.service

