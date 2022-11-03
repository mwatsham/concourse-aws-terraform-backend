kms_key_alias = "dummy-tf-state-bucket-key"
kms_key_replica_alias = "dummy-tf-state-bucket-key-replica"
kms_key_deletion_window_in_days = 7

override_s3_bucket_name = true
s3_bucket_name = "dummy-tf-state-bucket"
s3_bucket_name_replica = "dummy-tf-state-bucket-replica"
s3_bucket_force_destroy = true

override_terraform_iam_policy_name = true
terraform_iam_policy_name = "dummy-tf-state-bucket-policy"

override_iam_policy_name = true
iam_policy_name = "dummy-tf-state-bucket-replica-policy"

override_iam_role_name = true
iam_role_name = "dummy-tf-state-bucket-replica-role"
iam_policy_attachment_name = "dummy-tf-state-bucket-policy-attachment"

dynamodb_table_name = "dummy-tf-remote-state-lock"
dynamodb_enable_server_side_encryption = true
