resource "random_id" "subnets" {
  count       = length(var.subnets)
  byte_length = 2
}

resource "google_compute_subnetwork" "subnets" {
  count = length(var.subnets)

  network                  = google_compute_network.vpc.id
  name                     = "${lookup(var.subnets[count.index], "region")}-${random_id.subnets[count.index].hex}"
  region                   = lookup(var.subnets[count.index], "region")
  ip_cidr_range            = lookup(var.subnets[count.index], "cidr")
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_1_MIN"
    flow_sampling        = 1
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
