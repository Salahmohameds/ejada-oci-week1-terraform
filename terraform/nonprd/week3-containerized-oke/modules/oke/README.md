# Module: oke

OKE related-group: the container engine cluster, its managed node pool, and
the optional API/worker/pod NSGs that get attached to them. NSGs stay inside
this module (in `nsg.tf`) because they are part of the same cluster building
block, not a separate one-resource module. Called **once** from the root
(`oke.tf`) behind `count = var.enable_oke ? 1 : 0` — one cluster, one node
pool, at most one NSG per role (API/workers/pods), never duplicated through
multiple module calls.

## Files

| File | Declares |
|---|---|
| `main.tf` | `oci_containerengine_cluster.this` (VCN-native pod networking via `cluster_pod_network_options`, public/private API endpoint, Service LB subnet), `oci_containerengine_node_pool.this` (single managed node pool with `dynamic "node_shape_config"` for flex shapes, VCN-native pod network options on the pool). Both resources carry `lifecycle.precondition` checks (kubernetes version set, pod subnets present for VCN-native, node image set, worker subnet set, SSH key set). |
| `nsg.tf` | One `oci_core_network_security_group.this` resource with `for_each` over a `{ api, workers, pods }` display-name map (`pods` only present when VCN-native CNI is active) — not three copy-pasted NSG resources. Security rules follow the same pattern: `api_ingress_tcp` / `workers_ingress_tcp` render each NSG's TCP rule list with `for_each`, `all_ingress` renders the workers↔pods "allow all from subnet" rules from one map, and `egress_all` renders the "allow all egress" rule shared by every NSG from one map — no rule shape is ever repeated as a separate `count`-gated resource per NSG. |
| `variables.tf` | Every input below. |
| `outputs.tf` | Every output below. |
| `versions.tf` | Declares the `oci` provider requirement; inherits provider configuration from the root. |

## Inputs

| Variable | Description |
|---|---|
| `compartment_ocid` | Compartment OCID for the cluster, node pool, and optional NSGs. |
| `vcn_id` | VCN OCID that hosts the cluster. |
| `cluster_name` | OKE cluster display name. |
| `cluster_type` | `BASIC_CLUSTER` (lab) or `ENHANCED_CLUSTER`. |
| `kubernetes_version` | Kubernetes version string (e.g. `v1.31.1`). |
| `cni_type` | Pod CNI; the lab uses `OCI_VCN_IP_NATIVE`. |
| `endpoint_public` | Assign a public IP to the Kubernetes API endpoint. |
| `endpoint_subnet_id` | Subnet OCID for the Kubernetes API endpoint (the `lb` subnet). |
| `worker_subnet_id` | Subnet OCID for managed worker nodes. |
| `pod_subnet_ids` | Pod subnet OCIDs, required when `cni_type` is `OCI_VCN_IP_NATIVE`. |
| `service_lb_subnet_id` | Public subnet OCID for Kubernetes Service load balancers. |
| `services_cidr` | Kubernetes Service CIDR (must not overlap the VCN). |
| `pods_cidr` | Overlay pod CIDR, used only when `cni_type` is `FLANNEL_OVERLAY`. |
| `dashboard_enabled` | Enable the OKE Kubernetes dashboard add-on. |
| `availability_domain` | Availability domain for node pool placement. |
| `node_pool_name` | Managed node pool display name. |
| `node_pool_size` | Worker node count. |
| `node_shape` | Worker node shape. |
| `node_ocpus` | OCPUs per flex worker. |
| `node_memory_in_gbs` | Memory (GB) per flex worker. |
| `node_boot_volume_size_in_gbs` | Worker boot volume size (GB). |
| `node_image_id` | OKE-compatible node image OCID. |
| `ssh_public_key` | SSH public key placed on worker nodes. |
| `max_pods_per_node` | Max pods per worker for VCN-native CNI. |
| `freeform_tags` | Freeform tags for OKE resources. |
| `defined_tags` | Defined tags for OKE resources. |
| `enable_nsgs` | Create and attach NSGs for the API endpoint, workers, and pods. |
| `nsg_api_display_name` | API endpoint NSG display name. |
| `nsg_workers_display_name` | Worker NSG display name. |
| `nsg_pods_display_name` | Pod NSG display name (VCN-native). |
| `worker_subnet_cidr` | Worker subnet CIDR, used as an NSG rule source. |
| `pod_subnet_cidr` | Pod subnet CIDR, used as an NSG rule source. |
| `lb_subnet_cidr` | Service-LB/API subnet CIDR, used as an NSG rule source. |
| `allowed_api_cidr` | Client CIDR allowed to reach the Kubernetes API. |
| `api_port` | Kubernetes API TCP port. |
| `oke_control_port` | OKE control/proxy TCP port on the API endpoint. |
| `kubelet_port` | Kubelet TCP port on workers. |
| `app_port` | Application/NodePort target used by the Service LB. |
| `node_port_min` | NodePort range start for Service LB traffic. |
| `node_port_max` | NodePort range end for Service LB traffic. |

## Outputs

| Output | Used for |
|---|---|
| `cluster_id` | OCID of the OKE cluster. Used to build a kubeconfig (`oci ce cluster create-kubeconfig`) and as the root output surfaced to the operator. |
| `cluster_name` | Cluster name, for confirming the right cluster in the OCI console/CLI. |
| `node_pool_id` | OCID of the managed node pool, for `oci ce node-pool` lookups. |
| `kubernetes_version` | Kubernetes version actually applied on the cluster — compare against `var.kubernetes_version` / the resolved `local.kubernetes_version`. |
| `cni_type` | CNI type configured on the cluster, echoed back for verification. |
| `endpoints` | Cluster endpoint map (public/private) once populated; use the public endpoint to reach the Kubernetes API from outside the VCN. |
| `nsg_api_id` | API endpoint NSG OCID when `enable_nsgs` is `true`, otherwise `null`. |
| `nsg_workers_id` | Worker NSG OCID when `enable_nsgs` is `true`, otherwise `null`. |
| `nsg_pods_id` | Pod NSG OCID when VCN-native NSGs are enabled, otherwise `null`. |

## What to expect after apply

One `ACTIVE` OKE cluster and one node pool with `var.oke_node_pool_size`
workers. When `enable_nsgs` is `true`, exactly one API NSG, one worker NSG,
and (VCN-native only) one pod NSG — each with its rule set, never re-created
per module call.
