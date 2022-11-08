# PyData NYC 2022

This is a repository for [`Gentle introduction to scaling up ML service with Kubernetes + Mlflow`](https://nyc2022.pydata.org/cfp/talk/TTM9ZJ/) at PyData NYC 2022. 

## Contents

* How to set up a 3-node `K3s` cluster ([link](docs/k3s_installation.md))
* How to set up `Knative Serving` ([link](docs/knative_installation.md))
* How to set up `mlflow model registry` ([link](docs/mlflow_installation.md))
* Code for `test-app` ([link](test-app))

## Prerequisites

I recommend you to install the followings to run this repo

* `make` (Linux tool)
* `curl` (Linux tool)
* python virtual environment such as `conda`

## How to get started?

1. Create `.env` in the project root directory by filling variables in `.env.example`
1. Activate your virtual python environment such as `conda`
1. Set up a `K3s` instance by following [this tutorial](docs/k3s_installation.md)
1. Set up `mlflow model registry` by following [this tutorial](docs/mlflow_installation.md)
1. On the `K3s` control plane node, run `make namespaces && make secrets`. This sets up an environment for this demo in `K3s`. Make sure you follow the first step before you run this
1. Once `K3s` and `test-app` are ready, you can play with the followings
	* Create `deployment` by `kubectl apply -f kubernetes/deployment-demo.yaml`
	* Create `cluster IP` by `kubectl apply -f kubernetes/cluster-ip-demo.yaml`
	* Create `node port` by `kubectl apply -f kubernetes/node-port-demo.yaml`
	* Create `load balancer` by `kubectl apply -f kubernetes/load-balancer-demo.yaml`
1. Optionally, set up a `Knative` instance by following [this tutorial](docs/knative_installation.md)
1. Create `Knative` service for `test-app` by `kubectl apply -f kubernetes/knative-demo.yaml`
1. Once everything is done, clean all components you created in this demo by running `make clean` on the `K3s` control plane node
1. For more information, run `make help`

