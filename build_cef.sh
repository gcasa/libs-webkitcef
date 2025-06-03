#!/bin/sh

sudo apt update
sudo apt install cmake g++ git \
  libgtk-3-dev libnss3 libxcomposite-dev libxdamage-dev \
  libxrandr-dev libasound2 libatk1.0-dev libatk-bridge2.0-dev \
  libx11-dev libxext-dev libxfixes-dev libxrender-dev \
  libxcb1-dev libx11-xcb-dev libxcb-dri3-dev

tar -xvjf cef_binary_*.tar.bz2
# cd cef_binary_*

# rm -rf build
# mkdir build
# cd build
# cmake -DCMAKE_BUILD_TYPE=Release ..
# make -j$(nproc)
