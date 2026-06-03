variable "aws_region" {
  description = "AWS 기본 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "project" {
  description = "프로젝트명 — 리소스 이름 prefix로 사용"
  type        = string
  default     = "daengglejeju"
}

variable "domain" {
  description = "서비스 도메인"
  type        = string
  default     = "daengglejeju.cloud"
}

variable "ec2_instance_type" {
  description = "k3s 노드 인스턴스 타입"
  type        = string
  default     = "t3.small"
}

variable "ec2_ami" {
  description = "Ubuntu 24.04 LTS AMI (ap-northeast-2)"
  type        = string
  default     = "ami-042e76978adeb8c48"
}

variable "ssh_public_key" {
  description = "EC2 SSH 접속용 공개키"
  type        = string
  sensitive   = true
}
