#!/bin/bash

KUBESPRAY_VERSION="2.23.0"

if [ ! -d kubespray ]; then
  echo "Clone kubespray repo ..."
  git clone -q git@github.com:kubernetes-sigs/kubespray.git
  cd kubespray || (echo "Folder kubespray does not exist." && exit 1)
  git checkout -q "v$KUBESPRAY_VERSION"

  pipenv install -q -r requirements.txt

  echo "Init inventory ..."
  cp -rfp inventory/sample inventory/vagrant
  declare -a IPS=(192.168.56.101 192.168.56.102 192.168.56.103 192.168.56.111 192.168.56.112 192.168.56.113)
  DEBUG=false CONFIG_FILE=inventory/vagrant/hosts.yaml pipenv run python3 contrib/inventory_builder/inventory.py "${IPS[@]}"
  cp -r ../kubespray-override/* .

  # Cluster name
  echo "Change cluster name ..."
  sed -i "s/^cluster_name:.*/cluster_name: vagrant.local/g" inventory/vagrant/group_vars/k8s_cluster/k8s-cluster.yml

  # DNS
  echo "Setup DNS ..."
  sed -i "s/^\#\{0,1\}\s*upstream_dns_servers:.*/upstream_dns_servers: ['1.1.1.2']/g" inventory/vagrant/group_vars/all/all.yml

  # Read-only port for Kubelet
  echo "Enable read-only port ..."
  sed -i "s/^# kube_read_only_port:\(.*\)/kube_read_only_port:\1/g" inventory/vagrant/group_vars/all/all.yml

  # Flannel configuration
  echo "Enable flannel ..."
  sed -i "s/^kube_network_plugin:.*/kube_network_plugin: flannel/g" inventory/vagrant/group_vars/k8s_cluster/k8s-cluster.yml
  sed -i "s/^\#\{0,1\}\s*flannel_interface:.*/flannel_interface: eth1/g" inventory/vagrant/group_vars/k8s_cluster/k8s-net-flannel.yml

  # Kube-vip
  echo "Setup kube proxy strict arp for kube-vip"
  sed -i "s/^\#\{0,1\}\s*kube_proxy_strict_arp:.*/kube_proxy_strict_arp: true/g" inventory/vagrant/group_vars/k8s_cluster/k8s-cluster.yml

  # Metrics Server
  echo "Enable metrics server ..."
  sed -i "s/^\#\{0,1\}\s*metrics_server_enabled:.*/metrics_server_enabled: true/g" inventory/vagrant/group_vars/k8s_cluster/addons.yml
  sed -i "s/^m\#\{0,1\}\s*metrics_server_kubelet_insecure_tls:.*/metrics_server_kubelet_insecure_tls: true/g" inventory/vagrant/group_vars/k8s_cluster/addons.yml
  sed -i "s/^m\#\{0,1\}\s*metrics_server_kubelet_preferred_address_types:.*/metrics_server_kubelet_preferred_address_types: "InternalIP"/g" inventory/vagrant/group_vars/k8s_cluster/addons.yml
  sed -i "s/^m\#\{0,1\}\s*metrics_server_host_network:.*/metrics_server_host_network: true/g" inventory/vagrant/group_vars/k8s_cluster/addons.yml

  # Ingress nginx
  echo "Enable ingress nginx ..."
  sed -i "s/^\#\{0,1\}\s*ingress_nginx_enabled:.*/ingress_nginx_enabled: true/g" inventory/vagrant/group_vars/k8s_cluster/addons.yml
  sed -i "s/^\#\{0,1\}\s*ingress_nginx_host_network:.*/ingress_nginx_host_network: true/g" inventory/vagrant/group_vars/k8s_cluster/addons.yml
  sed -i "s/^\#\{0,1\}\s*ingress_nginx_nodeselector:.*/ingress_nginx_nodeselector:/g" inventory/vagrant/group_vars/k8s_cluster/addons.yml
  sed -i "s/^\#\{0,1\}\s*kubernetes.io\/os:.*/kubernetes.io\/os: \"linux\"/g" inventory/vagrant/group_vars/k8s_cluster/addons.yml
  sed -i "s/^\#\{0,1\}\s*ingress_nginx_namespace:.*/ingress_nginx_namespace: ingress-nginx/g" inventory/vagrant/group_vars/k8s_cluster/addons.yml
  sed -i "s/^\#\{0,1\}\s*ingress_nginx_insecure_port:.*/ingress_nginx_insecure_port: 80/g" inventory/vagrant/group_vars/k8s_cluster/addons.yml
  sed -i "s/^\#\{0,1\}\s*ingress_nginx_secure_port:.*/ingress_nginx_secure_port: 443/g" inventory/vagrant/group_vars/k8s_cluster/addons.yml
else
  echo "Folder kubespray already exists. Nothing to do."
  exit 0
fi
