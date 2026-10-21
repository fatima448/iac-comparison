# Manual Docker Deployment

## Overview

This document describes the manual Docker commands used to deploy and remove the Nginx web server for the Infrastructure as Code comparison experiment.

The manual deployment creates a Docker network and an Nginx container. The container serves a static HTML page through port 8080.

## 1. Prerequisites

- Docker Desktop installed and running
- Nginx image (`nginx:1.27.5-alpine`) available locally
- HTML file located at `site/index.html`

## 2. Deployment

The following PowerShell commands were used to measure the combined execution time of network and container creation.

```powershell
Measure-Command {
    docker network create iac-lab-net

    docker run -d `
        --name iac-lab-web `
        --network iac-lab-net `
        -p 127.0.0.1:8080:80 `
        --mount "type=bind,source=$((Resolve-Path ../site/index.html).Path),target=/usr/share/nginx/html/index.html,readonly"
        nginx:1.27.5-alpine
} | Select-Object TotalSeconds
```

## 3. Verification

The deployed resources were checked using:

```powershell
docker ps --filter "name=iac-lab-web"
docker network ls --filter "name=iac-lab-net"
```

The webpage was verified using:

```powershell
Invoke-WebRequest http://localhost:8080 -UseBasicParsing |
    Select-Object StatusCode
```

An HTTP status code of 200 indicates that the server responded successfully.

## 4. Removal

The following commands were used to measure removal time:

```powershell
Measure-Command {
    docker rm -f iac-lab-web
    docker network rm iac-lab-net
} | Select-Object TotalSeconds
```

## 5. Repeatability

The deployment and removal procedures were repeated for the recorded experimental trials. Execution times were collected for comparison with Terraform.

The commands were executed manually through PowerShell rather than through an automated deployment script.
