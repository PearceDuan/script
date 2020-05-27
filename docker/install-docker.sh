#!/usr/bin/env bash
# Author: pearceduan
# Date: 2020.05.26

readonly DOCKER_VERSION='19.03.5'
readonly DOCKER_COMPOSE_VERSION='1.25.0'

function root_need(){
    if [[ $EUID -ne 0 ]]; then
        echo "Error: this script must be run as root!" 1>&2
        exit 1
    fi
}

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

function get_linux_distribution() {
    . /etc/os-release && echo "$ID"
}

function get_ubuntu_version_codename() {
    . /etc/os-release && echo "$VERSION_CODENAME"
}

echo_docker_as_nonroot() {
	if command_exists docker && [[ -e /var/run/docker.sock ]]; then
		docker version || true
	fi
	your_user=your-user
	# [ "$USER" != 'root' ] && your_user="$USER"
	# intentionally mixed spaces and tabs here -- tabs are stripped by "<<-EOF", spaces are kept in the output
	echo "If you would like to use Docker as a non-root user, you should now consider"
	echo "adding your user to the \"docker\" group with something like:"
	echo
	echo "  sudo usermod -aG docker $your_user"
	echo
	echo "Remember that you will have to log out and back in for this to take effect!"
	echo
	echo "WARNING: Adding a user to the \"docker\" group will grant the ability to run"
	echo "         containers which can be used to obtain root privileges on the"
	echo "         docker host."
	echo "         Refer to https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface"
	echo "         for more information."
}

function remove_docker(){
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>remove old version first if already installed"
    case $(get_linux_distribution) in
    ubuntu)
        apt-get remove -y docker docker.io containerd runc docker-engine || true
        apt-get purge -y docker-ce docker-ce-cli containerd.io || true
        # rm -rf /var/lib/docker
        ;;
    centos)
        yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine || true
        yum remove -y docker-ce docker-ce-cli containerd.io || true
        # rm -rf /var/lib/docker
        ;;
    *)
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>un-support distribution"
        exit 1
        ;;
    esac
}

function install_docker(){
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>install docker(${DOCKER_VERSION})"
    case $(get_linux_distribution) in
    ubuntu)
        apt-get update
        apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
        apt-key fingerprint 0EBFCD88
        add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable"
        apt-get update
        apt-get install -y \
                docker-ce=5:${DOCKER_VERSION}~3-0~ubuntu-$(get_ubuntu_version_codename) \
                docker-ce-cli=5:${DOCKER_VERSION}~3-0~ubuntu-$(get_ubuntu_version_codename) \
                containerd.io
        ;;
    centos)
        yum install -y yum-utils
        yum-config-manager \
            --add-repo \
            https://download.docker.com/linux/centos/docker-ce.repo
        # yum list docker-ce --showduplicates | sort -r
        yum install -y docker-ce-${DOCKER_VERSION} docker-ce-cli-${DOCKER_VERSION} containerd.io
        systemctl start docker
        ;;
    *)
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>un-support distribution"
        exit 1
        ;;
    esac
}

function install_docker_compose_online() {
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>install docker-compose online"
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
}

function install_docker_compose_locally() {
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>install docker-compose locally"
    mv ./docker-compose-${DOCKER_COMPOSE_VERSION}-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
}

function remove_docker_compose() {
    rm -rf /usr/bin/docker-compose
    rm -rf /usr/local/bin/docker-compose
}

function install_docker_compose(){
    if [[ -e ./docker-compose-${DOCKER_COMPOSE_VERSION}-$(uname -s)-$(uname -m) ]]; then
        install_docker_compose_locally
    else
        install_docker_compose_online
    fi
}

function remove_command_completion() {
    rm -rf /etc/bash_completion.d/docker-compose
}

# optionally, install command completion for the bash shell
function install_command_completion_online() {
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>install command completion online"
    curl -L https://raw.githubusercontent.com/docker/compose/${DOCKER_COMPOSE_VERSION}/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
}

function install_command_completion_locally() {
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>install command completion locally"
    mv ./command-completion-docker-compose-${DOCKER_COMPOSE_VERSION}-$(uname -s)-$(uname -m) /etc/bash_completion.d/docker-compose
}

function install_command_completion() {
    if [[ -e ./command-completion-docker-compose-${DOCKER_COMPOSE_VERSION}-$(uname -s)-$(uname -m) ]]; then
        install_command_completion_locally
    else
        install_command_completion_online
    fi
}

set -e
root_need
remove_docker
remove_docker_compose
remove_command_completion
install_docker
echo_docker_as_nonroot
install_docker_compose
install_command_completion
exit 0

