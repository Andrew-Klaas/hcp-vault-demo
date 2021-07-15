#!/bin/bash
set -v
echo "beginning init"
sudo apt-get update
sudo apt-get install -y vim
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vault
echo "end init"
