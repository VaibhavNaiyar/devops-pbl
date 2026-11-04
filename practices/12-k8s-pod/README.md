# Practice 12 – Simple Kubernetes Pod YAML

```bash
kind create cluster --name pbl          # or: minikube start / Docker Desktop -> Enable Kubernetes
kubectl apply -f pod.yaml
kubectl get pods -o wide
kubectl describe pod nginx-pod
kubectl logs nginx-pod
kubectl port-forward pod/nginx-pod 8080:80     # open http://localhost:8080
kubectl exec -it nginx-pod -- sh
kubectl apply -f multi-container-pod.yaml
kubectl port-forward pod/sidecar-pod 8081:80   # timestamps grow every 5s
kubectl delete -f pod.yaml -f multi-container-pod.yaml
```
YAML parts: `apiVersion`, `kind`, `metadata` (name/labels), `spec.containers` (image, ports, resources, probes).
