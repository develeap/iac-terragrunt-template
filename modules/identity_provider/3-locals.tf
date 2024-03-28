locals {
  aws_sts     = "sts.amazonaws.com"
  url         = "https://${var.github_url}"
  thumbprints = data.tls_certificate.github.certificates.*.sha1_fingerprint
  tags_all = merge(
    var.tags,
    { Terraform = "True", Name = "${var.github_url}" }
  )
}