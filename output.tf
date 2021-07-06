output "id" {
  description = "The identifier for the distribution"
  value = aws_cloudfront_distribution.s3_distribution.id
}

output "trusted_signers" {
   description = "List of nested attributes for active trusted signers, if the distribution is set up to serve private content with signed URLs"
   value = aws_cloudfront_distribution.s3_distribution.trusted_signers
}

output "domain_name" {
  description = "The domain name corresponding to the distribution."
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
