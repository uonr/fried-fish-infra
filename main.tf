terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.28.0"
    }
    sops = {
      source = "carlpett/sops"
      version = "~> 0.7"
    }
  }
}

data "sops_file" "google-cloud-key" {
  source_file = "google-cloud-key.sops.json"
}

provider "google" {
  credentials = data.sops_file.google-cloud-key.raw

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "fried-network"
}


resource "google_compute_instance" "saba" {
  name         = "saba"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2204-lts"
      type = "pd-ssd"
      size = 16
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}
