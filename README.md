# Simple HCP Vault demo
This demo connects an EC2 instance to HCP via a transit gateway.

1. Create an HCP account and service principal credentials for the HVN provider:
https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/guides/auth

2. fill out terraform.tfvars

3. terraform plan;

4. terraform apply;

5. SSH into your newly provisioned machine using the output from the apply. 
```bash
PUBLIC_IP = "55.199.335.319"
VAULT_ADDR = "https://demo-vault-cluster.private.vault.......63.aws.hashicorp.cloud:8200"
```

6. Set the Vault address
```
$ export VAULT_ADDR="https://demo-vault-cluster.private.vault.......63.aws.hashicorp.cloud:8200"
```

7. Run Vault status
```bash
$ vault status
Key                      Value
---                      -----
Recovery Seal Type       shamir
Initialized              true
Sealed                   false
Total Recovery Shares    1
Threshold                1
Version                  1.7.3+ent
Storage Type             raft
Cluster Name             vault-cluster-411134ac
Cluster ID               9de2b307-b512-df16-1d7e-7347a08c95c7
HA Enabled               true
HA Cluster               https://172.25.17.216:8201
HA Mode                  active
Active Since             2021-07-15T14:46:19.053608784Z
Raft Committed Index     980
Raft Applied Index       980
Last WAL                 269
```