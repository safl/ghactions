#!/bin/sh
# Query the linker version
ld --version || true

# Query the (g)libc version
ldd --version || true

# Install packages via apk
#apk update

script=`basename "$0"`
pkgs="${script/.sh/.txt}"
apk add $(cat "scripts/pkgs/alpine:3.12.0.txt")
