variable "aws_region" {}
variable "aws_region_replica" {}
variable "aws_deploy_role" {}

provider "aws" {
  region = var.aws_region
  
  assume_role {
    role_arn = var.aws_deploy_role 
  }
}

provider "aws" {
  alias  = "replica"
  region = var.aws_region_replica
  
  assume_role {
    role_arn = var.aws_deploy_role 
  }
}

output "backend_tfconfig" {
  value = { 
    backend_s3 = { 
      bucket = aws_s3_bucket.state.bucket,
      key = "<environment/app/pipeline name>/terraform.tfstate",
      region = aws_s3_bucket.state.region,
      encrypt = true,
      kms_key_id = aws_kms_key.this.id,
      dynamodb_table = aws_dynamodb_table.lock.id
    } 
  }
}

resource "aws_s3_object" "backend_tfconfig_template" {
  bucket = aws_s3_bucket.state.bucket
  key    = "${aws_s3_bucket.state.bucket}/backend.tf.template"
  content = <<-EOT
  # Template for consuming this S3 Terraform State backend
  terraform { 
    backend "s3" { 
      bucket = "${aws_s3_bucket.state.bucket}"
      key = "<environment/app/pipeline name/etc>/terraform.tfstate"
      region = "${aws_s3_bucket.state.region}"
      encrypt = true
      kms_key_id = "${aws_kms_key.this.id}"
      dynamodb_table = "${aws_dynamodb_table.lock.id}"
      role_arn = "<arn for terraform state role>"
    } 
  }
  EOT
}

resource "aws_s3_object" "backend_tfconfig" {
  bucket = aws_s3_bucket.state.bucket
  key    = "${aws_s3_bucket.state.bucket}/backend.tf"
  content = <<-EOT
  terraform { 
    backend "s3" { 
      bucket = "${aws_s3_bucket.state.bucket}"
      key = "${aws_s3_bucket.state.bucket}/terraform.tfstate"
      region = "${aws_s3_bucket.state.region}"
      encrypt = true
      kms_key_id = "${aws_kms_key.this.id}"
      dynamodb_table = "${aws_dynamodb_table.lock.id}"
      role_arn = "<arn for terraform state role>"
    } 
  }
  EOT
}

resource "local_file" "s3_backend_tfconfig" {
  filename = "./s3_backend_tfconfig"
  content = <<-EOT
  terraform { 
    backend "s3" { 
      bucket = "${aws_s3_bucket.state.bucket}"
      key = "${aws_s3_bucket.state.bucket}/terraform.tfstate"
      region = "${aws_s3_bucket.state.region}"
      encrypt = true
      kms_key_id = "${aws_kms_key.this.id}"
      dynamodb_table = "${aws_dynamodb_table.lock.id}"
      role_arn = "${var.aws_deploy_role}"
    }
  }
  EOT
}
