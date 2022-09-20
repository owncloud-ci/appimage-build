#! /bin/sh

set -e

unset BASH_ENV PROMPT_COMMAND ENV
# ensure we have a fully defined PKG_CONFIG_PATH before it is extended by devtoolset
export PKG_CONFIG_PATH="$(pkg-config --variable pc_path pkg-config)"

if [[ "$PYENV_ROOT" != "" ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"

    # pyenv may not have been installed yet when we run this script
    if command -v pyenv >/dev/null; then
        # https://github.com/pyenv/pyenv/issues/1157#issuecomment-418446159
        eval "$(pyenv init - --no-rehash)"
    fi
fi

set +e

# the devtoolscript is known fail, therefore we set +e before it
source scl_source enable devtoolset-9
