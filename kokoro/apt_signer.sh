#!/bin/bash
# Copyright 2018 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex -o pipefail

. "$(dirname "$0")/common.sh" || exit 1

main() {
    require_kokoro_artifacts

    local src_root="${KOKORO_ARTIFACTS_DIR}/git/cros-container-guest-tools"
    local repo_dir="${src_root}"/apt_signed
    mkdir -p "${repo_dir}"

    cp -r "${KOKORO_GFILE_DIR}"/apt_unsigned/* "${repo_dir}"

    # 4EB27DB2A3B88B8B - expires 2024-10-25
    # E88979FB9B30ACF2 - expires 2026-02-14
    local key_ids="4EB27DB2A3B88B8B,E88979FB9B30ACF2"

    # Sign the Release file(s).
    local release_file
    for release_file in "${repo_dir}"/dists/*/Release; do
        /escalated_sign/escalated_sign.py --tool=linux_gpg_sign \
                                          --job-dir=/escalated_sign_jobs -- \
                                          --signing_key="${key_ids}" \
                                          --loglevel=debug \
                                          "${release_file}"

        mv "${release_file}.asc" "${release_file}.gpg"
    done
}

main "$@"
