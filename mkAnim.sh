#!/usr/bin/env bash

convert *.png -delay 4 -scale 20% -coalesce -layers Optimize anim.gif
