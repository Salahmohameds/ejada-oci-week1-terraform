# Week 3 — Containerized application / OKE

Lab deliverables for Week 3 Lab 3 (OKE, VCN-native CNI, kubectl workload).

**Terraform (canonical IaC):** [`../terraform/nonprd/week3-containerized-oke/`](../terraform/nonprd/week3-containerized-oke/)

That stack uses cohesive nested modules (`modules/network`, `modules/subnet`, `modules/oke`), optional remote state (`backend.tf` + `backend.hcl.example`), and `k8s/` manifests applied with kubectl after the cluster is ACTIVE.

## Files in this folder

| File | Description |
|------|-------------|
| [Week3-Lab3-Terraform-Documentation.pdf](Week3-Lab3-Terraform-Documentation.pdf) | Full Terraform lab write-up (architecture, commands, evidence, screenshots) |
| [Week3-Terraform-Diagrams.drawio](Week3-Terraform-Diagrams.drawio) | Architecture / traffic / topology diagrams for the Terraform lab |
| [Week3-Terraform-Modules-Reference.pdf](Week3-Terraform-Modules-Reference.pdf) | Detailed reference for each module (network, subnet, oke): every file, purpose, inputs, outputs |
| [Week3-Modules-Diagrams2.drawio](Week3-Modules-Diagrams2.drawio) | Module-map / module diagrams companion to the modules reference |
