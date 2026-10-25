# Manual Docker vs. Terraform: Infrastructure as Code Comparison

SEN421 Cloud Architecture and Services, Fall 2026, Istanbul Aydın University.
Topic 7 (Part A). Author: Fatima Alfurais.

## Project Overview

This project compares manual Docker deployment with Terraform-based provisioning
of the same local environment. It evaluates deployment time, removal time,
repeatability, setup effort, and infrastructure drift detection, using a single
Nginx container serving a static HTML page.

## Technologies

- Windows 11, PowerShell, Docker Desktop (Docker Engine v29.6.2)
- Terraform v1.16.5, provider `kreuzwerker/docker` v4.2.0
- Nginx `1.27.5-alpine`

## Infrastructure (identical for both methods)

- Docker network: `iac-lab-net`
- Container: `iac-lab-web`
- Image: `nginx:1.27.5-alpine`
- Port mapping: `127.0.0.1:8080` -> container port `80`
- `site/index.html` mounted read-only at `/usr/share/nginx/html/index.html`

## Repository Structure

| Path | Content |
|---|---|
| `site/index.html` | Static page used by both methods |
| `manual/commands.md` | Manual deployment, verification, and removal commands |
| `terraform/main.tf` | Terraform configuration (image, network, container) |
| `terraform/.terraform.lock.hcl` | Provider version lock file |
| `results/timings.csv` | Raw timings of all trials (seconds) |
| `.gitignore` | Excludes Terraform state and provider cache |

## Experimental Method

- Times were measured with PowerShell `Measure-Command`, in seconds.
- Manual deployment: `docker network create` + `docker run`.
  Manual removal: `docker rm -f` + `docker network rm`.
- Terraform deployment: `terraform apply -auto-approve`.
  Terraform removal: `terraform destroy -auto-approve`.
- `-auto-approve` avoids interactive prompts during timed runs.
- Each method was deployed and removed **six times**.
- Excluded from timing: tool installation, `terraform init`, the first image
  pull, and webpage verification.
- After each deployment the webpage was checked separately (HTTP 200).
- The trials were run manually in PowerShell, not by an automated script.

## Results (mean ± sample standard deviation, n = 6)

| Method | Deployment (s) | Removal (s) |
|---|---:|---:|
| Manual Docker | 7.727 ± 2.859 | 4.944 ± 1.669 |
| Terraform | 15.571 ± 3.245 | 12.365 ± 3.335 |

Terraform was slower than manual Docker in all six trials for both operations.
Raw values are in `results/timings.csv`. These results apply only to this small
single-container environment on one laptop and do not show which method is
faster in larger environments.

## Repeatability and Errors

All 12 recorded deployments created the network and container and returned
HTTP 200. No execution errors occurred in the recorded trials.
[Add here any problem from results/time_log.txt that happened during preparation.]

## Running the Experiment

All commands are run from the repository root in PowerShell.

### Manual Docker

See `manual/commands.md`.

### Terraform

```powershell
terraform "-chdir=terraform" init
terraform "-chdir=terraform" validate
Measure-Command { terraform "-chdir=terraform" apply -auto-approve }
docker ps --filter "name=iac-lab-web"
(Invoke-WebRequest http://localhost:8080 -UseBasicParsing).StatusCode   # expect 200
Measure-Command { terraform "-chdir=terraform" destroy -auto-approve }
```

## Infrastructure Drift Test

After `terraform apply`, the Terraform-managed container was deleted manually:

```powershell
docker rm -f iac-lab-web
terraform "-chdir=terraform" plan
```

Terraform detected the missing container and proposed recreating only that
resource: `Plan: 1 to add, 0 to change, 0 to destroy.` The image and network
were unchanged. The plan was inspected but not applied. The detection and
recreation times were not measured.

## Scope and Limitations

- Local Docker Desktop on one Windows laptop; no cloud provider and no cloud charges.
- One simple Nginx container; larger environments were not tested.
- Timings cover command execution only and exclude verification and human
  preparation time.
- Timings varied considerably between trials (standard deviation was 21-37% of the mean).

## Notes

- Terraform state files and the `.terraform/` cache are not committed.
- No secrets or personal data are used. The port is bound to localhost only.