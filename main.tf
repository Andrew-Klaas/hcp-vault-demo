// Credentials can be set explicitly or via the environment variables HCP_CLIENT_ID and HCP_CLIENT_SECRET
provider "hcp" {
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Name  = var.Name
      owner = var.owner
      TTL   = var.TTL 
    }
  }
}














