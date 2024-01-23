terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 3.75.0",
    }
  }
  required_version = "~> 1.3"

/* Uncomment below mentioned block if want to enable backend */
/*
  backend "s3" {
    key    = "demo-tfe-backend" #replace with your S3 bucket if want to enable bckend
    bucket = "demo-tfe-backend" #replace with your S3 bucket if want to enable bckend
    region = "us-east-1"        #add region of your choice
  }
*/
}
