# New resource outputs

output "distribution_domain_name" {
    value = aws_cloudfront_distribution.cloudfront.domain_name
}

output "distribution_id" {
    value = aws_cloudfront_distribution.cloudfront.id
}

output "bucket_id" {
    value = aws_s3_bucket.bucket.id
}

output "bucket_region" {
    value = aws_s3_bucket.bucket.region
}