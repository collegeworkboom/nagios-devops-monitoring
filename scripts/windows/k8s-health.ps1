# Checks whether the nginx-demo deployment has all desired replicas ready.
# Update the kubectl path and deployment name for your environment.
$ErrorActionPreference = "SilentlyContinue"
$kubectl = Join-Path $env:LOCALAPPDATA "Programs\DockerDesktop\resources\bin\kubectl.exe"
$deployment = "nginx-demo"

if (-not (Test-Path $kubectl)) {
    Write-Output "CRITICAL - kubectl executable not found at configured path"
    exit 2
}

$desired = & $kubectl get deployment $deployment -o "jsonpath={.spec.replicas}" 2>$null
if ($LASTEXITCODE -ne 0 -or $null -eq $desired -or "$desired" -eq "") {
    Write-Output "CRITICAL - Cannot read Kubernetes deployment"
    exit 2
}

$ready = & $kubectl get deployment $deployment -o "jsonpath={.status.readyReplicas}" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Output "CRITICAL - Cannot read Kubernetes ready replicas"
    exit 2
}

if ("$ready" -eq "") { $ready = 0 }

if ([int]$ready -lt [int]$desired) {
    Write-Output "WARNING - Kubernetes replicas ready: $ready/$desired"
    exit 1
}

Write-Output "OK - Kubernetes replicas ready: $ready/$desired"
exit 0
