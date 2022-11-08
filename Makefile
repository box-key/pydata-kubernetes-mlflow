include .env

# mlflow 
MLFLOW_NAME=mlflow
MLFLOW_TAG=v1.27.0

# namespaces to be used for this demo
TARGET_NAMESPACES  = deployment-demo
TARGET_NAMESPACES += cluster-ip-demo
TARGET_NAMESPACES += node-port-demo
TARGET_NAMESPACES += load-balancer-demo
TARGET_NAMESPACES += knative-demo

.PHONY: build install deploy test-container test-local register secrets namespaces clean mlflow-image help

build: 
	docker build -t $(IMAGE_NAME):$(TAG) -f test-app/Dockerfile test-app/

install:
	@echo "Installing python packages using 'pip'"
	pip install -q -r test-app/requirements.txt

deploy:
	@echo "Tagging image"
	docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_HUB_USER)/$(IMAGE_NAME):$(TAG)
	@echo "Pushing image"
	docker push $(DOCKER_HUB_USER)/$(IMAGE_NAME):$(TAG)

test-container:
# .env contains necessary information
	docker run --rm -it --env-file .env -p 5000:5000 $(IMAGE_NAME):$(TAG)

test-local:
	env $$(cat .env | xargs) gunicorn --chdir test-app/ wsgi:app \
		--workers 1 \
		--bind 127.0.0.1:5000 \
		--timeout 300

register:
	env $$(cat .env | xargs) python test-app/register.py

secrets:
	@for ns in $(TARGET_NAMESPACES); do \
		echo "Namespace: $$ns"; \
		kubectl create secret generic mlflow --from-literal=mlflowuri=$(MLFLOW_URI) -n $$ns; \
	done

namespaces:
	@for ns in $(TARGET_NAMESPACES); do \
		echo "Namespace: $$ns"; \
		kubectl create ns $$ns; \
	done

clean:
	@echo "Delete all components in the following namespaces and namespace themselves in 3 seconds: \n$(TARGET_NAMESPACES)"
	sleep 3
	@for ns in $(TARGET_NAMESPACES); do \
		echo "Namespace: $$ns"; \
		kubectl delete all --all -n $$ns; \
		kubectl delete ns $$ns; \
	done

mlflow-image:
	docker build -t $(MLFLOW_NAME):$(MLFLOW_TAG) -f mlflow/Dockerfile .

help:
	@echo 'Test APP:'
	@echo '  install        - Install dependencies for test-app. Make sure your '
	@echo '                   python virtual environment such as conda is active'
	@echo '  test-local     - Run test-app locally'
	@echo '  build          - Build image for test-app'
	@echo '  deploy         - Tag and push test-app image to remote image '
	@echo '                   repository. You may need to docker login first'
	@echo '  test-container - Run test-app in docker container'
	@echo '  register       - Register a Random Forest model into mlflow model '
	@echo '                   registry'
	@echo 'Kubernetes:'
	@echo '  namespaces     - Create namespaces for this demo'
	@echo '  secrets        - Create secrets for this demo'
	@echo '  clean          - Clean all components in the namespaces for this '
	@echo '                   demo'
	@echo 'Mlflow:'
	@echo '  mlflow-image   - BUild mlflow image'
