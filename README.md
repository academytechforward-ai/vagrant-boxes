# TechForward Academy Vagrant Boxes

Official Vagrant box repository for TechForward Academy training environments.

## Available Boxes

### Rocky Linux 9.8

- Box Name: `techforwardacademy/rocky9`
- Version: `1.0.0`
- Provider: VirtualBox
- Architecture: amd64
- Default User: `techforward`

## Student Setup

Create a folder:

```powershell
mkdir C:\techforward-rocky
cd C:\techforward-rocky
```

Create a file named `Vagrantfile` with:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "techforwardacademy/rocky9"
  config.vm.box_url = "https://github.com/academytechforward-ai/vagrant-boxes/releases/download/rocky9-v1.0.0/techforward-rocky9-1.0.0.box"

  config.ssh.username = "techforward"
  config.ssh.insert_key = false

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
  end
end
```

Start the VM:

```powershell
vagrant up
```

Connect:

```powershell
vagrant ssh
```

Stop the VM:

```powershell
vagrant halt
```

Delete the VM:

```powershell
vagrant destroy -f
```

## Requirements

- Vagrant
- Oracle VirtualBox
- Windows PowerShell

## Releases

Rocky Linux releases are published through GitHub Releases.

Current release: `rocky9-v1.0.0`
