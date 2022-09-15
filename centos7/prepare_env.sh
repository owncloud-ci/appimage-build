#!/bin/sh
unset BASH_ENV PROMPT_COMMAND ENV
# ensure we have a fully defined PKG_CONFIG_PATH before it is extended by devtoolset
export PKG_CONFIG_PATH="$(pkg-config --variable pc_path pkg-config)"

# setup pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

source scl_source enable devtoolset-9
