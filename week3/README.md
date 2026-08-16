# Week 3 lab docs

Submission PDF and architecture diagram for Week 3 Lab 3 (containerized app on OKE).

**Terraform (canonical IaC):** [`../terraform/nonprd/week3-containerized-oke/`](../terraform/nonprd/week3-containerized-oke/)

That stack uses cohesive nested modules (`modules/network`, `subnet`, `oke`) plus a multi-file root and `k8s/` manifests applied with kubectl after the cluster is ACTIVE.
