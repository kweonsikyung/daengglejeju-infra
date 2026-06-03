output "ec2_public_ip" {
  description = "k3s 노드 Elastic IP"
  value       = aws_eip.k3s.public_ip
}

output "cloudfront_domain" {
  description = "CloudFront 배포 도메인"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

# 가비아에서 이 NS 레코드로 네임서버 변경 필요
output "route53_nameservers" {
  description = "가비아 네임서버를 이 값으로 변경하세요"
  value       = aws_route53_zone.main.name_servers
}
