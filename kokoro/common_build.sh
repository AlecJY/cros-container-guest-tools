#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

build_guest_tools() {
    local src_root="${KOKORO_ARTIFACTS_DIR}"/git/cros-container-guest-tools
    local result_dir="${src_root}"/guest_debs
    mkdir -p "${result_dir}"

    cd "${src_root}"

    curl -sSL https://bazel.build/bazel-release.pub.gpg \
        | gpg --dearmor \
        | sudo tee /etc/apt/trusted.gpg.d/bazel.gpg > /dev/null

    sudo tee /etc/apt/sources.list.d/bazel.list > /dev/null << EOF
deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/bazel.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8
EOF
    sudo apt-get -q update
    sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
        bazel-5.3.0 python-is-python3

    # Build all targets.
    bazel-5.3.0 build //cros-debs:debs

    # Copy resulting debs to results directory.
    chmod 644 bazel-bin/cros-debs/*/*.deb
    cp -r bazel-bin/cros-debs/* "${result_dir}"
}

# Builds one of the mesa-related tools. Usage is:
#     build_mesa_shard <distro> <architecture> [<package> ...]
# Which will build <package> for the <distro> debian version with the given
# processor <architecture>.
build_mesa_shard() {
    [[ $# -ge 3 ]]
    local dist="$1"
    local arch="$2"
    shift 2
    local packages=( "$@" )
    local src_root="${KOKORO_ARTIFACTS_DIR}"/git/cros-container-guest-tools
    local buildresult="${KOKORO_ARTIFACTS_DIR}/${dist}_mesa_debs"
    mkdir -p "${buildresult}"

    sudo apt-get -q update
    sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
      debhelper debian-archive-keyring libva-dev pbuilder quilt qemu-user-static

    sudo mv "${src_root}/mesa/buster/"{.pbuilder,.pbuilderrc} /root/

    pushd "${KOKORO_ARTIFACTS_DIR}/git" > /dev/null

    sudo "${src_root}/mesa/buster/sync-and-build.sh" "${dist}" "${arch}" \
      "${buildresult}" "${packages[@]}"

    popd > /dev/null
}

# Builds the Crostini IME Debian package for all supported architectures.
build_cros_im() {
    local src_root="${KOKORO_ARTIFACTS_DIR}"/git/platform2/vm_tools/cros_im
    local result_dir="${src_root}"/cros_im_debs
    mkdir -p "${result_dir}"
    cd "${src_root}"

    # Use qemu-user-static 1:6.2 since the version in Ubuntu 20.04 has a bug
    # that has not yet been patched (b/244998899).
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
        "${KOKORO_GFILE_DIR}"/qemu-user-static_ubuntu6.2_amd64.deb \
        binfmt-support

    sudo ./build-packages

    # Copy resulting debs to results directory.
    cp *_cros_im_debs/* "${result_dir}"
}
