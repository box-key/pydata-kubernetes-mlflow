# K3s set-up tutorial

This tutorial shows how to create a `K3s` instance with 3 VMs: one for the `control plane` and two for the `workers`. 

## What is K3s and why?

`K3s` is a lightweight distribution of `Kubernetes`. It's a certified Kubernetes distribution that requires much less resources to run. `K3s` comes with a single binary and simplifies the installation process. It is suitable for demo like this and can be used for production workloads

## How to install?

I use `Ubuntu 22.10` instances offered by `Digital Ocean` for this tutorial but this should work for other linux distrubitions and other environments.

1. Create the following instances on Digital Ocean:
    * One `1CPU/2GB Ubuntu 22.10` for the `Control Plane`
    * Two `1CPU/1GB Ubuntu 22.10` for the `Workers`
1. Go to the `Control Plane` node
1. Install and run the `k3s server` by `curl -sfL https://get.k3s.io | sh -`
1. Get token by `cat /var/lib/rancher/k3s/server/node-token`
1. Go to each worker node and do the following steps:
    1. Download `k3s` installer by `curl -sfL https://get.k3s.io/ >> k3s_install.sh`
    1. Run `k3s agent` by `INSTALL_K3S_EXEC="agent --server https://<control-plane-ip>:6443 --token <mytoken> --with-node-id" sh k3s_install.sh`, where `<mytoken>` is the token you obtained on the `Control Plane`
1. Go to the `Control Plane` and run `kubectl get node -o wide`. If it prints 3 nodes, your installation is done!

## How to test?
After the installation is complete, you can test your `k3s` instance by the following

1. Run test `deployment` by `kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4`
1. Increase the number of `replicasets` by `kubectl scale deployment/hello-node --replicas=3`
1. Create a `cluster IP` for the deployment by `kubectl expose deploy hello-node --type=ClusterIP --port=8080`
1. Get cluster IP address by `kubectl get services`
1. Send a http request to the cluster IP. E.g., `curl http://<cluster-ip>:8080`. If your cluster is configured correctly, you should see something like the following:
```bash
CLIENT VALUES:
client_address=10.42.0.0
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://10.43.226.160:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=10.43.226.160:8080
user-agent=curl/7.85.0
BODY:
-no body in request-
```