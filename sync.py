#!/usr/bin/env python3
# TODO: get rid of rsync, it sucks for creating parent dirs
# TODO: would also be nice to get rid of sh dependency
# TODO: add hook/plugin system for triggering per-file code, e.g. automatically calling
# mkinitcpio if our config is updated for it. Or apparmor_parser.

import os
import sh

from pathlib import Path
import yaml


# def get_mod_time(file: str):
#     stat_buf = os.stat(file)
#     return stat_buf.st_mtime

# this mod time shit is TOO MUCH WORK
# path_git_mod_time = get_mod_time(path_git)
# path_sys_mod_time = get_mod_time(path_sys)
# print(path_sys_mod_time)
# time_diff: float = path_git_mod_time - path_sys_mod_time
# print(time_diff)
# # > 0 implies that git file has been edited more recently
# if time_diff > 0:
#     pass
# # < 0 implies that system file is newer than git file
# elif time_diff < 0:
#     pass
# elif time_diff == 0:
#     pass


class OSRelease(dict):

    def __setitem__(self, key, value):
        if isinstance(key, str):
            key = key.casefold()
        super().__setitem__(key, value)

    def __getitem__(self, key):
        if isinstance(key, str):
            key = key.casefold()
        return super().__getitem__(key)

    def __init__(self, os_release_path='/etc/os-release'):
        super().__init__({'PRETTY_NAME': '',
                          'NAME': '',
                          'VERSION_ID': '',
                          'VERSION': '',
                          'VERSION_CODENAME': '',
                          'ID': '',
                          'ID_LIKE': '',
                          'HOME_URL': '',
                          'SUPPORT_URL': '',
                          'BUG_REPORT_URL': ''
                          })
        for line in Path(os_release_path).open().readlines():
            ini_key: str
            ini_value: str
            ini_key, ini_value = line.split('=')
            self.__setitem__(ini_key.strip(), ini_value.strip())


def install(src_path_str: str, dst_path_str: str):
    try:
        print(f'{src_path_str} -> {dst_path_str}')
        sh.rsync('-r',  src_path_str, dst_path_str)
    except sh.ErrorReturnCode_23:
        print(f'src not found: {src_path_str}')
    except sh.ErrorReturnCode_11:
        print(f'dst not found: {dst_path_str}')


def update_dict(old: dict, new: dict):
    for key in new:
        old[key] = new[key]
    return old


def main():
    print('Loading...')
    release = OSRelease()
    enabled_tags: list = []

    distro: str = ''
    if 'arch' in release['ID'].lower():
        distro = 'ARCH'
    elif 'debian' in release['ID_LIKE'].lower():
        distro = 'DEBIAN'

    print(f'Distro detected: {distro}')
    yaml_data = yaml.safe_load(open("dotfiles.yaml", 'r'))
    user: str = yaml_data['DOTFILES']['USER']
    user_home: str = ''
    try:
        user_home: str = yaml_data['DOTFILES']['USER_HOME']
    except KeyError:
        user_home = f'/home/{user}'
    print(f'User: {user}')
    print(f'User home: {user_home}')
    paths: dict = yaml_data['paths']['default']
    for distro_for_paths in yaml_data['paths']['os']:
        if distro_for_paths == distro:
            update_dict(paths, yaml_data['paths']['os'][distro])

    for tag in yaml_data['paths']['tags']:
        if tag in enabled_tags:
            update_dict(paths, yaml_data['paths']['tags'][tag])

    for src in paths:
        dst = paths[src]
        install(src, dst)



if __name__ == '__main__':
    main()
