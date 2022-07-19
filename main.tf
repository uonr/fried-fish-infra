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

resource "google_storage_bucket" "nixos" {
  name                        = "nixos-image-uonr"
  location                    = "ASIA-NORTHEAST1"
  force_destroy               = true
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
}
resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.nixos.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
resource "google_compute_firewall" "allow-icmp" {
  name          = "allow-icmp"
  network       = google_compute_network.vpc_network.name
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "icmp"
  }
}
resource "google_compute_firewall" "allow-ssh" {
  name          = "allow-ssh"
  network       = google_compute_network.vpc_network.name
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "minecraft" {
  name          = "minecraft-default"
  network       = google_compute_network.vpc_network.name
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["25565"]
  }
}

resource "google_compute_address" "saba" {
  name         = "saba-address"
  address_type = "EXTERNAL"
  lifecycle {
    prevent_destroy = true
  }
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
      type  = "pd-ssd"
      size  = 16
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      nat_ip = google_compute_address.saba.address
    }
  }
}
