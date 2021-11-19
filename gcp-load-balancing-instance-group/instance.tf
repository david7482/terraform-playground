locals {
  region = "asia-east1"
}

data "google_compute_image" "default" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}

resource "random_id" "instance_template" {
  byte_length = 2
  keepers = {
    version = 5
  }
}

resource "google_compute_instance_template" "default" {
  name         = "${var.name}-it-${random_id.instance_template.hex}"
  machine_type = "e2-small"

  tags = ["allow-health-check"]

  labels = {
    environment = var.env
  }

  region = local.region
  network_interface {
    subnetwork = "asia-east1-5418"
    access_config {
      # add this block to get public ip even it is empty
    }
  }

  disk {
    disk_size_gb = 32
    source_image = data.google_compute_image.default.self_link
    auto_delete  = true
    boot         = true
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  # install nginx and serve a simple web page
  metadata = {
    startup-script = <<-EOF1
      #! /bin/bash
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y nginx-light jq

      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

      cat <<EOF > /var/www/html/index.html
      <pre>
      Name: $NAME
      IP: $IP
      Metadata: $METADATA
      </pre>
      EOF
    EOF1
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "default" {
  name               = "${var.name}-igm"
  base_instance_name = "${var.name}-igm"
  target_size        = 5
  region             = local.region

  named_port {
    name = "http"
    port = 80
  }

  version {
    name              = "primary"
    instance_template = google_compute_instance_template.default.self_link
  }

  update_policy {
    minimal_action        = "REPLACE"
    type                  = "PROACTIVE"
    replacement_method    = "SUBSTITUTE"
    max_surge_fixed       = 3
    max_unavailable_fixed = 3
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = 30
  }
}