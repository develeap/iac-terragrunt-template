###########################
# OpenID Connent - Github #
###########################
resource "aws_iam_openid_connect_provider" "github" {
  client_id_list  = ["${local.aws_sts}"]
  tags            = local.tags_all
  tags_all        = local.tags_all
  thumbprint_list = local.thumbprints
  url             = local.url
}