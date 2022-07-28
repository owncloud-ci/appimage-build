#! /bin/bash

set -xe

curl -L https://mirrors.edge.kernel.org/pub/software/scm/git/git-"$GIT_VERSION".tar.gz | tar xz

cd git-"$GIT_VERSION"

# build and install into prefix
./configure --prefix=/usr/local
make all -j"$(nproc)"
make install

cd ..

rm -rf git-"$GIT_VERSION"/
