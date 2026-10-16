# TechForward Academy Vagrant Boxes

Official Vagrant box repository for TechForward Academy training environments.

## Production Catalog

| Environment | Box | Version | Provider | Default User |
|---|---|---:|---|---|
| Rocky Linux 9 | `techforwardacademy/rocky9` | `1.0.1` | VirtualBox | `techforward` |
| Windows Server 2025 | `techforwardacademy/windows2025` | `1.0.0` | VirtualBox | `techforward` |
| Ubuntu Server 22.04 | `techforwardacademy/ubuntu2204` | `1.0.0` | VirtualBox | `techforward` |

## Delivery Architecture

Production box binaries and Vagrant metadata are delivered from:

`https://boxes.techforward.ai`

Student Vagrantfiles are maintained under the `student/` directory in this repository.

## Student Runtime Standard

- Oracle VirtualBox 7.2.14
- Vagrant 2.4.9
- Windows PowerShell or another supported terminal
- VMs run headless by default (`vb.gui = false`)
