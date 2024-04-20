REPO_HUB = mediazen
VERSION = v_0.0.1
BUILD_IMAGE = slurm-cluster
BUILD_TAG = $(VERSION)
IS_LOCAL = false
BASE_IMAGE = centos
BASE_TAG = 7
USE_COLOR = false
DEPLOY_TEST = test
DEPLOY_ENV = test
MAINTAINER = MZ-INFRA
PYTHON_VERSION = 3.8.16
SLURM_VERSION = 21.08.5
DOCKER_DIR = docker-slurm

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
    ECHO_OPTION = ""
else
    ECHO_OPTION = "-e"
endif

ifeq ($(USE_COLOR), false)
    NO_COLOR=
    OK_COLOR=
    ERROR_COLOR=
    WARN_COLOR=
else
    NO_COLOR=\033[0m
    OK_COLOR=\033[32m
    ERROR_COLOR=\033[31m
    WARN_COLOR=\033[93m
endif

ifeq ($(IS_LOCAL), true)
	DOCKER_BUILD_OPTION = --progress=plain --no-cache --rm=true
else
	DOCKER_BUILD_OPTION = --no-cache --rm=true
endif

VCS_REF = $(shell git rev-parse --short HEAD)
BUILD_DATE = $(shell date -u +"%Y-%m-%dT%H:%M:%S%Z")
GIT_DIRTY  = $(shell git diff --shortstat 2> /dev/null | tail -n1 )

.PHONY: all install build push test release ping version

all: install build
version:
	@echo $(VERSION)

ping:
	@ansible -m ping -i ./ansible-slurm/inventory.yml all

deploy-slurm:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbook.yml --extra-vars="env=$(DEPLOY_ENV)"

print-version:
	@echo $(ECHO_OPTION) "$(OK_COLOR) VERSION-> $(VERSION)  REPO-> $(REPO_HUB)/$(BUILD_IMAGE):$(BUILD_TAG) $(NO_COLOR) IS_LOCAL: $(IS_LOCAL)"

install: install-pyenv

build: make_build_args
	docker build $(DOCKER_BUILD_OPTION) -f $(DOCKER_DIR)/Dockerfile \
		$(shell cat $(DOCKER_DIR)/BUILD_ARGS) \
		-t $(REPO_HUB)/$(BUILD_IMAGE):$(BUILD_TAG) .
	$(call colorecho, "\n\nSuccessfully build '$(REPO_HUB)/$(BUILD_IMAGE):$(BUILD_TAG)'")
	@echo "==========================================================================="
	@docker images | grep  $(REPO_HUB)/$(BUILD_IMAGE) | grep $(BUILD_TAG)

push: print_version
	docker push $(REPO_HUB)/$(BUILD_IMAGE):$(BUILD_TAG)

install-pyenv:
	ifeq ($(UNAME_S),Darwin)
		brew update
		brew install pyenv pyenv-virtualenv
	else
		yum install -y bzip2 bzip2-devel curl gcc gcc-c++ git libffi-devel make openssl-devel readline-devel sqlite sqlite-devel xz xz-devel zlib-devel
		curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
		echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
		echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
		echo 'eval "$(pyenv init -)"' >> ~/.bashrc
		echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
		source ~/.bashrc
	endif
	pyenv update
	pyenv install $(PYTHON_VERSION)
	pyenv global $(PYTHON_VERSION)

install-ansible:
	pip3 install ansible
	@ansible-galaxy install ericsysmin.chrony

install-docker:
	yum remove docker \
		docker-client \
		docker-client-latest \
		docker-common \
		docker-latest \
		docker-latest-logrotate \
		docker-logrotate \
		docker-engine
	yum install -y yum-utils
	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	systemctl start docker

jwt-key:
	@dd if=/dev/random of=./ansible-slurm/conf/jwt_hs256.key bs=32 count=1

run-slurmrestd:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t run_slurmrestd --extra-vars "env=$(DEPLOY_ENV)"

kill-slurmrestd:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t kill_slurmrestd --extra-vars "env=$(DEPLOY_ENV)"

gen-token:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t gen_token --extra-vars "env=$(DEPLOY_ENV)"

test-api:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t test_api --extra-vars "env=$(DEPLOY_ENV)"

send-slurm-conf:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t send_slurm_conf --extra-vars "env=$(DEPLOY_ENV)"

send-slurmdbd-conf:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t send_slurmdbd_conf --extra-vars "env=$(DEPLOY_ENV)"

send-munge-key:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t send_munge_key --extra-vars "env=$(DEPLOY_ENV)"

send-pam-conf:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t send_pam_conf --extra-vars "env=$(DEPLOY_ENV)"

restart-slurmctld:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t restart_slurmctld --extra-vars "env=$(DEPLOY_ENV)"

restart-slurmdbd:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t restart_slurmdbd --extra-vars "env=$(DEPLOY_ENV)"

restart-slurmd:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t restart_slurmd --extra-vars "env=$(DEPLOY_ENV)"

restart-munge:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t restart_munge --extra-vars "env=$(DEPLOY_ENV)"

status-slurmctld:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t status_slurmctld --extra-vars "env=$(DEPLOY_ENV)"

status-slurmdbd:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t status_slurmdbd --extra-vars "env=$(DEPLOY_ENV)"

status-slurmd:
	@ansible-playbook -i ./ansible-slurm/inventory.yml ./ansible-slurm/playbooks/control_slurm.yml \
	   -t status_slurmd --extra-vars "env=$(DEPLOY_ENV)"

printvars:
	@$(foreach V,$(sort $(.VARIABLES)), \
		$(if $(filter-out environment% default automatic, \
		$(origin $V)),$(warning $V=$($V) ($(value $V)))))

make_build_args:
	@$(shell echo $(ECHO_OPTION) "$(OK_COLOR) ----- Build Environment ----- \n $(NO_COLOR)" >&2)\
		$(shell echo "" > $(DOCKER_DIR)/BUILD_ARGS) \
			$(foreach V, \
				$(sort $(.VARIABLES)), \
				$(if  \
					$(filter-out environment% default automatic, $(origin $V) ), \
						$($V=$($V)) \
				$(if $(filter-out "SHELL" "%_COLOR" "%_STRING" "MAKE%" "colorecho" ".DEFAULT_GOAL" "CURDIR" "TEST_FILES" "DOCKER_BUILD_OPTION" "GIT_DIRTY", "$V" ),  \
					$(shell echo $(ECHO_OPTION) '$(OK_COLOR)  $V = $(WARN_COLOR) $($V) $(NO_COLOR) ' >&2;) \
					$(shell echo "--build-arg $V=$($V)  " >> $(DOCKER_DIR)/BUILD_ARGS)\
					)\
				)\
			)

show_labels: make_build_args
	docker $(REPO_HUB)/$(BUILD_IMAGE):$(BUILD_TAG) | jq .[].Config.Labels
