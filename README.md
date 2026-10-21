# Manual Docker vs. Terraform: Infrastructure as Code Comparison

## Project Overview

This project compares manual Docker deployment with Terraform-based infrastructure provisioning in a local environment.

The experiment uses a simple Nginx web server to evaluate deployment time, removal time, repeatability, execution errors, and infrastructure drift detection.

## Objectives

- Deploy the same infrastructure using manual Docker commands and Terraform.
- Measure and compare deployment and removal execution times.
- Evaluate repeatability through repeated deployments.
- Record errors encountered during the experiment.
- Demonstrate how Terraform detects infrastructure changes made outside its configuration.

## Technologies

- Docker Desktop
- Terraform
- Docker Provider (`kreuzwerker/docker`, version 4.2.0)
- Nginx (`1.27.5-alpine`)
- Windows PowerShell
- HTML

## Infrastructure

Both deployment methods use the same infrastructure:

- Docker network: `iac-lab-net`
- Docker container: `iac-lab-web`
- Nginx image: `nginx:1.27.5-alpine`
- Host port: `127.0.0.1:8080`
- Container port: `80`
- Static HTML page: `site/index.html`

The HTML file is mounted into the container as a read-only file.

## Project Structure

- `manual/commands.md` — Manual deployment, verification, and removal commands.
- `terraform/main.tf` — Terraform infrastructure configuration.
- `terraform/.terraform.lock.hcl` — Terraform provider dependency lock file.
- `site/index.html` — Static webpage used in both deployment methods.
- `README.md` — Project documentation.
- `.gitignore` — Files excluded from version control.

## Experimental Method

The experiment was conducted using two deployment methods: manual Docker commands and Terraform.

PowerShell's `Measure-Command` was used to measure execution times in seconds.

For manual Docker, deployment time included the execution of `docker network create` and `docker run`. Removal time included `docker rm -f` and `docker network rm`.

For Terraform, deployment time was measured using `terraform apply -auto-approve`, while removal time was measured using `terraform destroy -auto-approve`.

The `-auto-approve` option was used to avoid interactive confirmation delays during the timed trials.

Both deployment and removal procedures were repeated four times for each method.

Docker installation, Terraform initialization, and initial Nginx image downloading were excluded from the timed measurements.

After deployment, the Docker container and network were checked, and the webpage was verified separately using HTTP status code 200.

## Experimental Results

The following table presents the execution times recorded across four trials.

| Trial                  | Manual Deployment (s) | Manual Removal (s) | Terraform Deployment (s) | Terraform Removal (s) |
| ---------------------- | --------------------: | -----------------: | -----------------------: | --------------------: |
| 1                      |                2.1394 |             1.2054 |                   4.2549 |                6.0353 |
| 2                      |                1.7002 |             1.1308 |                   4.6251 |                5.8244 |
| 3                      |                1.6120 |             1.0339 |                   3.9842 |                5.5592 |
| 4                      |                1.8623 |             0.9880 |                   3.7965 |                5.6525 |
| **Mean**               |             **1.828** |          **1.090** |                **4.165** |             **5.768** |
| **Standard Deviation** |             **0.232** |          **0.098** |                **0.360** |             **0.209** |

### Statistical Analysis

The mean and sample standard deviation were calculated for deployment and removal times across four trials for each method.

The mean was calculated by summing the four execution times and dividing by the number of trials (n = 4).

The sample standard deviation was calculated to describe the variation in execution times between trials.

Results are expressed as mean ± standard deviation:

- Manual deployment: 1.828 ± 0.232 seconds.
- Manual removal: 1.090 ± 0.098 seconds.
- Terraform deployment: 4.165 ± 0.360 seconds.
- Terraform removal: 5.768 ± 0.209 seconds.

### Results Comparison

Manual Docker showed lower execution times than Terraform for both deployment and removal in this local experiment.

Terraform required additional time for operations such as planning, resource management, and state updates.

These results reflect the performance of the tested local environment and workload. They do not establish which method performs better in larger or more complex environments.

## Repeatability and Errors

Both methods successfully created the required Docker network and Nginx container across four recorded trials.

The webpage returned HTTP status code 200 during verification after each deployment.

The recorded trials did not show execution errors.

Both methods were able to repeat the deployment procedure using the same resource names, Nginx image, network configuration, and port mapping.

## Running the Experiment

### Manual Docker

Follow the deployment, verification, and removal instructions in `manual/commands.md`.

### Terraform

Open PowerShell in the `terraform` directory.

Initialize Terraform:

```powershell
terraform init
```

Validate the configuration:

```powershell
terraform validate
```

Deploy the infrastructure:

```powershell
terraform apply -auto-approve
```

Verify the running container:

```powershell
docker ps --filter "name=iac-lab-web"
```

Verify the webpage:

```powershell
Invoke-WebRequest http://localhost:8080 -UseBasicParsing |
    Select-Object StatusCode
```

The expected HTTP status code is `200`.

Remove the infrastructure:

```powershell
terraform destroy -auto-approve
```

## Infrastructure Drift

Infrastructure drift was tested by manually deleting the Terraform-managed Nginx container while leaving the Terraform configuration unchanged.

After the container was deleted, the following command was executed:

```powershell
terraform plan
```

Terraform detected the missing container and proposed recreating it.

The output showed:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

The Docker image and network remained available, so Terraform did not propose recreating them.

This demonstrated Terraform's ability to detect a manual infrastructure change and generate a plan to restore the declared configuration.

## Scope and Limitations

The experiment was conducted locally using Docker Desktop on a Windows computer.

The study focused on a simple Nginx web server and did not include cloud deployment, cloud service charges, or large-scale infrastructure.

Execution time measurements included command execution but excluded webpage verification time and human preparation time.

The results are limited to the tested environment and four trials per method.
