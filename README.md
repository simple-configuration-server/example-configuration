# SCS Example Configuration Repository
This repository contains an example of how you can version-control the
configuration files and variables of a simple system, and host them using the
[Simple Configuration Server](https://gitlab.com/Tbro/simple-configuration-server)
(SCS), using GitLab CI/CD to automatically test your configuration file syntax
and build a Docker image that includes the configuration.

**NOTE: This is Work-In-Progress**

## 1. Contents
* **configuration/**: This contains the full configuration for scs, including
  the scs configuration files, that are to be placed in the SCS_CONFIG_DIR,
  with the excepctions of secrets (See warning below):
  * **config/**: The configuration files and endpoint configurations for SCS.
    All files ending with scs-env.yaml contain configurations of each endpoint,
    as well as the context that contains the variables that can be used in
    the configuration file templates. All files that do not end with
    'scs-env.yaml' are rendered as configuration file templates, and hosted
    under their relative paths under the configs/* urls of the SCS
  * **common/**: Contains common variables that can be subsituted inside the
    scs-env.yaml file, using the '!scs-common' YAML tag
  * **scs-configuration.yaml**: The global configuration for the SCS
  * **scs-users.yaml**: The list of users of the system, including their
    authorizations.
  * **scs-validate.yaml**: The settings for configuration validation. This is
    only used by the validate.py script for testing.
* **.githooks/**: Folder containing a pre-commit githook to the SCS validation
  script locally using Docker, so the integrity of the files is validated
  prior to a commit.
* **enable_githooks.sh**: Simple convenience script to activate the .githooks
  directory for your local repository clone.
* **.gitlab-ci.yml**: An example GitLab CI/CD configuration that contains
  uses the validate script to test the configuration, and build a custom
  Docker image that includes the configuration after success.

**WARNING**: It's bad practice to store secrets in git repositories. By default,
the 'validate' script, used for testing, gives an error if 'directories.secrets'
is specified in scs-configuration.yaml, and this directory contains data.
Although the scs-users.yaml file is included in this example, user tokens are
referenced using the !scs-secret yaml tag. Based on your own considerations,
you can also choose not to include the 'scs-users.yaml' in your configuration
repository, and use docker volumes or secrets to add it to the Docker container
at runtime, since this file is not checked by the 'validate' script anyway.
