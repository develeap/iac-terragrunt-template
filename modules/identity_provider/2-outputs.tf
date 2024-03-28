output "thumbprint_list" {
  value = data.tls_certificate.github.certificates.*.sha1_fingerprint
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "machine_public_ip" {
  value = chomp(data.http.machine_public_ip.response_body)
}

output "assume_role_with_web_identity_trust_policy" {
  value = data.aws_iam_policy_document.assume_role_with_web_identity_trust_policy.json
}