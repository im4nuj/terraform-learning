terraform {
  backend "gcs" {
    bucket  = "terraform-cf-backend"
  }
}

data "template_file" "config_file"{
  template = "${file("${path.module}/tcf-api.yaml")}"
  vars = {
    ADDRESS = google_cloudfunctions_function.function.https_trigger_url
  }
}

provider "google" {           
  project = "dmp-test2"
  region  = "us-central1"
  zone = "us-central1-c"
}

resource "google_storage_bucket" "bucket" {
  name      = "terraform-dlp-decrypt-code"
  location  = "us"
}

resource "google_storage_bucket_object" "archive" {
  name   = "terraform-dlp"
  bucket = google_storage_bucket.bucket.name
  source = "main.zip"
}

resource "google_api_gateway_api" "api" {
  provider = google-beta
  project = "dmp-test2"
  api_id = "ap-terraform-trial"
}

resource "google_api_gateway_api_config" "api_cfg" {
  provider = google-beta
  project = "dmp-test2"
  api = google_api_gateway_api.api.api_id
  api_config_id = "tcf-cfg"
  openapi_documents {
    document {
      path = "terraform-cf-api.yaml"
      contents = base64encode(data.template_file.config_file.rendered)
    }
  }
  gateway_config {
    backend_config {
        google_service_account = "<your-service-account-email>"
    }
  }
}

resource "google_api_gateway_gateway" "api_gateway" {
  provider = google-beta
  project = "dmp-test2"
  region  = "us-central1"
  api_config = google_api_gateway_api_config.api_cfg.id
  gateway_id = "api-gateway"
}

resource "google_cloudfunctions_function" "function" {
  name        = "terraform-dlp-decrypt"
  runtime     = "python38"

  available_memory_mb   = 256
  max_instances         = 30
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  timeout               = 60
  entry_point           = "decrypt"
  service_account_email = "cloud-function-dlp-service-acc@dmp-test2.iam.gserviceaccount.com"

}