provider "google" {
    project = var.project_id
    region = var.region
}

resource "google_project" "project" {
    name = "movies-tv-shows"
    project_id = var.project_id
    billing_account = var.billing_account
}

resource "google_storage_bucket" "bucket" {
    name = var.bucket_name
    project = google_project.project.project_id
    location = var.region
    force_destroy = true
    depends_on = [ google_project_service.service ]
}

resource "google_bigquery_dataset" "dataset" {
    dataset_id = var.bq_dataset_name
    project = google_project.project.project_id
    location = var.region
    depends_on = [ google_project_service.service ]
}

resource "google_project_service" "service" {
    for_each = toset([
        "storage.googleapis.com",
        "bigquery.googleapis.com"
    ])
    project = google_project.project.project_id
    service = each.value
}