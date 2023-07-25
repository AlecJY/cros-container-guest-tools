#!/bin/bash
# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

build_guest_tools() {
    local src_root="${KOKORO_ARTIFACTS_DIR}"/git/cros-container-guest-tools
    local result_dir="${src_root}"/guest_debs
    mkdir -p "${result_dir}"

    cd "${src_root}"

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

    if [[ "${arch}" = "arm"* && "$(uname -m)" != "aarch64" ]]; then
        sudo dpkg -i "${KOKORO_GFILE_DIR}/qemu-user-static_ubuntu6.2_amd64.deb"
    fi

    sudo mkdir /tmpfs/pbuilder
    sudo mount --bind /tmpfs/pbuilder /var/cache/pbuilder

    local cache_url="gs://pbuilder-apt-cache/debian-${dist}-${arch}"
    local cache_dir="/var/cache/pbuilder/debian-${dist}-${arch}/aptcache"
    sudo mkdir -p "${cache_dir}"
    sudo gsutil -m -q rsync "${cache_url}" "${cache_dir}"

    sudo mv "${src_root}/mesa/"{.pbuilder,.pbuilderrc} /root/
    # Backported build dependencies are needed for newer libdrm and mesa.
    # This hack omits them for other builds.
    if [[ "${packages[*]}" != "libdrm mesa" ]]; then
        sudo rm -f /root/.pbuilder/hooks/E01apt-preferences
    fi

    pushd "${KOKORO_ARTIFACTS_DIR}/git" > /dev/null

    sudo "${src_root}/mesa/sync-and-build.sh" "${dist}" "${arch}" \
      "${buildresult}" "${packages[@]}"

    sudo gsutil -m -q rsync "${cache_dir}" "${cache_url}"

    popd > /dev/null
}

# Builds the Crostini IME Debian package for a single architecture, for both
# bookworm and bullseye.
build_cros_im_shard() {
    [[ $# -eq 1 ]]
    local arch="$1"
    local src_root="${KOKORO_ARTIFACTS_DIR}"/git/platform2/vm_tools/cros_im
    cd "${src_root}"

    local releases="bullseye bookworm"
    # pbuilder may not be installed yet, so create both directories.
    sudo mkdir -p /tmpfs/pbuilder /var/cache/pbuilder
    sudo mount --bind /tmpfs/pbuilder /var/cache/pbuilder

    for dist in ${releases}; do
        if [[ "${dist}" == "bookworm" ]]; then
            # The debian-archive-keyring in Ubuntu 20.04 is too old, install a
            # newer version for bookworm keys.
            sudo dpkg -i \
              "${KOKORO_GFILE_DIR}/debian-archive-keyring_2023.3ubuntu1_all.deb"
        fi

        local cache_url="gs://pbuilder-apt-cache/debian-${dist}-${arch}"
        local cache_dir="/var/cache/pbuilder/debian-${dist}-${arch}/aptcache"
        sudo mkdir -p "${cache_dir}"

        sudo gsutil -m -q rsync "${cache_dir}" "${cache_url}"

        sudo ./build-packages "${dist}" "${arch}"

        sudo gsutil -m -q rsync "${cache_dir}" "${cache_url}"
    done

    # Copy resulting debs to results directory.
    local result_dir="${src_root}"/cros_im_debs
    mkdir -p "${result_dir}"
    cp -r *_cros_im_debs "${result_dir}"
}