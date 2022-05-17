provider "google" {
  project = "dmp-test2"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_service_account" "service_account"{
  account_id   = "terraform-cloud-function"
  display_name = "terraform-cloud-function"
  description  = "service account to invoke cloudfunction created by terraform"
  project      = "dmp-test2"
}

resource "google_project_iam_member" "service_account_role_1" {
  member  = "serviceAccount:${google_service_account.service_account.email}"
  project = "dmp-test2"
  role    = "roles/cloudfunctions.invoker"
}
