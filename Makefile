SHELL=/bin/bash

.PHONY: help
.DEFAULT_GOAL := help

help: ## Displays this help message.
	@awk 'BEGIN {FS = ":.?## "} /^[a-zA-Z_-]+:.?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

kind-create: ## Create kind cluster
	@echo "Installing kind cluster rockstage ..."
	kind create cluster --config=cluster/rockstage.yaml
	@sleep 10
	kubectl apply -f https://docs.projectcalico.org/v3.19/manifests/calico.yaml
	kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true
	kubectl -n kube-system get pods | grep calico-node

kind-delete: ## Delete kind cluster
	@echo "Deleting kind cluster rockstage ..."
	kind delete cluster --name rockstage

mysql-create: ## Create MySQL Server
	@echo "Creating MySQL Server..."
	kubectl apply -k projects/rockstage/wp-mysql/
	@echo "Waiting while MySQL is starting up..."
	@sleep 120
	@echo "Getting status"
	kubectl get all -n wp-mysql

mysql-delete: ## Delete MySQL Server
	@echo "Creating MySQL Server..."
	kubectl delete -k projects/rockstage/wp-mysql/

prometheus-create: ## Create Kube-Prometheus
	@echo "Creating Kube-Prometheus..."
	kubectl apply -k projects/rockstage/kube-prometheus/
	@echo "Waiting while Kube-Prometheus is starting up..."
	@echo "Getting status"
	kubectl get all -n monitoring

prometheus-delete: ## Delete Kube-Prometheus
	@echo "Deleting Kube-Prometheus..."
	kubectl delete -k projects/rockstage/kube-prometheus/

wp-petshop-create: ## Create petshop Environment
	@echo "Installing petshop customer..."
	kubectl apply -k projects/rockstage/petshop/
	@echo "Waiting while Wordpress is starting up..."
	@echo "Getting status"
	kubectl get all -n petshop

wp-petshop-delete: ## Delete petshop Environment
	@echo "Deleting petshop customer..."
	kubectl delete -k projects/rockstage/petshop/

wp-bakery-create: ## Create bakery Environment
	@echo "Installing bakery customer..."
	kubectl apply -k projects/rockstage/bakery/
	@echo "Waiting while Wordpress is starting up..."
	@echo "Getting status"
	kubectl get all -n bakery

wp-bakery-delete: ## Delete bakery Environment
	@echo "Deleting bakery customer..."
	kubectl delete -k projects/rockstage/bakery/

wp-supermarket-create: ## Create supermarket Environment
	@echo "Installing supermarket customer..."
	kubectl apply -k projects/rockstage/supermarket/
	@echo "Waiting while Wordpress is starting up..."
	@echo "Getting status"
	kubectl get all -n supermarket

wp-supermarket-delete: ## Delete supermarket Environment
	@echo "Deleting supermarket customer..."
	kubectl delete -k projects/rockstage/supermarket/

port-forward-bakery-on: ## Start port-forward bakery of Wordpress and PHPMyAdmin
	@echo "Starting PHPMyAdmin port-forward bakery..."
	@ps -ef |grep "kubectl port-forward" |grep -v grep | awk -F" " {'print $2'} | xargs kill -9
	@nohup kubectl port-forward service/phpmyadmin 8071:80 -n bakery &
	@echo "link: http://localhost:8071"
	@echo "starting Wordpress port-forward customer..."
	@nohup kubectl port-forward service/wordpress 8070:80 -n bakery &
	@echo "link: http://localhost:8070"

port-forward-petshop-on: ## Start port-forward petshop of Wordpress and PHPMyAdmin
	@echo "Starting PHPMyAdmin port-forward petshop..."
	@ps -ef |grep "kubectl port-forward" |grep -v grep | awk -F" " {'print $2'} | xargs kill -9
	@nohup kubectl port-forward service/phpmyadmin 8081:80 -n petshop &
	@echo "link: http://localhost:8081"
	@echo "starting Wordpress port-forward petshop..."
	@nohup kubectl port-forward service/wordpress 8080:80 -n petshop &
	@echo "link: http://localhost:8080"

port-forward-supermarket-on: ## Start port-forward supermarket of Wordpress and PHPMyAdmin
	@echo "Starting PHPMyAdmin port-forward supermarket..."
	@ps -ef |grep "kubectl port-forward" |grep -v grep | awk -F" " {'print $2'} | xargs kill -9
	@nohup kubectl port-forward service/phpmyadmin 8091:80 -n supermarket &
	@echo "link: http://localhost:8091"
	@echo "starting Wordpress port-forward customer..."
	@nohup kubectl port-forward service/wordpress 8090:80 -n supermarket &
	@echo "link: http://localhost:8090"

port-forward-prometheus-on: ## Start port-forward Prometheus, Alert Manager e Grafana
	@echo "Starting Grafana port-forward monitoring..."
	@ps -ef |grep "kubectl port-forward" |grep -v grep | awk -F" " {'print $2'} | xargs kill -9
	@nohup kubectl port-forward service/grafana 3000:3000 -n monitoring &
	@echo "link: http://localhost:3000"
	@echo "Grafana User/Password: admin/admin"
	@echo "starting PromQL port-forward monitoring..."
	@nohup kubectl port-forward service/prometheus-k8s 9999:9090 -n monitoring &
	@echo "link: http://localhost:9999"
	@echo "starting Alert Manager port-forward monitoring..."
	@nohup kubectl port-forward service/alertmanager-main 9993:9093 -n monitoring &
	@echo "link: http://localhost:9993"

port-forward-stop-all: ## Stop ALL port-forward supermarket of Wordpress and PHPMyAdmin
	@echo "Stopping All port-forward of Wordpress and PHPMyAdmin..."
	ps -ef |grep "kubectl port-forward" |grep -v grep | awk -F" " {'print $2'} | xargs kill -9



