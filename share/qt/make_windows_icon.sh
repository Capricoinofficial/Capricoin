#!/bin/bash
# create multiresolution windows icon
ICON_DST=../../src/qt/res/icons/Capricoin.ico

convert ../../src/qt/res/icons/Capricoin-16.png ../../src/qt/res/icons/Capricoin-128.png ../../src/qt/res/icons/Capricoin-256.png ${ICON_DST}
