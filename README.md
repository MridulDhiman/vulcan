## Simple scaffolding tool

- [Installation](#installation)
- [Reference](#reference)
- [Create Your Own Templates](#create-your-own-custom-templates)
### Installation

- Clone the repository

```bash
git clone https://github.com/MridulDhiman/vulcan.git
```

- Install `make` in your application using `chocolatey` in windows, and using Homebrew in Linux, MacOS.

```bash
choco install make ## Windows
brew install make ### MacOS
```

- Build the binary of our application

```bash
make build
```

- Follow the reference and scaffold your templates 😁.

### Reference

1. Terraform config.
    - Provision EC2 with Application load balancer config. and auto scaling group setup
    ```bash
    vulcan <project-name> terraform/ec2-alb-asg
    ```
    - Provision EC2 instance with EBS volume
    ```bash
    vulcan <project-name> terraform/ec2-ebs
    ```

2. Docker Config. 
    - Containerize Express javascript application
    ```bash
    vulcan <project-name> docker/express-ts
    ```
    - Containerize Express javascript application
    ```bash
    vulcan <project-name> docker/express
    ```

3. CI config.
    - Build docker image and publish to docker hub on each push
    ```bash
    vulcan .github/workflows ci/publish-to-dockerhub
    ```
    - Manual Production Deployment to EKS Cluster through Github Actions Dashboard
    ```bash
    vulcan .github/workflows ci/deploy-to-eks
    ```

3. Python related
    - `__init__.py` in your directory 
    ```bash
    vulcan <directory-name> python/init
    ```

### Create Your Own Custom Templates

Just create New Folder based on the template like CI, Docker, terraform etc. and create specific templates that you want to scaffold in your local system.
