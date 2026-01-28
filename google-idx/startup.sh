#!/usr/bin/env sh

nohup $PWD/$Xray -c $PWD/config.json 1>$PWD/$Xray.log 2>&1 &
