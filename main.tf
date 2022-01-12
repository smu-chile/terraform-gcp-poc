provider "google" {
  project = "terraform-projects-337900"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public-subnetwork" {
  name          = "terraform-subnetwork"
  ip_cidr_range = "10.120.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_address" "internal_address" {
  name         = "terraform-internal-ip"
  region       = "us-central1"
  address_type = "INTERNAL"
  address      = "10.120.0.10"
  subnetwork   = google_compute_subnetwork.public-subnetwork.id
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-vm"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  tags = ["terraform", "vm"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.public-subnetwork.id
    network_ip = google_compute_address.internal_address.address

    access_config {
      // Ephemeral public IP
    }

  }

}

resource "google_compute_firewall" "poc-allow-ssh" {
  name    = "terraform-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["35.235.240.0/20"]
}