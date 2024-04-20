# Slurm-Cluster
## Introduction
Slurm Cluster Deployment Automation


## Prerequisites
- Python 3.8 later
- Docker

## Makefile Params
|Name|Default|Desc|
|---|---|---|
|REPO_HUB|wingflower||
|VERSION|v_0.0.1||
|BUILD_IMAGE|slurm-cluster||
|BUILD_TAG|$(VERSION)||
|IS_LOCAL|false||
|BASE_IMAGE|centos||
|BASE_TAG|7||
|USE_COLOR|false||
|DEPLOY_TEST|test||
|DEPLOY_ENV|test||
|MAINTAINER|wingflower||
|PYTHON_VERSION|3.8.16||
|SLURM_VERSION|22.05.11||
|DOCKER_DIR|docker-slurm||

## Dockerfile Params
|Name|Default|Desc|
|---|---|---|
|BASE_IMAGE|censtos||
|BASE_TAG|7||
|BUILD_DATE|Now||
|BUILD_IMAGE|slurm-cluster||
|BUILD_TAG|=VERSION||
|DEPLOY_ENV|test||
|DOCKER_BUILD_OPTION||
|DOCKER_DIR|docker-slurm||
|ECHO_OPTION|||
|GIT_DIRTY|||
|IS_LOCAL|false||
|MAINTAINER|MZ-INFRA||
|PYTHON_VERSION|3.8+||
|REPO_HUB|||
|SLURM_VERSION|22.05.9||
|UNAME_S|||
|USE_COLOR|false||
|VCS_REF|||
|VERSION|git tag||

## How to Run
- Install pyenv ans python
https://github.com/pyenv/pyenv#installation
```shell
$ make install
``` 
- Install docker for OSX
https://docs.docker.com/desktop/install/mac-install/
- Install docker for CentOS
https://docs.docker.com/engine/install/centos/

> #### Case1. Ansible
> - Modify
>   - .inventory.yml
>   - ./conf/exports
>   - ./conf/slurm.conf
>   - ./vars/test.yml
> - Install ansible
> ```shell
> make install-ansible
> ```
> - Test ping to hosts
> ```shell
> make ping
> ```
> - If got [SUCCESS] mesages from all nodes.
> ```shell
> make deploy-ansible
> ```
> - Add a compute node
> ```shell
> 
> ```

> #### Case2. Docker
> - Build docker image for slurm
> ```shell
> $ make build
> ```

- Verify
    - Connect control node and..
    ```shell
    $ sinfo
    ```

## Test
```shell
```

## References
https://slurm.schedmd.com/quickstart_admin.html
https://download.schedmd.com/slurm/
https://slurm.schedmd.com/archive/slurm-23.02.1/configurator.html
https://southgreenplatform.github.io/trainings/hpc/slurminstallation/
https://slurm.schedmd.com/SLUG19/Atos.pdf
https://github.com/Artlands/Install-Slurm
https://github.com/xtreme-d/docker-slurm-cluster
https://hpc.stat.yonsei.ac.kr/docs/01_intro/

## License
MIT
