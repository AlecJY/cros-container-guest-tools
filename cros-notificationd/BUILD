# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "cros-notificationd-dbus-service-files",
    srcs = ["org.freedesktop.Notifications.service"],
    mode = "0644",
    package_dir = "/usr/share/dbus-1/services/",
    strip_prefix = "/cros-notificationd",
)

pkg_tar(
    name = "cros-notificationd-systemd-service-files",
    srcs = ["cros-notificationd.service"],
    mode = "0644",
    package_dir = "/usr/lib/systemd/user/",
    strip_prefix = "/cros-notificationd",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-notificationd-dbus-service-files",
        ":cros-notificationd-systemd-service-files",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-notificationd",
    section = "misc",
    version = "0.3",
    visibility = ["//cros-debs:__pkg__"],
)
