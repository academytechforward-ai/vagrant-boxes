#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y \
  curl ca-certificates sudo openssh-server \
  virtualbox-guest-utils

# Configure the TechForward account
echo 'techforward ALL=(ALL) NOPASSWD:ALL' |
  sudo tee /etc/sudoers.d/90-techforward >/dev/null
sudo chmod 0440 /etc/sudoers.d/90-techforward
sudo visudo -cf /etc/sudoers.d/90-techforward

# Install Vagrant's standard initial public key
sudo mkdir -p /home/techforward/.ssh
curl --fail --location \
  https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub \
  -o /tmp/vagrant.pub

sudo install -m 600 /tmp/vagrant.pub \
  /home/techforward/.ssh/authorized_keys
sudo chown -R techforward:techforward \
  /home/techforward/.ssh
sudo chmod 700 /home/techforward/.ssh

# Disable password authentication for packaged VM
printf '%s\n' \
  'PasswordAuthentication no' \
  'KbdInteractiveAuthentication no' \
  | sudo tee /etc/ssh/sshd_config.d/00-techforward.conf

sudo sshd -t

# Prepare cloud-init for first boot after packaging
# Ensure the first boot after cloning uses SSH keys, not the installer password;
# allow cloud-init to rotate the SSH host keys for each independent VM.
printf '%s\n' \
  'ssh_pwauth: false' \
  'ssh_deletekeys: true' \
  | sudo tee /etc/cloud/cloud.cfg.d/99-techforward-ssh.cfg >/dev/null

sudo cloud-init clean --logs --machine-id

echo "TechForward provisioning completed"
