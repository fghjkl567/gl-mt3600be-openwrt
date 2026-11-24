#!/bin/sh
set -eu

REPO=https://github.com/FAN789/luci-app-h5000m-fancontrol.git
REV=9eaf2524830eae7e17139983713fd22eb3c2d14a
DEST=${1:-package/luci-app-h5000m-fancontrol}

if [ -d "$DEST/.git" ]; then
	git -C "$DEST" fetch --depth 1 origin "$REV"
else
	mkdir -p "$(dirname "$DEST")"
	git clone --no-checkout "$REPO" "$DEST"
	git -C "$DEST" fetch --depth 1 origin "$REV"
fi

git -C "$DEST" checkout --detach FETCH_HEAD
