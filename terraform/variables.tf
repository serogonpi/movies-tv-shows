variable "project_id" {
    description = "unique name of the project"
    type = string
    default = "movies-shows-pipeline-19032026"
}

variable "region" {
    description = "GCP region to deploy resources in"
    type = string
    default = "us-central1"
}

variable "billing_account" {
    description = "billing account associated to the project"
    type = string
}

variable "bucket_name" {
    description = "bucket name"
    type = string
    default = "movies-tv-show-19032026"
}

variable "bq_dataset_name" {
    description = "bigquery dataset name"
    type = string
    default = "movies_tv_shows"
}

