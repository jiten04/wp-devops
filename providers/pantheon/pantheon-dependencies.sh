#!/usr/bin/env bash
#
# devops/core/providers/pantheon/pantheon-dependencies.sh
#

#
# "Declarations" of the variables this script assumes
#
declare=${PANTHEON_TOKEN:=}
declare=${PANTHEON_TERMINUS_VERSION:=1.6.0}  # 1.6.0 is the most recent version we tested with.

if ! [ -f ~/cache/terminus/bin/terminus ]; then
    #
    # Installing Terminus for Pantheon, latest version
    #
    # @todo Save version # to a file in cache and if 'latest' requested then
    #       check to see if there is a new version available instead of just
    #       not checking the version if already installed.
    #
    announce "...Installing Terminus for Pantheon"
    mkdir -p ~/cache
    cd ~/cache
    rm -f terminus.tar.gz
    rm -rf terminus

    if [ "latest" == "${PANTHEON_TERMINUS_VERSION}" ]; then
        announce "...Retrieving URL to latest Terminus version"
        TERMINUS_TARBALL="$(curl -s https://api.github.com/repos/pantheon-systems/terminus/releases/latest | jq -r ".tarball_url")"
    else
        announce "...Retrieving URL to version ${PANTHEON_TERMINUS_VERSION} of Terminus"
        TERMINUS_TARBALL="https://github.com/pantheon-systems/terminus/archive/${PANTHEON_TERMINUS_VERSION}.tar.gz"
    fi

    announce "...Downloading Terminus tarball"
    wget -O terminus.tar.gz "${TERMINUS_TARBALL}"

    announce "...Extracting Terminus tarball"
    tar -xzf terminus.tar.gz
    rm terminus.tar.gz

    if [ "latest" = "${PANTHEON_TERMINUS_VERSION}" ]; then
        announce "...Locating extracted Terminus directory"
        TERMINUS_DIRECTORY="$(ls -d *terminus*/)"
    else
        TERMINUS_DIRECTORY="terminus-${PANTHEON_TERMINUS_VERSION}"
    fi

    mv "${TERMINUS_DIRECTORY}" terminus
    cd terminus

    announce "...Run composer to build Terminus"
    composer update

fi

#
# Symlinking Terminus for Pantheon
#
announce "...Symlinking Terminus for Pantheon"
sudo ln -s ~/cache/terminus/bin/terminus /usr/local/bin/terminus

#
# Authenticating Terminus for Pantheon
#
announce "...Authenticating Terminus for Pantheon"
terminus auth:login --machine-token="${PANTHEON_TOKEN}"

