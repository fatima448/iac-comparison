# Manual Docker Deployment

All commands are run from the **repository root** in PowerShell, with Docker
Desktop running.

## Overview

This document lists the manual Docker commands used to deploy, verify, and
remove the Nginx environment for the Infrastructure as Code comparison. The
deployment creates a Docker network and an Nginx container serving
`site/index.html` on port 8080.

## 0. Preparation (not timed)

```powershell
docker pull nginx:1.27.5-alpine
```

## 1. Deployment (timed)

```powershell
$site = (Resolve-Path .\site\index.html).Path

Measure-Command {
    docker network create iac-lab-net

    docker run -d `
        --name iac-lab-web `
        --network iac-lab-net `
        -p 127.0.0.1:8080:80 `
        --mount "type=bind,source=$site,target=/usr/share/nginx/html/index.html,readonly" `
        nginx:1.27.5-alpine
} | Select-Object TotalSeconds
```

## 2. Verification (not timed)

```powershell
docker ps --filter "name=iac-lab-web"
docker network ls --filter "name=iac-lab-net"
(Invoke-WebRequest http://localhost:8080 -UseBasicParsing).StatusCode
docker stats --no-stream iac-lab-web
```

An HTTP status code of 200 indicates that the server responded successfully.

## 3. Removal (timed)

```powershell
Measure-Command {
    docker rm -f iac-lab-web
    docker network rm iac-lab-net
} | Select-Object TotalSeconds
```

## 4. Confirm cleanup

```powershell
docker ps -a --filter "name=iac-lab-web"
docker network ls --filter "name=iac-lab-net"
```

Both commands should show no matching resources.

## 5. Repeatability

Deployment and removal were repeated six times. Timings are in
`results/timings.csv`. The commands were run manually in PowerShell, not
through an automated script.

## Mistakes and troubleshooting

[Copy from results/time_log.txt. If nothing went wrong, write:
"No errors occurred during the recorded trials."]