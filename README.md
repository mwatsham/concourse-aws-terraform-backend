# concourse-aws-terraform-backend
## Introduction
This repo contains the [Concourse CI](https://concourse-ci.org/) code for setting up a [Terraform State Backend in AWS](https://developer.hashicorp.com/terraform/language/settings/backends/s3).

The intention is that these S3 state buckets and DynamoDB locking tables can be reused as a common Terraform State Backend for other Terraform deployments.

This repo defines and records the backends it has been used to setup, being able to setup new state backends from scratch and also managing previous deployments.

## Dependancies
###  mwatsham/terraform-aws-backend
Terraform module geared specifically toward setting up a [Terraform State Backend in AWS](https://developer.hashicorp.com/terraform/language/settings/backends/s3).

This code base reuses https://registry.terraform.io/modules/nozaq/remote-state-s3-backend/aws/latest.

>"Features...
  >* Create a S3 bucket to store remote state files.
  >* Encrypt state files with KMS.
  >* Enable bucket replication and object versioning to prevent accidental data loss.
  >* Automatically transit non-current versions in S3 buckets to AWS S3 Glacier to optimize the storage cost.
  >* Optionally you can set to expire aged non-current versions(disabled by default).
  >* Optionally you can set fixed S3 bucket name to be user friendly(false by default).
  >* Create a DynamoDB table for state locking, encryption is optional.
  >* Optionally create an IAM policy to allow permissions which Terraform needs."

#### Provider dependancy
The Terraform module `mwatsham/terraform-aws-backend` depends upon Terraform provider...
  * aws (hashicorp/aws) >= 4.3

### Credential management
The code assumes that Concourse CI has been configured to use an external [cluster-wide credential manager](https://concourse-ci.org/vars.html#cluster-wide-credential-manager).

Specifically AWS account keys and secrets are defined with [`((vars))`](https://concourse-ci.org/vars.html#var-syntax) expecting that Concourse will resolve these values from the credential manager at run time.

>"For credential managers which support path-based lookup, a secret-path without a leading `/` may be queried relative to a predefined set of path prefixes. This is how the Vault credential manager currently works; `foo` will be queried under `/concourse/(team name)/(pipeline name)/foo`."

### AWS Policies
The following AWS policy is required as a minimum to enable the state backend setup within AWS...
```
```

## Invocation
### Configuration
The following configuration needs to be considered when setting up from scratch...
 * Secrets...
   * Git repository access tokens for accessing repositories...
     *  `mwatsham/concourse-aws-terraform-backend`
     *  `mwatsham/terraform-aws-backend` 
   * AWS Access and Secret keys for the accounts hosting the State Backends
 * Git configuration to pull repositories...
     *  `mwatsham/concourse-aws-terraform-backend`
     *  `mwatsham/terraform-aws-backend` 
 * Overall Pipeline name and Concourse team
 * Terraform Backend configuration

When adding a new State Backend to an established pipeline the following configuration is required...
  * AWS Access and Secret keys for the accounts hosting the State Backend
  * Terraform Backend configuration

#### AWS Secrets Manager
Assuming that the Concourse CI platform is configured to retrieve secrets stored in [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/).

In preparation to run the Pipeline the following Secrets need to be present...
 * Git repository read access to `mwatsham/concourse-aws-terraform-backend`...
   * Git username e.g. `/concourse/<team name>/<pipeline name>/gituser`
   * Git access token e.g. `/concourse/<team name>/<pipeline name>/gittoken`
 * Git repository read access to `mwatsham/terraform-aws-backend`...
   * Git username e.g. `/concourse/<team name>/<pipeline name>/gituser`
   * Git access token e.g. `/concourse/<team name>/<pipeline name>/gittoken`
 * AWS access to account hosting the State Backend...
   * AWS Access Key e.g. `/concourse/<team name>/<pipeline name>/concourse-deploy-user-key`
   * AWS Secret Key e.g. `/concourse/<team name>/<pipeline name>/concourse-deploy-user-secret`

#### Git repositories
Configuration to locate and pull the required repositories for the pipeline is located in the following file...
  * `config/git_repos.yml`

##### Variables
  * `PIPELINE:` - variable hierachy for the Concourse pipeline code.
  * `TF_BACKEND:` - variable hierachy for Terraform State Backend module code.
  * `URI:` - https url for Git repository.
  * `BRANCH:` - Git branch containing code.
  * `GITUSER:` - Git username with access to the repository.
  * `GITTOKEN:` - Git access token for the user.

**Note**: that when specifiying the path to a secret Concourse will look in the following paths, in order:
  * `/concourse/<TEAM_NAME>/<PIPELINE_NAME>/foo_param`
  * `/concourse/<TEAM_NAME>/foo_param`

Consequently only the path after the `/concourse/<TEAM_NAME>/<PIPELINE_NAME>` or `/concourse/<TEAM_NAME>` needs to be specified in the Concourse CI code e.g. 
  * `/concourse/<TEAM_NAME>/<PIPELINE_NAME>/gituser` -> `((gituser))`

e.g. - `config/git_repos.yml`..
```
REPOSITORY:
  PIPELINE:
    URI: https://github.com/mwatsham/concourse-aws-terraform-backend.git
    BRANCH: main
    GITUSER: ((concourse-aws-terraform-backend-gituser))
    GITTOKEN: ((concourse-aws-terraform-backend-gittoken))
  TF_BACKEND:
    URI: https://github.com/mwatsham/terraform-aws-backend.git
    BRANCH: main
    GITUSER: ((terraform-aws-backend-gituser))
    GITTOKEN: ((terraform-aws-backend-gittoken))
```

#### Pipeline configuration

#### Terraform Backend configuration
Configuration of a Terraform State Backend requires configuration in two files...
  * `config/terraform_backends.yml`
  * `config/tfvars/<state backend name>.yml`

### Initialising Concourse Pipelines
1. Set-up local `fly` environment...
  e.g.
  ```
  $ fly -t myconcourse login --team-name myteam --concourse-url https://concourse.example.com
  ```
2. Clone repo...
  ```
  $ git clone https://github.com/mwatsham/concourse-aws-terraform-backend.git
  ```
3. Create Pipeline...
  ```
  $ cd concourse-aws-terraform-backend
  $ fly -t myconcourse set-pipeline -c pipelines/factory.yml -p my-tf-state-backend-deployment --load-vars-from=config/pipeline.yml --load-vars-from=config/git_repos.yml
  ```
4. Unpause Pipeline...
  ```
  $ fly -t myconcourse unpause-pipeline -p my-tf-state-backend-deployment
  ```
5. Trigger Pipeline...
  ```
  $ fly -t myconcourse check-resource -r my-tf-state-backend-deployment/concourse
  ```

# References
  * https://aws.amazon.com/secrets-manager/
  * https://concourse-ci.org/aws-asm-credential-manager.html
  * https://concourse-ci.org/aws-asm-credential-manager.html#credential-lookup-rules

