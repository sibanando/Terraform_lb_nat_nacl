terraform {
  backend "s3" {
    bucket         = "backend-s3-demo-siba" # change this
    key            = "siba/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}
