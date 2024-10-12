default: install

alias f := format
alias fmt := format

format:
    just --fmt --unstable

install:
    #!/usr/bin/env bash
    set -euxo pipefail
    # todo This needs to be installed manually on Arm.
    if [ ! -f "/etc/yum.repos.d/sublimehq.repo" ] ; then
        sudo cp --update=none yum.repos.d/sublimehq.repo /etc/yum.repos.d/sublimehq.repo
    fi
    distro=$(awk -F= '$1=="ID" { print $2 ;}' /etc/os-release)
    if [ "$distro" = "fedora" ]; then
        variant=$(awk -F= '$1=="VARIANT_ID" { print $2 ;}' /etc/os-release)
        if [ "$variant" = "toolbx" ]; then
            sudo dnf --assumeyes install sublime-merge
        elif [ "$variant" = "iot" ] || [[ "$variant" = *-atomic ]]; then
            sudo rpm-ostree install --idempotent sublime-merge
            echo "Reboot to finish installation."
        fi
    fi
    mkdir --parents "{{ config_directory() }}/sublime-merge/Packages"
    rm --force --recursive "{{ config_directory() }}/sublime-merge/Packages/User"
    ln --force --relative --symbolic User "{{ config_directory() }}/sublime-merge/Packages/User"
