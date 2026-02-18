terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"

  backend "gcs" {
    bucket = "devops-assignment-tf-state-prithvirajreddy" # You need to create this bucket manually
    prefix = "gcp"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
