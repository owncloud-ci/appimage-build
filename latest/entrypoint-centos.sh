#! /bin/bash

###
# this script functions as a transparent wrapper to other commands
# it enables devtoolset by default
###

set -eo pipefail

# ensure we have a fully defined PKG_CONFIG_PATH before it is extended by devtoolset
export PKG_CONFIG_PATH="$(pkg-config --variable pc_path pkg-config)"

source /opt/rh/devtoolset-9/enable

exec "$@"
