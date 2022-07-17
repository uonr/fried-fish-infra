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

resource "google_compute_firewall" "allow-icmp" {
  name    = "allow-icmp"
  network = google_compute_network.vpc_network.name
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "icmp"
  }
}
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "minecraft" {
  name    = "minecraft-default"
  network = google_compute_network.vpc_network.name
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["25565"]
  }
}

resource "google_compute_address" "saba" {
  name = "saba-address"
  address_type = "EXTERNAL"
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
      nat_ip = google_compute_address.saba.address
    }
  }
}
