#!/usr/bin/env bash

# ipkg-make-index -- stdout Packages manifest index
# based on a script by OpenWrt team

set -e

pkg_dir=$1

if [ -z $pkg_dir ] || [ ! -d $pkg_dir ]; then
	echo "Usage: ipkg-make-index <package_directory>" >&2
	exit 1
fi

empty=1

for pkg in `find $pkg_dir -name '*.ipk' | sort`; do
	empty=
	name="${pkg##*/}"
	name="${name%%_*}"
	[[ "$name" = "kernel" ]] && continue
	[[ "$name" = "libc" ]] && continue
	echo "Generating index for package $pkg" >&2
	file_size=$(stat -L -c%s $pkg)
	md5sum=$(openssl dgst -md5 $pkg | awk '{print $2}')
	#LEGACY#sha256sum=$(openssl dgst -sha256 $pkg | awk '{print $2}')
	# Take pains to make variable value sed-safe
	#LEGACY#sed_safe_pkg=`echo $pkg | sed -e 's/^\.\///g' -e 's/\\//\\\\\\//g'`
	#LEGACY#tar -xzOf $pkg ./control.tar.gz | tar xzOf - ./control | sed -e "s/^Description:/Filename: $sed_safe_pkg\\
	basename_pkg=`basename $pkg`
	ar -p $pkg ./control.tar.gz | tar xzOf - ./control | sed -e "s/^Description:/Filename: $basename_pkg\\
Size: $file_size\\
MD5sum: $md5sum\\
Description:/"
	echo ""
done
[ -n "$empty" ] && echo
exit 0
