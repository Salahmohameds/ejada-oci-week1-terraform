data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Latest Oracle Linux image for the chosen shape in this region.
data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# All regional services CIDR for Service Gateway (object storage, etc.).
data "oci_core_services" "all_osn" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# Resolve mount target private IP OCID → dotted IP for cloud-init / NFS mount.
data "oci_core_private_ip" "mount_target" {
  count = var.enable_fss ? 1 : 0

  private_ip_id = oci_file_storage_mount_target.app[0].private_ip_ids[0]
}
