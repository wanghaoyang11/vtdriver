#!/bin/bash

# Copyright 2021 JD Project Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

mkdir build_vitess
cd build_vitess

echo "Downloading vitess source from github..."
git --version >/dev/null 2>&1 || fail "git is not installed"
git clone git@github.com:vitessio/vitess.git
git checkout v11.0.2 # 用11.0.2版本

cp ./vtdriver ./vitess/examples/local/
cp ./Dockerfile.vtdriver ./vitess/docker/local/

# add target 'docker_vtdriver' in Makefile
echo -e '\ndocker_vtdriver:\n\t${call build_docker_image,docker/local/Dockerfile.vtdriver,vitess/vtdriver-env}' >> ./vitess/Makefile

echo "build docker image 'vitess/vtdriver-env'"
cd vitess
make docker_vtdriver

echo "Done."
