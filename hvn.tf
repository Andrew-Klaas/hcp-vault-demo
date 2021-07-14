resource "hcp_hvn" "example_hvn" {
  hvn_id         = "${var.Name}-example-hvn"
  cloud_provider = "aws"
  region         = var.region
  cidr_block     = var.hvn_cidr
}

resource "hcp_vault_cluster" "example_vault_cluster" {
  hvn_id     = hcp_hvn.example_hvn.hvn_id
  cluster_id = "${var.Name}-vault-cluster"
  public_endpoint = false
  tier = "dev"
}

resource "hcp_vault_cluster_admin_token" "example_vault_admin_token" {
  cluster_id = hcp_vault_cluster.example_vault_cluster.cluster_id
}

resource "aws_ec2_transit_gateway" "example" {
}

resource "aws_ram_resource_share" "example" {
  name                      = "example-resource-share"
  allow_external_principals = true
}

resource "aws_ram_principal_association" "example" {
  resource_share_arn = aws_ram_resource_share.example.arn
  principal          = hcp_hvn.example_hvn.provider_account_id
}

resource "aws_ram_resource_association" "example" {
  resource_share_arn = aws_ram_resource_share.example.arn
  resource_arn       = aws_ec2_transit_gateway.example.arn
}

resource "hcp_aws_transit_gateway_attachment" "example" {
  depends_on = [
    aws_ram_principal_association.example,
    aws_ram_resource_association.example,
  ]

  hvn_id                        = hcp_hvn.example_hvn.hvn_id
  transit_gateway_attachment_id = "${var.Name}-tgw-attachment"
  transit_gateway_id            = aws_ec2_transit_gateway.example.id
  resource_share_arn            = aws_ram_resource_share.example.arn
}

resource "hcp_hvn_route" "route" {
  hvn_link         = hcp_hvn.example_hvn.self_link
  hvn_route_id     = "${var.Name}-hvn-to-tgw-attachment"
  destination_cidr = aws_vpc.example.cidr_block
  target_link      = hcp_aws_transit_gateway_attachment.example.self_link
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "example" {
  transit_gateway_attachment_id = hcp_aws_transit_gateway_attachment.example.provider_transit_gateway_attachment_id
}

