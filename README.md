# Objectives

The objective is to complete all task sent by Rockstage, which is on [Rock Stage SRE Assessment
](https://github.com/Pehesi97/rockstage-sre-assessment).

# Prerequisites

These elements are necessary to proceed with our Wordpress Stack:

- kubectl
- kind
- docker

Docker Desktop Resources:
- Recommended:
  - CPUs: 5
  - Memory: 5
  - Swap: 1
  - Disk image size: 20 Gb

- Minimum:
  - CPUs: 3
  - Memory: 3
  - Swap: 1
  - Disk image size: 20 Gb
  
  Sometimes, you can face some errors about insufficient resources. Example:
```
  Warning  FailedScheduling  76s (x2 over 77s)  default-scheduler  0/1 nodes are available: 1 Insufficient cpu.
```
# Definitions


## Kubernetes in Docker (KIND)
___

Kind is a tool for running local Kubernetes clusters using Docker container “nodes”.

## Port-forwarding
___

The port-forward command will expose applications URLs locally. I created a Makefile command to do that. In a real scenario we could expose via Load Balancer and Ingress Controller, for example.
## Secrets
___

I declared secrets on kustomization files, with the objective to become easy to run this stack. It is important to know that IS NOT a good practice stored the as plain/text on git. In a production environment, we should adopt some secrets management solutions, for example HashiCorp Vault.

## MySQL Database
___

I configured 1 MySQL Server, which I created 3 databases for 3 customers: bakery, petshop e supermarket.

## Populating MySQL Databases
___

The database will be populated right after Wordpress Customer Site being created. At that moment, there is a Init Container (init-mysql) which will handle it. There is a schema template that I use to input customer variables and create it.

## Prometheus
___

Prometheus operator was my choice to expose metrics. With that solution you can check some metrics for example cluster, workloads, cpu, memory,etc.
I decided to not persist data in database or volumes, because it is an experimental environment. If a Grafana/Prometheus Pod is restarted, you will loose your data.

- Grafana User: admin
- Grafana User: admin
## Wordpress Environments
___

### Strategy

I adopted a strategy which customer information are persisted in 3 files on each project:

$WORDPRESS_REPO/projects/rockstage/<customer>/configmap-wordpress.yaml
$WORDPRESS_REPO/projects/rockstage/<customer>/namespace.yaml
$WORDPRESS_REPO/projects/rockstage/<customer>/kustomization.yaml.yaml

Cloning **$WORDPRESS_REPO/projects/rockstage/<customer>** and change those files above with customer information, you will be a new environment.

| WORDPRESS_DB_NAME | bakery | petshop | supermarket |
|-|-|-|-|
| WORDPRESS_DB_USER | bakery | petshop | supermarket |
| WORDPRESS_DB_PASSWORD | Bakery202020 | Petshop202020 | Supermarket202020 |
| SITE_URL | http://localhost:8070 | http://localhost:8080 | http://localhost:8090 |
| PHPMYADMIN URL | http://localhost:8071 | http://localhost:8081 | http://localhost:8091 |
| ADMIN_EMAIL | bakery@bakery.com | petshop@petshop.com | supermarket@supermarket.com |
| BLOG_NAME (Wordpress User) | bakery-template | petshop-template | supermarket-template |

## Using Makefile
___

In order to improve your overall experience I created a Makefile to improve user experience, validating these task, I created a Makefile that is possible to create and validate all scenarios that I needed to do.

- make command:

```
bash$ make
help                           Displays this help message.
kind-create                    Create kind cluster
kind-delete                    Delete kind cluster
mysql-create                   Create MySQL Server
mysql-delete                   Delete MySQL Server
prometheus-create              Create Kube-Prometheus
prometheus-delete              Delete Kube-Prometheus
wp-petshop-create              Create petshop Environment
wp-petshop-delete              Delete petshop Environment
wp-bakery-create               Create bakery Environment
wp-bakery-delete               Delete bakery Environment
wp-supermarket-create          Create supermarket Environment
wp-supermarket-delete          Delete supermarket Environment
port-forward-bakery-on         Start port-forward bakery of Wordpress and PHPMyAdmin
port-forward-petshop-on        Start port-forward petshop of Wordpress and PHPMyAdmin
port-forward-supermarket-on    Start port-forward supermarket of Wordpress and PHPMyAdmin
port-forward-prometheus-on     Start port-forward Prometheus, Alert Manager e Grafana
port-forward-stop-all          Stop ALL port-forward supermarket of Wordpress and 
PHPMyAdmin
```

Behind the scenes, you can check all commands on Makefile.
# 1. Creating cluster 

We will use "kind" to create kubernetes cluster. We create a config file to do that, saving in cluster.yaml:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: rockstage
networking:
  ipFamily: ipv4
  apiServerAddress: 127.0.0.1
  apiServerPort: 6443
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
  disableDefaultCNI: true
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    listenAddress: "127.0.0.1"
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    listenAddress: "127.0.0.1"
    protocol: TCP

```

Command:
```
make kind-create 
```

# Deployments

## kube-prometheus
___

Command:
```
make prometheus-create 
```
## MySQL Server (make mysql-create)
___

Command:
```
make mysql-create  
```
## Wordpress bakery
___

Command:
```
make wp-bakery-create 
```
## Wordpress petshop
___

Command:
```
make wp-petshop-create 
```

## Wordpress supermarket
___

Command:
```
make wp-supermarket-create 
```
# Port-forwarding


## Start Port-forward
____

Following below, necessary commands to navigate by browser:

**make port-forward-bakery-on** : Start port-forward bakery of Wordpress and PHPMyAdmin

**make port-forward-petshop-on** : Start port-forward petshop of Wordpress and PHPMyAdmin

**make port-forward-supermarket-on** : Start port-forward supermarket of Wordpress and PHPMyAdmin

**make port-forward-prometheus-on** : Start port-forward Prometheus, Alert Manager e Grafana


## Stop Port-forwarding
________________
**make port-forward-stop-all** : Stop ALL port-forward supermarket of Wordpress and PHPMyAdmin

# References

- [kind - Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start)
- [Installing kubectl](https://kubernetes.io/docs/tasks/tools)
- [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus)
