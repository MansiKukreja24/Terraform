provider "google" {
  credentials = file("new-project.json")
  project     = var.project   
}

resource "google_compute_network" "myvpc" {
  name                    = var.vpc_gcp
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network" {
  name          = var.lab
  ip_cidr_range = "10.0.1.0/24"
  region        = var.gcp_region
  network       = google_compute_network.myvpc.id  
}

resource "google_compute_firewall" "rule" {
  name    = "myfirewall"
  network = google_compute_network.myvpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

}

resource "google_container_cluster" "primary" {
  name               = "myk8scluster"
  location           = var.gcp_region
  initial_node_count = 1

  network    = google_compute_network.myvpc.name
  subnetwork = google_compute_subnetwork.network.name

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
    
  }
 
}


data "google_client_config" "provider" {}


provider "kubernetes" { 
  load_config_file = false

  host  = "https://${google_container_cluster.primary.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
}


resource "kubernetes_deployment" "wp" {
  metadata {
    name = "wordpress"
    labels = {
      App = "frontend"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          App = "frontend"
        }
      }
      spec {
        container {
          image = "wordpress"
          name  = "wordpress"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "lb" {
  metadata {
    name = "wordress"
  }
  spec {
    selector = {
      
      App = "frontend"
      
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  } 
}

