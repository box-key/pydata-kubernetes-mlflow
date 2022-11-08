# Knative installation tutorial

This tutorial shows how to install `Knative` instance in your `Kubernetes` cluster. 

## Why and what is Knative?

`Knative` is a `Kubernetes` extension that enables us to create serverless applications on a `Kubernetes` instance. It simplifies service deployment process and comes with various handy features such as  `Autoscaling (even to zero)`, `Event Handler`, advanced routing capabilities and more.

## How to install?

The followings show how to install Knative version 1.6.0 in your `K3s` cluster, but it should work for other `Kubernetes` distributions

1. Install core `Knatvive` components
    * `kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.6.0/serving-crds.yaml`
    * `kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.6.0/serving-core.yaml`
    * `kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.6.0/kourier.yaml`
1. Configure `Knative Serving` to use `Kourier` (recommended by [their documentation](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/#install-a-networking-layer)) by 
```
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
```
1. By default, `K3s` uses `traefik` for ingress. Since `Kourier` is also an ingress service, this causes a port conflict between them. Thus, you need to delete `traefik` service, deployment and pods. Each component can be discovered by finding `traefik` namespace by `kubectl get namespaces` and delete each component in the namespace
1. Install `sslip.io` which generates a pseudo url for knative service by `kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.6.0/serving-default-domain.yaml`. Please check [their documentation](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/#configure-dns) for more details
1. If everything goes well, you should see `knative-serving` and `kourier-system` namespaces by `kubectl get namespace`


## How to test?

After the installation is complete, you can test your `Knative Serving` instance by the following

1. Save the following yaml file
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
spec:
  template:
    metadata:
      # This is the name of our new "Revision," it must follow the convention {service-name}-{revision-name}
      name: hello-world
    spec:
      containers:
        - image: gcr.io/knative-samples/helloworld-go
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "World"
```
1. Create the test component by `kubectl apply -f <path-to-yaml>`
1. Check the status of test servicec by `kubectl get ksvc hello`
1. Send a request by `curl $(kubectl get ksvc hello -o jsonpath='{.status.url}')`. If it's set up correctly, it prints `Hello World!`