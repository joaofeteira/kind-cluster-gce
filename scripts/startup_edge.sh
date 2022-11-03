#! /bin/bash
apt update

# Install packages
sudo yum install -y git

# Install docker
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create the Kind K8s Cluster Config
cat <<EOF >> /tmp/cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF

# Create the Kind Cluster
kind create cluster --name edge --config /tmp/cluster.yaml --wait 1m



# # Post Steps
# sudo usermod -aG docker $USER
# logout / login
# kind export kubeconfig --name edge

# Install Multus
# git clone https://github.com/k8snetworkplumbingwg/multus-cni.git && cd multus-cni
# cat ./deployments/multus-daemonset-thick.yml | kubectl apply -f -