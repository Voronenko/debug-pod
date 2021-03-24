build:
	docker build -t voronenko/debug-pod:latest .
push:
	docker push voronenko/debug-pod:latest

kube-deploy:
	kubectl apply -f ./debug-pod.yaml
kube-delete:
	kubectl delete -f ./debug-pod.yaml

