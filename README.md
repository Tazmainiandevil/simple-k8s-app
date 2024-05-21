# simple-k8s-app
A simple application deployment


## Infrastructure

The infrastructure folder contains the terraform code to deploy an AKS cluster, Virtual Network, Log Analytics and Container Registry. The AKS cluster is split into 2 node pools, the system node pool so this can be isolated from day to day applications, independently scale and be right sized for the system and the apps node pool which can scaled for the application needs and allows the application nodes to be right sized.

The apps node pool has a label that is used in the helm chart to select the node when deploying.

## Build container

Login to the Azure Container Registry with the Azure CLI

```PowerShell
az acr login -n monolithacrdevweu
```

Build the image and push to the Azure Container Registry

```PowerShell
docker build -f src/simple-app/Dockerfile -t monolithacrdevweu.azurecr.io/simple-app:v1.0 --target base .

docker push monolithacrdevweu.azurecr.io/simple-app:v1.0
```

## Helm

Get Credentials

```PowerShell
az aks get-credentials -g rg-aks-dev-weu -n monolith-aks-dev-weu
```

Install the application to AKS using Helm

```PowerShell
helm install simple-app chart/simple-app --create-namespace --namespace apps
```

## Scaling 

In order to scale to 10k requests per second there are a number of things to consider, firstly is the node size, getting the right node size for the workloads has an impact on how many requests depending on workload, optimized nodes for memory/cpu need to be considered. Secondly using autoscalers, cluster auto scaler to increase the nodes in the cluster and horizontal pod scalers to automatically scale out the number of pods based on cpu/memory utilisation or custom metrics. KEDA is another technology that can be used to help scale out the pods.

Continuous monitoring with Azure monitor will be key to understanding the performance and monitoring the scaling

To scale your application to handle 10,000 requests per second, several key considerations:
1. Node Sizing: Choosing the appropriate node size for your workloads is critical. Optimised nodes for memory or CPU can significantly impact the number of requests your cluster can handle. Evaluating and selecting the appropriate VM sizes that match the applications requirements.
2. Autoscaling:
    - Cluster Autoscaler: Enable the cluster autoscaler to automatically adjust the number of nodes in your AKS cluster based on demand. This ensures that the cluster can scale up to accommodate high loads and scale down when demand decreases.
    - Horizontal Pod Autoscaler (HPA): Configure HPA to automatically scale the number of pod replicas based on CPU/memory utilization or custom metrics. This helps maintain performance by ensuring the right number of pods are running to handle the load.
    - KEDA (Kubernetes Event-Driven Autoscaling): Implement KEDA to further enhance pod scalability based on event-driven metrics.

3. Continuous Monitoring: Utilising observability tools like Azure Monitor to continuously monitor the performance and scaling of your application. Azure Monitor provides valuable insights into resource utilisation, performance bottlenecks, and scaling events, enabling you to make informed decisions and adjustments.

## Enhancements

Possible enhancements for the cluster configuration going forward

- Add Azure Entra ID configuration for cluster RBAC
- Add Azure Policy to control policies within the cluster
- Add Service Mesh to provide more security inside the cluster
- Add Azure Front Door as the entry point to the cluster services which provides a number of features including CDN