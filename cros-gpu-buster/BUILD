# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

# Empty package, we don't yet need anything special for buster but we will.
pkg_tar(
    name = "debian-data-buster",
    extension = "tar.gz",
)

pkg_deb(
    name = "deb",
    architecture = "all",
    conflicts = ["cros-gpu-alpha"],
    data = ":debian-data-buster",
    depends = ["apt-transport-https"],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-gpu",
    section = "misc",
    version = "10.7",
    visibility = ["//cros-debs:__pkg__"],
)
