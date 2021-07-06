resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI about s3 bucket ${var.bucket_name}"
}

#
# Amazon CloudFront adds support for configurable origin connection attempts and origin connection timeout #13729
# https://github.com/hashicorp/terraform-provider-aws/issues/13729
#
# Support the use of CloudFront Trusted Key Group as a signer #15912
# https://github.com/hashicorp/terraform-provider-aws/issues/15912
#
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3bucket.bucket_regional_domain_name
    origin_id   = "S3-${var.bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }

    custom_header {
      name = "X-Repo"
      value = var.bucket_name
    }

  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "${var.lab_name} cloudfront s3 distribution"
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["BR"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    trusted_key_groups = [aws_cloudfront_key_group.cf_keygroup.id]
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code = 403
    response_code = 403
    response_page_path = "/error.html"
  }

  tags = var.common_tag
}

resource "aws_cloudfront_public_key" "my_public_key" {
  comment     = "signed url public key"
  encoded_key = file("public_key.pem")
  name        = "my_public_key"
}

resource "aws_cloudfront_key_group" "cf_keygroup" {
	items = [aws_cloudfront_public_key.my_public_key.id]
	name  = "mycf_trusted_keygroup"
}