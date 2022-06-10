# SCS Example Configuration Repository
This repository contains an example of how you can version-control the
configuration files and variables of a simple system, and host them using the
[Simple Configuration Server](https://gitlab.com/Tbro/simple-configuration-server)
(SCS), using GitLab CI/CD to automatically test your configuration file syntax
and build a Docker image that includes the configuration.

**NOTE: This is Work-In-Progress**

## 1. Contents
* **scs/**: The folder that contains the configuration for the
  Simple Configuration Server itself. This includes:
  * **scs-configuration.yaml**: The global configuration for the SCS
  * **scs-users.yaml**: The list of users of the system, including their
    authorizations.
  * **scs-validate.yaml**: The settings for configuration validation. This is
    only used by the validate.py script for testing.
* **configuration/**: Contains the configuration files that are served by the SCS,
  including the following sub-folders:
  * **config/**: The configuration files and endpoint configurations for SCS.
    All files ending with scs-env.yaml contain configurations of each endpoint,
    as well as the context that contains the variables that can be used in
    the configuration file templates. All files that do not end with
    'scs-env.yaml' are rendered as configuration file templates, and hosted
    under their relative paths under the configs/* urls of the SCS
  * **common/**: Contains common variables that can be subsituted inside the
    scs-env.yaml file, using the '!scs-common' YAML tag
* **.githooks/**: Folder containing a pre-commit githook to the SCS validation
  script locally using Docker, so the integrity of the files is validated
  prior to a commit.
* **enable_githooks.sh**: Simple convenience script to activate the .githooks
  directory for your local repository clone.
* **.gitlab-ci.yml**: An example GitLab CI/CD configuration that contains
  uses the validate script to test the configuration, and build a custom
  Docker image that includes the configuration after success.
