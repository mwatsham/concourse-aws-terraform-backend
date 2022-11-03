terraform { 
  backend "s3" { 
    bucket = "dummy-tf-state-bucket"
    key = "dummy-tf-state-bucket/terraform.tfstate"
    region = "eu-west-2"
    encrypt = true
    kms_key_id = "603eefb7-c704-4752-b020-172e619ed63c"
    dynamodb_table = "dummy-tf-remote-state-lock"
    role_arn = "arn:aws:iam::123456789012:role/concourse-deploy-role"
  }
}
