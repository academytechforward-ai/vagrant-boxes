# Ubuntu 22.04 — TechForward VirtualBox Vagrant box source

These are the source templates needed to rebuild the Ubuntu 22.04.5 Server VM from the official ISO with HashiCorp Packer. The independently validated and publicly distributed Ubuntu box is `techforwardacademy/ubuntu2204` version `1.0.2`. **Do not overwrite an already published `.box` version.** The Packer post-processor deliberately creates `output/techforward-ubuntu2204-candidate.box` for validation.

## Requirements

- Windows PowerShell, Packer and its `hashicorp/virtualbox` / `hashicorp/vagrant` plugins
- Oracle VirtualBox
- WSL Ubuntu with `openssl` installed (used only for generating a unique salted installer password hash)
- The official `ubuntu-22.04.5-live-server-amd64.iso`, placed in `iso/`. The SHA-256 is checked by Packer.

## Build

1. Check out this folder from GitHub and place the ISO at `iso/ubuntu-22.04.5-live-server-amd64.iso`.
2. From **Windows PowerShell**, run `./build.ps1` in this directory.
3. Enter a **unique temporary** installer password at the prompt. The build generates `http/user-data` from the checked-in template, passes the password to Packer as a sensitive environment variable, and removes the temporary response file and environment variable after the build (including failure paths).
4. Wait for the build and Vagrant post-processing to finish; don't interrupt export.
5. Import the candidate box using a temporary local name. Validate initial boot, Vagrant SSH key rotation, passwordless sudo, `sshd -T` (`passwordauthentication no`, `kbdinteractiveauthentication no`), shared folder, and `vagrant reload` before release.

**Why the installer enables password login briefly:** Packer needs a bootstrap SSH credential to provision the base image. Ubuntu autoinstall `late-commands` installs the passwordless sudo policy in `/target/etc/sudoers.d/90-techforward`, so provisioning can run unattended. The `scripts/setup.sh` final hardening must disable password authentication with a `00-*.conf` SSH override that precedes `50-cloud-init.conf`; cloud-init must be prepared to regenerate instance-specific settings. Never publish a box if that final hardening fails.

## Source boundaries

- `ubuntu2204.pkr.hcl`: VirtualBox installation, SSH communicator, and nonrelease candidate output.
- `http/user-data.template`: Ubuntu autoinstall; hashed password is generated per build.
- `http/meta-data`: NoCloud install seed metadata.
- `scripts/setup.sh`: image provisioning and SSH hardening.
- `box.Vagrantfile`: default Vagrant SSH username and machine-specific bootstrap key rotation.
- `build.ps1`: unattended Packer build wrapper and temporary credential handling.
- `.gitignore`: excludes the temporary `http/user-data`, ISO, generated `.box`, virtual disks and Packer output.

## Caveats

- The existing published v1.0.2 image was validated separately (including a public Cloudflare download). Its original first run required manual sudo bootstrap and a recovered VM repackaging process. This source-code improvement needs a new **full Packer rebuild and independent VM validation** before it may be considered an end-to-end reproducible replacement.
- On Windows exFAT work drives, set a unique `VAGRANT_DOTFILE_PATH` under `%LOCALAPPDATA%` on the NTFS system drive before running validation with `config.ssh.insert_key = true`.
- Packer provisioner credentials are temporary and distinct from learner VM-specific SSH keys; do not record build passwords, hashes, keys, or generated autoinstall files in Git.
