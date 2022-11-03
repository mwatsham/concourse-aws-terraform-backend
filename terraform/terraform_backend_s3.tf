terraform {
  backend "s3" {}
}

data "terraform_remote_state" "s3_state_backend" {
  backend = "s3"
}

output "s3_terraform_state_backend" {
  value = data.terraform_remote_state.s3_state_backend.outputs
}
