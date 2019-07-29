# replicated-starter-knative

# kubectl apply -f namespace.yaml
```
---
# kind: scheduler-kubernetes
apiVersion: v1
kind: Namespace
metadata:
  labels:
    istio-injection: disabled
  name: istio-system
---
# kind: scheduler-kubernetes
apiVersion: v1
kind: Namespace
metadata:
  labels:
    istio-injection: enabled
  name: knative-serving
---
# kind: scheduler-kubernetes
apiVersion: v1
kind: Namespace
metadata:
  labels:
    istio-injection: enabled
  name: replicated-xxxxxxxxxxxxxxxxxxxxxxx
```
