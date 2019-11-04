provider "aws" {
  version = "~> 2.0"
  region  = "ca-central-1"
}

# Section for setting up KMS key and S3 bucket encrypted with that key
resource "aws_kms_key" "bcgovcapkey" {
  description             = "This key is used to encrypt bucket objects for bcgovcapstorage"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "bcgovcapstorage" {
  bucket = "bcgovcapstorage"
  force_destroy = "true"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.bcgovcapkey.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    project = "cap"
    environment = "poc"
  }
}

# Create user and access key for reading/writing into the S3 bucket
resource "aws_iam_user" "bcgovcapstorage" {
  name = "bcgovcapstorage"

  tags = {
    project = "cap"
    environment = "poc"
  }
}

resource "aws_iam_access_key" "bcgovcapstorage" {
  user = "${aws_iam_user.bcgovcapstorage.name}"
}

# Create and attach policy to limit full object access to the bcgovcapstorage bucket
resource "aws_iam_policy" "bcgovcapstorage-owner" {
  name        = "bcgovcapstorage-owner"
  description = "Provides full access to bcgovcapstorage S3 bucket"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListAllBuckets",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::bcgovcapstorage"
            ]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": [
                "arn:aws:s3:::bcgovcapstorage/*"
            ]
        },
        {
            "Sid": "KeyAccessForEncryption",
            "Effect": "Allow",
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "arn:aws:kms:::key/${aws_kms_key.bcgovcapkey.key_id}"
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "attach-policy" {
  user       = "${aws_iam_user.bcgovcapstorage.name}"
  policy_arn = "${aws_iam_policy.bcgovcapstorage-owner.arn}"
}


output "access_key" {
  value = "${aws_iam_access_key.bcgovcapstorage.id}"
}

output "secret_key" {
  value = "${aws_iam_access_key.bcgovcapstorage.secret}"
}