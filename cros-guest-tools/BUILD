# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "debian-data",
)

DEPENDS = [
    "cros-garcon",
    "cros-host-fonts",
    "cros-notificationd",
    "cros-sommelier",
    "cros-ui-config",
]

RECOMMENDS = [
    "bash-completion",
    "bzip2",
    "cros-apt-config",
    "cros-gpu",
    "cros-logging",
    "cros-sommelier-config",
    "cros-sudo-config",
    "cros-systemd-overrides",
    "cros-vmstat-metrics",
    "cros-wayland",
    "curl",
    "dbus-user-session",
    "dbus-x11",
    "file",
    "fuse3",
    "git",
    "gnupg",
    "iputils-ping",
    "iptables",
    "less",
    "libxss1",
    "man-db",
    "udev",
    "unzip",
    "usbutils",
    "vim",
    "wget",
    "xz-utils",
]

pkg_deb(
    name = "deb-bookworm",
    architecture = "all",
    data = ":debian-data",
    depends = DEPENDS + ["cros-im"],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/containers/cros-container-guest-tools/",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-guest-tools",
    recommends = RECOMMENDS + [
        "cros-pipe-config",
    ],
    section = "misc",
    version = "0.39",
    visibility = ["//cros-debs:__pkg__"],
)

pkg_deb(
    name = "deb-bullseye",
    architecture = "all",
    data = ":debian-data",
    depends = DEPENDS + ["cros-im"],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/containers/cros-container-guest-tools/",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-guest-tools",
    recommends = RECOMMENDS + ["cros-pipe-config"],
    section = "misc",
    # To maintain a clean upgrade path, the version should sort before the
    # :deb-bookworm versions.
    version = "0.39~cros11",
    visibility = ["//cros-debs:__pkg__"],
)

pkg_deb(
    name = "deb-buster",
    architecture = "all",
    data = ":debian-data",
    depends = DEPENDS,
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/containers/cros-container-guest-tools/",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-guest-tools",
    recommends = RECOMMENDS + ["cros-pulse-config"],
    section = "misc",
    # To maintain a clean upgrade path, the version should sort before the
    # :deb-bookworm and :deb-bullseye versions.
    version = "0.39~cros10",
    visibility = ["//cros-debs:__pkg__"],
)
