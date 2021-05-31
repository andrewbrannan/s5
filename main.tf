terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.66.1"
    }
  }
}

variable "gcloud_project_name" {
  type = string
}

variable "gcloud_project_zone" {
  type = string
}

variable "gcloud_project_region" {
  type = string
}

variable "request_check_topic" {
  type = string
}

variable "check_url" {
  type = string
}


provider "google" {
  credentials = file("service_account.json")

  project = var.gcloud_project_name
  region  = var.gcloud_project_region
  zone    = var.gcloud_project_zone
}

resource "google_pubsub_topic" "request_check_topic" {
  name = var.request_check_topic
}

resource "google_cloud_scheduler_job" "job" {
  name        = "check-stock-job"
  description = "Job to check stock at a url"
  schedule    = "*/10 * * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.request_check_topic.id
    attributes = {
      "url" = base64encode(var.check_url)
    }
  }
}
