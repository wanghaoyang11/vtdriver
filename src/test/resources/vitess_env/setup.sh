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

# Pull vitess source to local and build a vtdriver-env docker image.

set -e

git --version >/dev/null 2>&1 || fail "git is not installed"
docker --version >/dev/null 2>&1 || fail "docker is not installed"

# which vitess release tag to use, default v13.0.0
release=${1:-"v13.0.0"};

echo "using branch/tag '${release}'"

if [ ! -d "build_vitess" ];then
  mkdir build_vitess
  cd build_vitess
  echo "Downloading vitess source from github..."
  git clone git@github.com:vitessio/vitess.git
else
  cd build_vitess
fi

cd vitess
git checkout --force ${release}

cp -r ../../vtdriver ./examples/local/
git apply ../../vtdriver-env-${release}.patch
chmod -R ug+rwx .

echo "build docker image 'vitess/vtdriver-env'"
make docker_vtdriver

echo "Done."
