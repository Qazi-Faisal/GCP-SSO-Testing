resource "google_compute_instance" "app_server" {
  name         = "${var.project_name}-server"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["web-server", "ssh-access"]

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.boot_disk_size
      type  = "pd-standard"
    }
  }
  network_interface {
    network    = var.vpc_name
    subnetwork = var.subnet_name
    
    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only"]
  }

  metadata = {
    startup-script = var.startup_script
  }

  scheduling {
    preemptible       = var.preemptible
    automatic_restart = !var.preemptible
  }
}