provider "aws" {
  version = "~> 2.0"
  region  = "ca-central-1"
}

# Section for setting up S3 bucket, encrypted and with metrics for reporting
resource "aws_s3_bucket" "bcgovcapstorage" {
  bucket = "bcgovcapstorage"
  force_destroy = "true"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  tags = {
    project = "cap"
    environment = "poc"
  }
}

resource "aws_s3_bucket_metric" "bcgovcapstorage" {
  bucket = "${aws_s3_bucket.bcgovcapstorage.bucket}"
  name   = "EntireBucket"
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
            "Sid": "BucketList",
            "Effect": "Allow",
            "Action": [
                "s3:PutAccountPublicAccessBlock",
                "s3:GetAccountPublicAccessBlock",
                "s3:ListAllMyBuckets",
                "s3:HeadBucket"
            ],
            "Resource": "*"
        },
        {
            "Sid": "BucketAccess",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::bcgovcapstorage",
                "arn:aws:s3:::bcgovcapstorage/*"
            ]
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