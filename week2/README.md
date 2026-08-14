# Week 2 lab docs

Submission PDFs and architecture diagram for Week 2 Lab 2 (LB + private app + FSS).

**Terraform (canonical IaC):** [`../terraform/nonprd/week2-lb-fss/`](../terraform/nonprd/week2-lb-fss/)

That stack uses cohesive nested modules (`modules/network`, `compute`, `storage`, `lb`) plus a multi-file root — not thin one-resource modules.
