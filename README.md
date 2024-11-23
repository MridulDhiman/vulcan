### Simple scaffolding tool

1. Terraform config.
    - Provision EC2 with Application load balancer config. and auto scaling group setup
    ```bash
    vulcan <project-name> terraform/ec2-alb-asg
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
    - Manual Production Deployment to EKS Cluster through Github Actions
    ```bash
    vulcan .github/workflows ci/deploy-to-eks
    ```
