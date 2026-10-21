# Windows PowerShell 5.1+ with Packer, WSL Ubuntu, and OpenSSL in WSL.
# Prompts for a unique temporary installer password; never commits the hash or secret.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$installerPath = Join-Path $root 'http\user-data'
Push-Location $root
try {
    foreach ($exe in @('packer', 'wsl.exe')) {
        if (-not (Get-Command $exe -ErrorAction SilentlyContinue)) {
            throw "Required command not found: $exe"
        }
    }
    if (-not (Test-Path 'iso\ubuntu-22.04.5-live-server-amd64.iso')) {
        throw 'Put the official Ubuntu 22.04.5 live-server ISO under iso\ first.'
    }
    if (-not (Test-Path 'scripts\setup.sh')) {
        throw 'Missing provisioning source: scripts\setup.sh'
    }
    $securePassword = Read-Host 'Enter a unique TEMPORARY Packer installer password' -AsSecureString
    $credential = New-Object System.Management.Automation.PSCredential('techforward', $securePassword)
    $password = $credential.GetNetworkCredential().Password
    if ([string]::IsNullOrWhiteSpace($password)) { throw 'A nonempty password is required.' }

    # OpenSSL computes a salted SHA-512 crypt password hash for Ubuntu autoinstall.
    $hash = ($password | & wsl.exe openssl passwd -6 -stdin)
    if ($LASTEXITCODE -ne 0 -or -not ($hash -match '^\$6\$')) {
        throw 'WSL OpenSSL did not return a SHA-512 crypt password hash.'
    }
    $template = [System.IO.File]::ReadAllText((Join-Path $root 'http\user-data.template'))
    $placeholder = '__GENERATED_PASSWORD_HASH__'
    if (-not $template.Contains($placeholder)) { throw 'Autoinstall template lacks password placeholder.' }
    [System.IO.File]::WriteAllText($installerPath, $template.Replace($placeholder, $hash), (New-Object System.Text.UTF8Encoding($false)))

    $env:PKR_VAR_build_password = $password
    & packer init .
    if ($LASTEXITCODE -ne 0) { throw 'packer init failed' }
    & packer validate .
    if ($LASTEXITCODE -ne 0) { throw 'packer validate failed' }
    & packer build .
    if ($LASTEXITCODE -ne 0) { throw 'packer build failed' }
    Write-Host 'Build completed. Validate the candidate box before assigning a release version.'
} finally {
    Remove-Item Env:PKR_VAR_build_password -ErrorAction SilentlyContinue
    Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
    $password = $null
    $hash = $null
    $credential = $null
    $securePassword = $null
    Pop-Location
}
