resource "aws_s3_bucket" "s3bucket" {
  bucket = var.bucket_name
  #acl = "public-read"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = merge(
    {
      "Name" = var.bucket_name
    },
    var.common_tag
  )

}

resource "aws_s3_bucket_public_access_block" "s3bucket_block_public" {
  bucket = aws_s3_bucket.s3bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets  = true
}

# Upload files to bucket
resource "aws_s3_bucket_object" "html" {

  for_each = fileset("bucketfiles/", "*.html")
  bucket = aws_s3_bucket.s3bucket.id
  key = each.value
  source = "bucketfiles/${each.value}"
  # etag: used to trigger updates
  etag = filemd5("bucketfiles/${each.value}")
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "png" {

  for_each = fileset("bucketfiles/", "*.png")
  bucket = aws_s3_bucket.s3bucket.id
  key = each.value
  source = "bucketfiles/${each.value}"
  # etag: used to trigger updates
  etag = filemd5("bucketfiles/${each.value}")
  content_type = "image/png"
}


data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "oai_s3_policy" {
  bucket = aws_s3_bucket.s3bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}
