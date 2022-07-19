terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.28.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.7"
    }
  }
}

data "sops_file" "google-cloud-key" {
  source_file = "google-cloud-key.sops.json"
}

resource "google_compute_firewall" "minecraft" {
  name          = "minecraft-default"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["25565"]
  }
}

resource "google_compute_address" "saba" {
  name         = "saba-address"
  address_type = "EXTERNAL"
}

provider "google" {
  credentials = data.sops_file.google-cloud-key.raw

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "saba" {
  name         = "saba"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "projects/mythal-nixos/global/images/nixos-image-22-11pre392657-e4d49de45a3-x86-64-linux"
      type  = "pd-ssd"
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.saba.address
    }
  }

  metadata = {
    ssh-keys = "${var.username}:${var.ssh_key_pub}"
  }

  tags = ["minecraft"]
}
