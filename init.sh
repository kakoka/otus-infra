#!/bin/bash

eval $(ssh-agent -s)
ssh-add ~/.ssh/otus-user

CATALOG=seism
TOKEN=$(yc config list | grep 'token:' | cut -d' ' -f2)
CLOUD_ID=$(yc config list | grep 'cloud-id' | cut -d' ' -f2)
FOLDER_ID=$(yc config list | grep 'folder-id:' | cut -d' ' -f2)
COMPUTE_ZONE=$(yc config list | grep 'compute-default-zone:' | cut -d' ' -f2)
OTUS_USER_PUB_KEY=$(cat ~/.ssh/otus-user.pub)

cat > bootstrap/metadata.yml << EOF
#cloud-config
users:
  - name: otus-user
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - $OTUS_USER_PUB_KEY
disable_root: true
timezone: Europe/Moscow
repo_update: true
repo_upgrade: true
yum:
  preserve_sources_list: true

write_files:
    - path: /etc/environment
      permissions: 0644
      content: |
        http_proxy=http://bastion:8888
        https_proxy=http://bastion:8888
runcmd:
  - sh -c "echo 'proxy=http://bastion:8888' >> /etc/yum.conf"
  - yum install -y epel-release
EOF

cat > providers.tf << EOM
provider "yandex" {
  token = "$TOKEN"
  cloud_id = "$CLOUD_ID"
  folder_id = "$FOLDER_ID"
  zone = "$COMPUTE_ZONE"
}
EOM

# create service user
# yc iam service-account create --name otus-user
# get secret key for service user
# yc iam access-key create --service-account-name otus-user > otus-user.creds
# set access rights for service user to catalog
# yc resource-manager folder add-access-binding $CATALOG --role editor --subject serviceAccount:$(cat otus-user.creds | grep 'service_account_id' | cut -d' ' -f4)

# echo "Waiting"
# for i in {1..45};do sleep 1; echo -ne '.';done

terraform init \
  -backend-config="access_key=$(cat otus-user.creds | grep 'key_id' | cut -d' ' -f4)" \
  -backend-config="secret_key=$(cat otus-user.creds | grep 'secret' | cut -d' ' -f2)" \
  -backend-config="bucket=otus-infra"

terraform import yandex_vpc_network.my-network $(yc vpc network get my-network --format json | jq -r '.id')
terraform import yandex_vpc_subnet.my-subnet $(yc vpc subnet get my-subnet --format json | jq -r '.id')

# rm -f otus-user.creds
