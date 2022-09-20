#! /bin/sh

set -e

unset BASH_ENV PROMPT_COMMAND ENV
# ensure we have a fully defined PKG_CONFIG_PATH before it is extended by devtoolset
export PKG_CONFIG_PATH="$(pkg-config --variable pc_path pkg-config)"

# setup pyenv once it's installed
if command -v pyenv >/dev/null; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

set +e

# the devtoolscript is known fail, therefore we set +e before it
source scl_source enable devtoolset-9
