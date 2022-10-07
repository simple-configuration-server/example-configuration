# SCS Example Configuration Repository
This repository contains an example of how you can version-control simple system
configurations and host them using the
[Simple Configuration Server](https://github.com/tom-brouwer/simple-configuration-server)
(SCS). It contains examples of using CI/CD and githooks to validate
configurations prior to deployment, and build a SCS docker image that includes
the configuration. This repository only showcases a subset of the features of
SCS. For a full description of the possibilities of SCS, review the
documentation in the [SCS repository](https://github.com/tom-brouwer/simple-configuration-server).

_Note that this repository is meant as an example, and should not be copied
directly. If you want to apply the structure described in this repository in
your own project, you have to review all settings and configuration files.
Among others, SSL should be enabled and more specific IP restrictions should be
set._

## 1. Contents
This repository contains the following:
* **.githooks/**: Folder containing a pre-commit githook to run the SCS
  validation script locally using Docker, so the integrity of the files is
  validated before a commit.
* **configuration/**: Folder containing the full configuration for scs, with
  the exception of secrets, which should never be stored in version control:
  * **config/ & common/**: The contents of these folders are discussed in
    detail in section 1.1.
  * **scs-configuration.yaml**: The configuration for the SCS
  * **scs-users.yaml**: The list of users, including their authorizations.
  * **scs-validate.yaml**: The settings for configuration validation. This is
    only used by the validate.py script for testing.
* **.gitlab-ci.yml**: An example GitLab CI/CD configuration that contains
  uses the validate script to test the configuration, and build a custom
  Docker image that includes the configuration after success.
* **.github/workflows/main.yml**: An example CI/CD configurations for GitHub
  actions, which is functionally equivalent to the GitLab configuration
* **docker-compose.yml**: Example docker docker-compose configuration that uses
  the image build using CI/CD to create and start a Docker container
* **Dockerfile**: Example of you can build a Docker image that includes the
  configuration from this repository. This is used by the CI/CD pipeline to
  built the image.
* **enable_githooks.sh**: Simple convenience script to enable pre-commit
  tests for the repository


**WARNING: Don't store secrets in GIT**  
It is bad practice to store secrets in git repositories. In case you run the
'validate' script, scs-configuration.yaml contains a 'directories.secrets'
variable and this directory is not empty, validation will fail. Although this
example does include 'scs-users.yaml', all tokens are sourced from a secrets
file (using the !scs-secret yaml tag) that is not in this repository. Based on
your own consideration, you may also choose not to include 'scs-users.yaml' in
your repository, since this is not required to run the 'validate' script. An
SSL private key is also considered a secret and should never be in a git
repository.

### 1.1 Configuration directory sub-folders
The configuration directory contains 2 folders:
1. **common/**: A directory with YAML files that contain common files used by
   multiple endpoints
2. **config/**: The structure and contents of this directory and its children
   is used by SCS to build the URL paths

#### 1.1.1 common/ directory
This contains some examples of how the 'common' directory can be used:
* **remote-files/**: This is an example of how configuration files from other
  sources, such as other git repositories, can be used by SCS. You can for
  example choose to include a global configuration file describing the
  properties of different environments, as a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
  inside your configuration repository
* **users/**: Another example where a 'common' directory comes in handy, is to
  specify a list of users for a system in a central place. In this example
  the list of users feeds the /elasticsearch/create_users.json file, as well as
  the credentials files for the individual servers (e.g. /servers/first/es-credentials.json)
* **global.yaml**: Another example is just having a simple global configuration
  file, so you can specify variables in one place, without having to
  use a 'scs-env.yaml' file in the root of the config/ directory, since this
  will add every variable to the context of every child directory/endpoint,
  which you may not want (especially for secrets).

_Note that if you do not want to use common configuration variables, you can
just leave the directory emtpy_

#### 1.1.2 config/ directory
This contains some different examples of how you can structure the
configuration paths of your SCS implementation. For example you can
use paths for specific systems (elasticsearch/), paths for specific
servers (servers/) and a section with global variables accessible by all
users (var/).

Note since you have to define path authorizations for each user in
[scs-users.yaml](configuration/scs-users.yaml) (If you're using the built-in
SCS auth module), you should design your configuration directory
structure in such a way that you can authorize users properly.

The config/ directory and it's subfolders contain (1) The configuration file
templates, which are used by SCS as the paths for the actual endpoints, and
(2) scs-env.yaml files, that define the environment for each endpoint.
Environment files among others define the context variables, available in the
template, the allowed HTTP methods for an endpoint, and the status code and
headers to send in in the response.

Each directory can have a global scs-env file, which applies to
all endpoints in the directory, as well as the ones in sub-directories. Also,
a specific scs-env.yaml file for a single endpoint can be defined. For example
for the file `/servers/first/es-credentials.json`, the following scs-env.yaml
files are used (if these exist), each one possibly overriding properties
defined in the previous:

1. [scs-env.yaml](configuration/config/scs-env.yaml)
2. servers/scs-env.yaml
3. servers/first/scs-env.yaml
4. [servers/first/es-credentials.json.scs-env.yaml](configuration/config/servers/first/es-credentials.json.scs-env.yaml)

In the above example, only 1 and 4 are relevant, since 2 and 3 do not exist.

Below is a list of the functionality illustrated by some of the endpoints:
* **/var/hostname-prefix**: this is the simplest way an endpoint can be
  defined. It uses no templating features, but rather just contains a constant.
* **/elasticsearch/jvm.custom.options**: This endpoint only allows POST
  requests. Note that the 'heap_size_gb' variable is not set in the env file,
  and therefore needs to be provided in a POST request JSON body. By default,
  all endpoints allow GET and POST requests by default, allowing you to
  override any context variables.
* **/elasticsearch/create_users.json && /servers/first/es-credentials.json**:
  The ElasticSearch users defined in the 'common' directory are used by
  ElasticSearch to determine the users to create, and each server can only
  retrieve the user data for that server specifically.
* **/var/domains-redirect**: By setting a 301 status code and the
  Location header, you can create redirects (Please consider the note in
  the [env file](configuration/config/var/domains-redirect.scs-env.yaml)
  before implementing this)
* **/var/domain-name**: This does not have an env file specifically for this
  endpoint, but rather uses the 'domains' variable from the
  [root-level scs-env file](configuration/config/scs-env.yaml).

## 2 Usage

### 2.1 CI/CD
The [.gitlab-ci.yml](.gitlab-ci.yml) defines the GitLab CI/CD configuration
for this repository. The CI/CD pipeline configured in this file both tests the
contents of the repository, and builds a docker image that includes the
configuration. The pipeline is only triggered on tagged commits, meaning you can
version your configuration using git tags, which will be used as the docker
image version. Docker images built by the pipeline can be found in the
'Container Registry' of the GitLab project.

For GitHub users, and equivalent CI/CD configuration (Using GitHub actions) is
included at [.gihub/workflows/main.yml](.github/workflows/main.yml).

### 2.2 Running the Docker container
The [docker-compose.yml](docker-compose.yml) file contains an example
configuration for running a docker container using the Docker image that is
built by the CI/CD pipeline.

Since secrets are not included in the repository, they are added to the
container using a bind-mount from the .local/secrets directory. If you want to
test the Docker image generated from this repository locally, open a terminal
window on a Linux or Mac machine and do
```bash
mkdir -p .local/secrets
# Note .TEMPLATE is included in the filename to prevent people from mounting
# them directly in Docker, and risk storing secrets to the repository on the
# next commit
cp ./templates/secrets/elasticsearch.TEMPLATE.yaml ./.local/secrets/elasticsearch.yaml
cp ./templates/secrets/scs-tokens.TEMPLATE.yaml ./.local/secrets/scs-tokens.yaml
docker compose up -d # Run it on the background
```
_Note you need to have docker and docker compose (v2) installed_

Since all 'secrets' in these files define the '!scs-gen-secret' tag, these are
auto-generated and saved when first running the container.

Now you can use e.g. curl to get data from the server. Note that you can find
the token for the superuser in your .local/secrets/scs-tokens.yaml file:
```
curl --header "Authorization: Bearer SUPERUSER_TOKEN" http://127.0.0.1:3000/configs/var/timezone
```

Run `docker compose down` to remove the container again.

## 3 Development
Before commiting any changes to the repositories, make sure to run the
`./enable_githooks.sh` script to ensure the pre-commit tests are run.

To trigger the build of a new Docker container, assign a git tag to your commit
and push it to GitLab, e.g.: `git tag 1.2.3 && git push --tags` (Note that
prior to doing this you need to have pushed your commits already).
