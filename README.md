# Terraform CloudFront to S3 with OAI and pre-signed URL

A CloudFront distibution for a s3 bucket with OAI and pre-signed URL.

Create a key pair for a trusted key group, before apply the terraform

```bash
openssl genrsa -out private_key.pem 2048

openssl rsa -pubout -in private_key.pem -out public_key.pem
```

# Sign the URL using the aws cli

Fill the correct values about parameters `url` and `key-pair-id`

```bash
$ aws cloudfront sign \
--url https://xxxxxx.cloudfront.net/beach.jpeg \
--key-pair-id KEY-PAIR-ID \
--private-key file://private_key.pem \
--date-less-than 2021-12-21
```

The result will be the signed url.

# Tip

Save the terraform state in a s3 bucket by creating a `backend.tf`

```
terraform {
  backend "s3" {
    bucket = "the-bucket-name"
    key    = "terraform-s3-static-website"
    region = "us-east-1"
  }
}
```
