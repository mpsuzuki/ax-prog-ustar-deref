#!/bin/sh
aclocal -I. --force
# autoheader
automake -a
autoconf
