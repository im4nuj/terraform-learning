provider "google" {           
  project = "dmp-test2"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_api_gateway_api" "api_cfg" {
  project = "dmp-test2"
  provider = google-beta
  api_id = "terraform-trial"
}

resource "google_api_gateway_api_config" "api_cfg" {
  project = "dmp-test2"
  provider = google-beta
  api = google_api_gateway_api.api_cfg.api_id
  api_config_id = "tcf-cfg"
  openapi_documents {
    document {
      path = "tcf-api.yaml"
      contents = filebase64("C:\\Users\\pande\\Desktop\\terraform-gcp\\ApiGateway\\tcf-api.yaml")
    }
  }
}
