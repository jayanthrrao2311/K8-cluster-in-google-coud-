      creating a K8s cluster using VM's in GCP

     create a vm instance of configuration (E2 , medium , ubuntu 22.04 , allow http)

      open SSH and execute the commands 



      master node creation  

1) Download the GPG key for docker

     wget -O - https://download.docker.com/linux/ubuntu/gpg > ./docker.key

     gpg --no-default-keyring --keyring ./docker.gpg --import ./docker.key

     gpg --no-default-keyring --keyring ./docker.gpg --export > ./docker-archive-keyring.gpg

     sudo mv ./docker-archive-keyring.gpg /etc/apt/trusted.gpg.d/ 

2). Add the docker repository and install docker
   
     sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
     sudo apt update
     sudo apt install git wget curl -y
     sudo apt install -y docker-ce

note : To install cri-dockerd for Docker support

Docker Engine does not implement the CRI which is a requirement for a container runtime to work with Kubernetes. For that reason, an additional service cri-dockerd has to be installed. cri-dockerd is a project based on the legacy built-in Docker Engine support that was removed from the kubelet in version 1.24.



3). Get the version details

     VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4|sed 's/v//g')

4). 
     
     wget https://github.com/Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.amd64.tgz

      tar xvf cri-dockerd-${VER}.amd64.tgz

      sudo mv cri-dockerd/cri-dockerd /usr/local/bin/

       wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service

       wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket

       sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/

       sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service

       sudo systemctl daemon-reload
       sudo systemctl enable cri-docker.service
       sudo systemctl enable --now cri-docker.socket

5). Add the GPG key for kubernetes

    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

6). Add the kubernetes repository
    
     echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

7). Update the repositiries
    
     sudo apt-get update

8). Install Kubernetes packages.

     sudo apt-get install -y kubelet kubeadm kubectl

9). To hold the versions so that the versions will not get accidently upgraded.

      sudo apt-mark hold docker-ce kubelet kubeadm kubectl

10). Enable the iptables bridge

     cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
     overlay
     br_netfilter
     EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter


    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-iptables  = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    net.ipv4.ip_forward                 = 1
     EOF


    sudo sysctl --system

11).Initialize the cluster by passing the cidr value and the value will depend on the type of network CLI you choose.

       sudo kubeadm init --apiserver-advertise-address=<control_plane_ip> --cri-socket unix:///var/run/cri-dockerd.sock  --pod-network-cidr=10.244.0.0/16
      # Copy your join command and keep it safe

12). To start using the cluster with current user.

      mkdir -p $HOME/.kube
      sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
      sudo chown $(id -u):$(id -g) $HOME/.kube/config

13). To set up the Calico network

       # Use this if you have initialised the cluster with Calico network add on.
      kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml

14). Check the nodes

    kubectl get nodes




      worker node creation 	

  create a vm instance of configuration (E2 , medium , ubuntu 22.04 , allow http)

      open SSH and execute the commands 

 
1) Download the GPG key for docker

     wget -O - https://download.docker.com/linux/ubuntu/gpg > ./docker.key

     gpg --no-default-keyring --keyring ./docker.gpg --import ./docker.key

     gpg --no-default-keyring --keyring ./docker.gpg --export > ./docker-archive-keyring.gpg

     sudo mv ./docker-archive-keyring.gpg /etc/apt/trusted.gpg.d/ 

2). Add the docker repository and install docker
   
     sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
     sudo apt update
     sudo apt install git wget curl -y
     sudo apt install -y docker-ce

note : To install cri-dockerd for Docker support

Docker Engine does not implement the CRI which is a requirement for a container runtime to work with Kubernetes. For that reason, an additional service cri-dockerd has to be installed. cri-dockerd is a project based on the legacy built-in Docker Engine support that was removed from the kubelet in version 1.24.



3). Get the version details

     VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4|sed 's/v//g')

4). 
     
     wget https://github.com/Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.amd64.tgz

      tar xvf cri-dockerd-${VER}.amd64.tgz

      sudo mv cri-dockerd/cri-dockerd /usr/local/bin/

       wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service

       wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket

       sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/

       sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service

       sudo systemctl daemon-reload
       sudo systemctl enable cri-docker.service
       sudo systemctl enable --now cri-docker.socket

5). Add the GPG key for kubernetes

    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

6). Add the kubernetes repository
    
     echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

7). Update the repositiries
    
     sudo apt-get update

8). Install Kubernetes packages.

     sudo apt-get install -y kubelet kubeadm kubectl

9). To hold the versions so that the versions will not get accidently upgraded.

      sudo apt-mark hold docker-ce kubelet kubeadm kubectl

10). Enable the iptables bridge

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF


sudo sysctl --system

  11).  Joining the node to the cluster:

   sudo kubeadm join $controller_private_ip:6443 --token $token --discovery-token-ca-cert-hash $hash

note : if there is an error stating multiple sockets choose one  
	add this command to join command : --cri-socket unix:///var/run/cri-dockerd.sock 

eg : # kubeadm join <control_plane_ip>:6443 --cri-socket unix:///var/run/cri-dockerd.sock --token 31rvbl.znk703hbelja7qbx --discovery-token-ca-cert-hash sha256:3dd5f401d1c86be4axxxxxxxxxx61ce965f5xxxxxxxxxxf16cb29a89b96c97dd


12. If the joining code is lost, it can retrieve using below command 

    kubeadm token create --print-join-command