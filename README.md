# TechForward Academy Vagrant Boxes

Official Vagrant box repository for TechForward Academy training environments.

## Production Catalog

| Environment | Box | Version | Provider | Default User |
|---|---|---:|---|---|
| Rocky Linux 9 | `techforwardacademy/rocky9` | `1.0.1` | VirtualBox | `techforward` |
| Windows Server 2025 | `techforwardacademy/windows2025` | `1.0.0` | VirtualBox | `techforward` |
| Ubuntu Server 22.04 | `techforwardacademy/ubuntu2204` | `1.0.2` | VirtualBox | `techforward` |
| Kali Linux Rolling | `techforwardacademy/kali` | `1.0.0` | VirtualBox | `techforward` |

## Delivery Architecture

Production box binaries and Vagrant metadata are delivered from:

`https://boxes.techforward.ai`

Student Vagrantfiles are maintained under the `student/` directory in this repository.

## Student Runtime Standard

- Oracle VirtualBox 7.2.14
- Vagrant 2.4.9
- Windows PowerShell or another supported terminal
- VMs run headless by default (`vb.gui = false`)

### Ubuntu 22.04 v1.0.2 SSH and Windows drive note

Ubuntu 22.04 v1.0.2 automatically replaces Vagrant's shared bootstrap SSH key with a unique key per VM (`config.ssh.insert_key = true`). Password-based SSH authentication is disabled.

**On Windows, before `vagrant up` from an exFAT/external working drive**, set `VAGRANT_DOTFILE_PATH` to an NTFS directory on C: so Windows OpenSSH can enforce private-key permissions:

```powershell
# Choose a unique state directory for each separate Vagrant project.
$env:VAGRANT_DOTFILE_PATH = "$env:LOCALAPPDATA\TechForward\VagrantState\ubuntu2204"
vagrant up
```

Keep the same `VAGRANT_DOTFILE_PATH` when running `vagrant ssh`, `vagrant reload`, or `vagrant destroy` in that project. For `student/multi/Vagrantfile`, use a different state directory (for example `...\VagrantState\multi-lab`).

The single-Ubuntu Vagrantfile has a `10.9.8.XX` private-network IP placeholder; replace `XX` with a suitable unused address before running `vagrant up`.

## Multi-VM Lab

`student/multi/Vagrantfile` can launch multiple Rocky, Ubuntu, Windows Server, and Kali instances from one lab definition. Change the platform counts at the top of the file to scale the environment.
