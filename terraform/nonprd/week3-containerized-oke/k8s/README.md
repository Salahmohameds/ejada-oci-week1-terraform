# Kubernetes manifests — Week 3 OKE workload

Apply **after** the OKE cluster is ACTIVE and kubeconfig is written. Terraform does **not** apply these (no Kubernetes provider).

Namespace: `w3-demo` (must match `k8s_namespace` in tfvars).

Authoritative lab story: [`../../../labs/week3-containerized-oke/WEEK3-LAB3-TERRAFORM-DOCUMENTATION.md`](../../../labs/week3-containerized-oke/WEEK3-LAB3-TERRAFORM-DOCUMENTATION.md).

## Image

**`docker.io/library/nginx:alpine`**

Empty `image` fails with `spec.template.spec.containers[0].image: Required value`. OKE worker CRI-O rejects short names (`nginx:alpine`). The live cluster used the fully qualified Docker Hub image.

## Why PVC + `oci-bv` is the block volume

OKE’s CSI driver `blockvolume.csi.oraclecloud.com` is the cluster StorageClass **`oci-bv`**. A PVC with that class asks OCI to create an **external Block Volume** and attach it to the worker that runs the pod (`ReadWriteOnce`). The Deployment mounts that volume at `/data`.

This is not a File Storage (FSS) share. It is one BV attached to one pod at a time.

## Apply order (Windows)

```powershell
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/storageclass.yaml
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

kubectl -n w3-demo get pods,pvc,svc
```

`storageclass.yaml` names the built-in `oci-bv` class. If the class already exists, kubectl may reject parameter updates — expected. PVC still uses `oci-bv`.

Wait until the Service `EXTERNAL-IP` is populated, then open `http://<EXTERNAL-IP>/`.

```powershell
kubectl -n w3-demo exec deploy/nginx -c nginx -- df -h /data
```

## Delete workloads before cluster destroy

```powershell
kubectl delete -f k8s/service.yaml --ignore-not-found
kubectl delete -f k8s/deployment.yaml --ignore-not-found
kubectl delete -f k8s/pvc.yaml --ignore-not-found
# wait until the Service LB and the Block Volume disappear in Console
# then terraform destroy
```
