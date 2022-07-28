#!/bin/sh
unset BASH_ENV PROMPT_COMMAND ENV
# ensure we have a fully defined PKG_CONFIG_PATH before it is extended by devtoolset
export PKG_CONFIG_PATH="$(pkg-config --variable pc_path pkg-config)"
source scl_source enable devtoolset-9
