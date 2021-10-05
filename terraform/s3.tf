resource "aws_s3_bucket" "code_bucket" {
  bucket_prefix = "${var.prefix}-"
  lifecycle_rule {
    id                                     = "lifecycle-rule"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 1
    expiration {
      days = 1
    }
    noncurrent_version_expiration {
      days = 1
    }
  }
  tags = var.tags
}