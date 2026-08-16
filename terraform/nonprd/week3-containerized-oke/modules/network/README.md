# Module: network

VCN core related-group for Week 3: the VCN itself plus the gateways and shared
logging resource every subnet in the stack depends on. Subnets (route table +
security list + optional flow log) live in `modules/subnet`; the OKE cluster
and its NSGs live in `modules/oke`. This module is called **once** from the
root (`network.tf`) — there is no per-gateway or per-VCN duplication.

## Files

| File | Declares |
|---|---|
| `main.tf` | `data.oci_core_services.all_osn` (lookup for the All Services In Oracle Services Network CIDR), `oci_core_vcn.this`, `oci_core_internet_gateway.this`, `oci_core_nat_gateway.this`, `oci_core_service_gateway.this` (count = `var.enable_service_gateway`), `oci_logging_log_group.vcn_flow` (count = `var.enable_log_group`, shared by all subnets that enable flow logs). |
| `variables.tf` | Every input below. |
| `outputs.tf` | Every output below. |
| `versions.tf` | Declares the `oci` provider requirement; the module inherits the provider configuration from the root — no version pin here. |

## Inputs

| Variable | Description |
|---|---|
| `compartment_ocid` | Compartment OCID for the VCN, gateways, and shared log group. |
| `vcn_display_name` | VCN display name (e.g. `w3-vcn`). |
| `vcn_cidr` | IPv4 CIDR block for the VCN. |
| `vcn_dns_label` | VCN DNS label (letters/digits, max 15). |
| `igw_display_name` | Internet Gateway display name. |
| `nat_display_name` | NAT Gateway display name. |
| `sgw_display_name` | Service Gateway display name. |
| `enable_service_gateway` | Whether to create the Service Gateway (All OSN). Private-subnet route rules that use it are added at the root, not inside this module. |
| `enable_log_group` | Whether to create the shared VCN flow-log group. Subnet modules attach per-subnet SERVICE logs to it. |
| `log_group_display_name` | Shared flow-log group display name. |
| `freeform_tags` | Freeform tags applied to every resource in this module. |
| `defined_tags` | Defined tags applied to every resource in this module. |

## Outputs

| Output | Used for |
|---|---|
| `vcn_id` | Passed to `modules/subnet` (`vcn_id`) and `modules/oke` (`vcn_id`). Expect a valid VCN OCID after apply. |
| `internet_gateway_id` | Root local `gateway_ids.igw`, used as the default-route target for the public (`lb`) subnet. |
| `nat_gateway_id` | Root local `gateway_ids.nat`, used as the default-route target for private (`workers`, `pods`) subnets. |
| `service_gateway_id` | OCID of the Service Gateway when `enable_service_gateway` is true, otherwise `null`. Referenced if an extra route rule needs the SGW as its network entity. |
| `log_group_id` | OCID of the shared flow-log group when `enable_log_group` is true, otherwise `null`. Passed into `modules/subnet` as `log_group_id` so per-subnet flow logs land in one shared group instead of creating their own. |
| `osn_cidr` | All-OSN service CIDR block. Consumed by the root `sgw_route` local to build the extra NAT-subnet route rule to the Service Gateway. |

## What to expect after apply

One VCN, one Internet Gateway, one NAT Gateway, and (when enabled) one Service
Gateway and one shared log group — never more than one of each, regardless of
how many subnets or clusters are layered on top.
