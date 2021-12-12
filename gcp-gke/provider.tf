terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}

provider "google" {
  credentials = file("~/.gcp/gcp-playground-332207-c35da30fd748.json")
  project     = "gcp-playground-332207"
}
