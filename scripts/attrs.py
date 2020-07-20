#!/usr/bin/env python
"""
    Extract the project version from the given CMakeLists.txt

    When running from shell, returns 0 on success, some other value otherwise
"""
import argparse
import sys
import os

def expand_path(path):
    """Expands variables from the given path and turns it into absolute path"""

    return os.path.abspath(os.path.expanduser(os.path.expandvars(path)))

def proj_name(cml_path=None):
    """
    Retrieve the project-name from CMakeLists.txt

    @returns "x.y.z", {"major": x, "minor": y, "patch": z}
    """

    if cml_path is None:
        cml_path = os.sep.join(["..", "CMakeLists.txt"])

    with open(cml_path) as cmake:
        for line in cmake.readlines():
            if "project(" not in line:
                continue

            _, vtxt = line.split("project(", 1)

            return vtxt.strip()

    return ""


def proj_ver(cml_path=None):
    """
    Retrieve the project-version from CMakeLists.txt

    @returns "x.y.z", {"major": x, "minor": y, "patch": z}
    """

    if cml_path is None:
        cml_path = os.sep.join(["..", "CMakeLists.txt"])

    with open(cml_path) as cmake:
        for line in cmake.readlines():
            if "\tVERSION " not in line:
                continue

            _, vtxt = line.split("VERSION ", 1)

            return vtxt.strip()

    return ""

def setup():
    """Parse command-line arguments"""

    attrs = {
        "ver": proj_ver,
        "name": proj_name,
    }

    prsr = argparse.ArgumentParser(
        description="Extract attributes from the given CMakeLists.txt",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    prsr.add_argument(
        "--cml",
        help="Path to 'CMakeLists.txt'",
        required=True
    )
    prsr.add_argument(
        "attr",
        help="Attribute to retrieve from CMakeLists.txt",
        choices=attrs.keys(),
    )
    args = prsr.parse_args()
    args.cml = expand_path(args.cml)
    args.func = attrs[args.attr]

    return args

def main(args):
    """Entry point"""

    try:
        print(args.func(args.cml))
    except FileNotFoundError:
        return 1

    return 0

if __name__ == "__main__":
    sys.exit(main(setup()))
