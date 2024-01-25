DATE := $(shell date +%Y%m%d)
build:
	docker build -t voronenko/debug-pod:latest .
push:
	docker push voronenko/debug-pod:latest
	docker tag voronenko/debug-pod:latest voronenko/debug-pod:$(DATE)
	docker push voronenko/debug-pod:$(DATE)

kube-deploy:
	kubectl apply -f ./debug-pod.yaml
kube-delete:
	kubectl delete -f ./debug-pod.yaml

