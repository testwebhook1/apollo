#!/usr/bin/env bash

###############################################################################
# Copyright 2020 The Apollo Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################

# Fail on first error.
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

. installer_base.sh

TARGET_ARCH=$(uname -m)

if [ "$TARGET_ARCH" == "x86_64" ]; then
  # https://docs.bazel.build/versions/master/install-ubuntu.html
  BAZEL_VERSION="3.4.1"
  PKG_NAME="bazel_${BAZEL_VERSION}-linux-x86_64.deb"
  DOWNLOAD_LINK=https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/${PKG_NAME}
  SHA256SUM="1a64c807716e10c872f1618852d95f4893d81667fe6e691ef696489103c9b460"
  download_if_not_cached $PKG_NAME $SHA256SUM $DOWNLOAD_LINK

  apt-get -y update && \
    apt-get -y install \
    zlib1g-dev

  # https://docs.bazel.build/versions/master/install-ubuntu.html#step-3-install-a-jdk-optional
  # openjdk-11-jdk

  dpkg -i $PKG_NAME

  ## buildifier ##
  PKG_NAME="buildifier"
  BUILDIFIER_VERSION="3.3.0"
  CHECKSUM="0c5df005e2b65060c715a7c5764c2a04f7fac199bd73442e004e0bf29381a55a"
  DOWNLOAD_LINK="https://github.com/bazelbuild/buildtools/releases/download/${BUILDIFIER_VERSION}/buildifier"
  download_if_not_cached "${PKG_NAME}" "${CHECKSUM}" "${DOWNLOAD_LINK}"

  chmod a+x ${PKG_NAME}
  cp -f ${PKG_NAME} "${SYSROOT_DIR}/bin"
  rm -f ${PKG_NAME}

  ## buildozer
  PKG_NAME="buildozer"
  BUILDOZER_VERSION="3.3.0"
  CHECKSUM="6618c2a4473ddc35a5341cf9a651609209bd5362e0ffa54413be256fe8a4081a"
  DOWNLOAD_LINK="https://github.com/bazelbuild/buildtools/releases/download/${BUILDOZER_VERSION}/buildozer"
  download_if_not_cached "${PKG_NAME}" "${CHECKSUM}" "${DOWNLOAD_LINK}"

  chmod a+x ${PKG_NAME}
  cp ${PKG_NAME} "${SYSROOT_DIR}/bin"
  rm -rf ${PKG_NAME}
  info "Done installing bazel ${VERSION} with buildifier and buildozer"

elif [ "$TARGET_ARCH" == "aarch64" ]; then
  # TODO(xiaoxq): Stick to v3.2 for a while until we have ARM machine to work with.
  BAZEL_ARM_VERSION="3.4.0"
  # Ref: https://docs.bazel.build/versions/master/install-compile-source.html
  # Ref: https://github.com/storypku/storydev/blob/master/bazel-build/build-bazel-from-source.md
  # Download Mode
  ARM64_BINARY="bazel-${BAZEL_ARM_VERSION}-linux-arm64"
  PKG_NAME="bazel"
  DOWNLOAD_LINK="https://github.com/bazelbuild/bazel/releases/download/${BAZEL_ARM_VERSION}/${ARM64_BINARY}"
  CHECKSUM="440672f319be239d7dd5d7c5062edee23499dd49b49e89cc26dc9d44aa044a96"
  download_if_not_cached "${ARM64_BINARY}" "${CHECKSUM}" "${DOWNLOAD_LINK}"
  chmod a+x ${ARM64_BINARY}
  mv -f ${ARM64_BINARY} "${SYSROOT_DIR}/bin/${PKG_NAME}"
else
  error "Target arch ${TARGET_ARCH} not supported yet"
fi

# Clean up cache to reduce layer size.
apt-get clean && \
    rm -rf /var/lib/apt/lists/*
