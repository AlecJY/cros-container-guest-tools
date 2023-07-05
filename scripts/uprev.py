#!/usr/bin/env python3
# Copyright 2020 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Uprev crostini tast data dependencies"""

import argparse
import itertools
import json
import os
import subprocess
import urllib.request

BUCKET_NAME = 'cros-containers-staging'
ARCHES = ['amd64', 'arm64']
CONTAINER_TYPES = ['test', 'app_test']
RELEASES = ['buster', 'bullseye']
PROJECTS = [
    ('chromiumos/platform/tast-tests',
     'src/go.chromium.org/tast-tests/cros/local/crostini/data'),
    ('chromeos/platform/tast-tests-private',
     'src/go.chromium.org/tast-tests-private/crosint/local/crostini/data'),
]
COMMIT_MSG = '''Uprev crostini data dependencies

BUG=none
TEST=CQ
'''


def update_data_file(url, filepath, size, sha256sum):
    result = {'url': url, 'size': size, 'sha256sum': sha256sum}

    print(f'Updated {os.path.basename(filepath)}')
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=4, sort_keys=True)
        f.write('\n')

def update_project(project, path, images, base_url):
    print(f'Updating {project}...')
    project = subprocess.check_output(
        ['repo', 'list', '-pf', project]
    ).decode().strip()
    data_dir = os.path.join(project, path)

    for arch, ctype, release in itertools.product(
        ARCHES, CONTAINER_TYPES, RELEASES):
        # The container URLs use 'arm64', but the tast data files use 'arm'
        if arch == 'arm64':
            file_arch = 'arm'
        else:
            file_arch = arch

        product = images['products'][f'debian:{release}:{arch}:{ctype}']
        latest_container = max(product['versions'].keys())
        items = product['versions'][latest_container]['items']

        metadata_item = items['lxd.tar.xz']
        metadata_file = (f'crostini_{ctype}_container_metadata_'
            + f'{release}_{file_arch}.tar.xz.external')
        update_data_file(
            base_url + metadata_item['path'],
            os.path.join(data_dir, metadata_file),
            metadata_item['size'],
            metadata_item['sha256'],
        )

        rootfs_item = items['rootfs.squashfs']
        rootfs_file = (f'crostini_{ctype}_container_rootfs_'
            + f'{release}_{file_arch}.squashfs.external')
        update_data_file(
            base_url + rootfs_item['path'],
            os.path.join(data_dir, rootfs_file),
            rootfs_item['size'],
            rootfs_item['sha256'],
        )

    print(f'Committing changes for {project}')
    subprocess.call(
        ['git', 'add', path], cwd=project, check=True
    )
    subprocess.call(
        ['git', 'commit', '-m', COMMIT_MSG], cwd=project, check=True
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        'milestone', help='milestone number, e.g. 78')
    args = parser.parse_args()
    milestone = args.milestone

    with urllib.request.urlopen(
        f'https://storage.googleapis.com/{BUCKET_NAME}'
        + f'/{milestone}/streams/v1/images.json'
    ) as url:
        images = json.loads(url.read())

    base_url = f'gs://{BUCKET_NAME}/{milestone}/'

    subprocess.check_call(
        ['repo', 'start', '--verbose', f'crostini-uprev-{milestone}']
        + [project for project, path in PROJECTS]
    )

    for project, path in PROJECTS:
        update_project(project, path, images, base_url)

    print('Tast data dependencies updated')
    print('Now upload these changes with '
        + f'"repo upload -b crostini-uprev-{milestone}"')

if __name__ == '__main__':
    main()
