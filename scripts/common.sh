#!/bin/bash
#
# Common setup for all servers (Control Plane and Nodes)

#sudo zypper rr http://download.opensuse.org/distribution/leap/15.2/repo/oss/
#sudo zypper rr http://download.opensuse.org/distribution/leap/15.2/repo/non-oss/
#sudo zypper rr http://download.opensuse.org/update/leap/15.2/oss/
#sudo zypper rr http://download.opensuse.org/update/leap/15.2/non-oss/
#
#sudo zypper ar --refresh https://download.opensuse.org/distribution/leap/15.4/repo/oss/ leap154-oss
#sudo zypper ar --refresh https://download.opensuse.org/distribution/leap/15.4/repo/non-oss/ leap154-non-oss
#sudo zypper ar --refresh https://download.opensuse.org/update/leap/15.4/oss/ leap154-update-oss
#sudo zypper ar --refresh https://download.opensuse.org/update/leap/15.4/non-oss/ leap154-update-non-oss
#sudo zypper --gpg-auto-import-keys refresh


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

#sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_15.5 snappy
#sudo zypper --gpg-auto-import-keys refresh
#sudo zypper dup --from snappy
#sudo zypper install -y snapd
#sudo systemctl enable --now snapd
#sudo systemctl enable --now snapd.apparmor
#
#sudo snap install kubelet --classic
#sudo snap install kubeadm --classic
#sudo snap install kubectl --classic

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


#sudo zypper ar --refresh https://download.opensuse.org/tumbleweed/repo/oss/ tumbleweed-oss
#sudo zypper --gpg-auto-import-keys refresh
#
#sudo zypper install -y conntrack-tools
#sudo zypper install -y containerd
#sudo zypper install -y cri-o
#sudo zypper install -y --no-recommends kubernetes1.28-kubelet
#sudo zypper install -y --no-recommends kubernetes1.28-kubeadm
#sudo zypper install -y --no-recommends kubernetes1.28-client






#enable the kubelet service started on boot
sudo systemctl enable kubelet.service






#sudo zypper install -y firewalld
#
#sudo systemctl enable firewalld
#sudo systemctl start firewalld

#sudo firewall-cmd --query-port=6443/tcp

#add port in the firewall rules
#sudo firewall-cmd --permanent --zone=public --add-port=6443/tcp
#
#sudo systemctl reload firewalld


