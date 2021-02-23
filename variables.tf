variable "domain_name" {
  description = "The (sub)domain that you want to use for your PyPi repository (e.g. pypi.yourcompany.com)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ACM Certificate ARN that covers your PyPi domain"
  type        = string
}

variable "logging" {
  description = "whether s3 logging should be enabled or disabled. By default it is enabled."
  type        = bool
  default     = true
}

variable "tags" {
  default     = {}
  description = "Key-value map of tags"
  type        = map(any)
}

variable "log_bucket_id" {
  description = "The bucket to log S3 logs to. Required if Logging is enabled"
  type        = string
  default     = ""
}

variable "add_cloudfront_records" {
  description = "If true, adds Cloudfront Alias record in the DNS"
  type        = bool
  default     = false
}

variable "whitelist_ips" {
  description = "Whitelist IPs to access pypi repo"
  type        = list(string)
  default     = []
}