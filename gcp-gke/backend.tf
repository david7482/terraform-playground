terraform {
  backend "gcs" {
    credentials = "~/.gcp/gcp-playground-332207-c35da30fd748.json"
    bucket      = "david74-terraform-remote-state-storage"
    prefix      = "terraform-gcp-gke"
  }
}