provider "google" {
  project = "slavinskiytm81"
  zone    = "europe-west1-b"
}

resource "google_compute_network" "nat-example" {
  name = "nat-example"
  mtu  = 1460
  auto_create_subnetworks = false
  project = "slavinskiytm81"
  routing_mode = "REGIONAL"
}



resource "google_compute_subnetwork" "some-subnet" {
  name          = "some-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west1"
  network       = google_compute_network.nat-example.id
}



resource "google_compute_firewall" "allow-internal-example" {
  name    = "allow-internal-example"
  network = google_compute_network.nat-example.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  source_ranges = ["10.0.1.0/24"]
  priority = 65534
}



resource "google_compute_firewall" "allow-ssh-iap" {
  name    = "allow-ssh-iap"
  network = google_compute_network.nat-example.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags = ["allow-ssh"]
}



resource "google_compute_instance" "example" {
  name         = "example"
  machine_type = "f1-micro"
  zone         = "europe-west1-b"

  tags = ["no-ip", "allow-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    subnetwork = "some-subnet"
  }
}



resource "google_compute_instance" "nat-gateway" {
  name         = "nat-gateway"
  machine_type = "f1-micro"
  zone         = "europe-west1-b"

  can_ip_forward  = true

  tags = ["nat", "allow-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    subnetwork = "some-subnet"
    access_config {

    }
  }

  metadata = {
  	startup-script = "#! /bin/bash sudo sh -c \"echo 1 > /proc/sys/net/ipv4/ip_forward\" sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
  }
}
resource "google_compute_route" "no_ip_internet_route" {
  name        = "no-ip-internet-route"
  dest_range  = "0.0.0.0/0"
  network     = google_compute_network.nat-example.name
  
  next_hop_instance = "nat-gateway"
  next_hop_instance_zone = "europe-west1-b"

  tags = ["no-ip"]

  priority = 800
}


# Internal HTTP load balancer with a managed instance group backend

# VPC network
resource "google_compute_network" "ilb_network" {
  name                    = "l7-ilb-network"
  provider                = google-beta
  auto_create_subnetworks = false
}

# proxy-only subnet
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "l7-ilb-proxy-subnet"
  provider      = google-beta
  ip_cidr_range = "10.0.0.0/24"
  region        = "europe-west1"
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
  network       = google_compute_network.ilb_network.id
}

# backend subnet
resource "google_compute_subnetwork" "ilb_subnet" {
  name          = "l7-ilb-subnet"
  provider      = google-beta
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west1"
  network       = google_compute_network.ilb_network.id
}

# forwarding rule
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "l7-ilb-forwarding-rule"
  provider              = google-beta
  region                = "europe-west1"
  depends_on            = [google_compute_subnetwork.proxy_subnet]
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.ilb_network.id
  subnetwork            = google_compute_subnetwork.ilb_subnet.id
  network_tier          = "PREMIUM"
}

# HTTP target proxy
resource "google_compute_region_target_http_proxy" "default" {
  name     = "l7-ilb-target-http-proxy"
  provider = google-beta
  region   = "europe-west1"
  url_map  = google_compute_region_url_map.default.id
}

# URL map
resource "google_compute_region_url_map" "default" {
  name            = "l7-ilb-regional-url-map"
  provider        = google-beta
  region          = "europe-west1"
  default_service = google_compute_region_backend_service.default.id
}

# backend service
resource "google_compute_region_backend_service" "default" {
  name                  = "l7-ilb-backend-subnet"
  provider              = google-beta
  region                = "europe-west1"
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.default.id]
  backend {
    group           = google_compute_region_instance_group_manager.mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# instance template
resource "google_compute_instance_template" "instance_template" {
  name         = "l7-ilb-mig-template"
  provider     = google-beta
  machine_type = "e2-small"
  tags         = ["http-server"]

  network_interface {
    network    = google_compute_network.ilb_network.id
    subnetwork = google_compute_subnetwork.ilb_subnet.id
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
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

# health check
resource "google_compute_region_health_check" "default" {
  name     = "l7-ilb-hc"
  provider = google-beta
  region   = "europe-west1"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

# MIG
resource "google_compute_region_instance_group_manager" "mig" {
  name     = "l7-ilb-mig1"
  provider = google-beta
  region   = "europe-west1"
  version {
    instance_template = google_compute_instance_template.instance_template.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}

# allow all access from IAP and health check ranges
resource "google_compute_firewall" "fw-iap" {
  name          = "l7-ilb-fw-allow-iap-hc"
  provider      = google-beta
  direction     = "INGRESS"
  network       = google_compute_network.ilb_network.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
  }
}

# allow http from proxy subnet to backends
resource "google_compute_firewall" "fw-ilb-to-backends" {
  name          = "l7-ilb-fw-allow-ilb-to-backends"
  provider      = google-beta
  direction     = "INGRESS"
  network       = google_compute_network.ilb_network.id
  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["http-server"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
}

# test instance
resource "google_compute_instance" "vm-test" {
  name         = "l7-ilb-test-vm"
  provider     = google-beta
  zone         = "europe-west1-b"
  machine_type = "e2-small"
  network_interface {
    network    = google_compute_network.ilb_network.id
    subnetwork = google_compute_subnetwork.ilb_subnet.id
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
}