resource "google_compute_health_check" "default" {
  name = "${var.name}-http-health-check"

  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 3
  unhealthy_threshold = 3

  http_health_check {
    port_name = "http"
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "${var.name}-cert"

  managed {
    domains = ["gcp.david74.dev"]
  }
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.name}-http-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = 80
  target                = google_compute_target_http_proxy.default.id

  labels = {
    environment = var.env
  }
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.name}-https-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = 443
  target                = google_compute_target_https_proxy.default.id

  labels = {
    environment = var.env
  }
}

resource "google_compute_target_http_proxy" "default" {
  name    = "${var.name}-target-http-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_target_https_proxy" "default" {
  name             = "${var.name}-target-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_url_map" "default" {
  name            = "${var.name}-url-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name = "${var.name}-http-backend-service"

  protocol                        = "HTTP"
  port_name                       = "http"
  load_balancing_scheme           = "EXTERNAL"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 60
  health_checks                   = [google_compute_health_check.default.id]

  backend {
    group           = google_compute_region_instance_group_manager.default.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}