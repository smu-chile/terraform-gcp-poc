This is a little example of how to create a VPC, Subnet and Compute Instance on GCP using terraform
Based on the documentation of [Terraform Google](https://registry.terraform.io/providers/hashicorp/google/latest/docs)


## Select the provider

First, we need to set the provider:

```bash
provider "google" {
  project = "<your project>"
  region  = "us-central1"
  zone    = "us-central1-c"
}
```

## Create the VPC
By default GCP has a VPC with many subnet, if you need to create your on VPC

```bash
resource "google_compute_network" "default" {
  name = "my-network"
}
```

## Create the subnet
In order to create the desire subnet.

```bash
resource "google_compute_subnetwork" "default" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.default.id
}
```

## Internal Address
Sometimes you need to set an specific address

```bash
resource "google_compute_address" "internal_with_subnet_and_address" {
  name         = "my-internal-address"
  subnetwork   = google_compute_subnetwork.default.id
  address_type = "INTERNAL"
  address      = "10.0.42.42"
  region       = "us-central1"
}
```

## Create the compute instance
Now with all setup you can create you compute instance

```bash
resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

}
```

## Access to the compute instance
In order to access to the compute instance you need to allow the desired port


```bash
resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_tags = ["web"]
}
```

## Terraform commands
In this example we create a main.tf and use the following commands
terraform validate
terraform fmt
terraform init
terraform plan
terraform apply
terraform destroy