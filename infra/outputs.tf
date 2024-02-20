# New resource outputs

output "distribution_domain_name" {
    value = aws_cloudfront_distribution.cloudfront.domain_name
}
