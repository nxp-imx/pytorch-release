#！/bin/bash

# Copyright 2020 NXP
# SPDX-License-Identifier: MIT

# check out pytorch code
git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
git checkout v1.5.0 -b v1.5.0
git submodule sync
git submodule update --init --recursive

# patch the code with fix on aarch64
git am 0001-QNNPACK-q8gemm-8x8-dq-aarch64-neon.S-fix-mov-operand.patch

# build pytorch wheel file
export USE_CUDA=0
export USE_NNPACK=0
export USE_QNNPACK=0
export CMAKE_PREFIX_PATH=/usr/bin

python3 setup.py bdist_wheel

# check the wheel file in dist folder
# mv dist/*.whl topdir/whl


# build the wheel file for torchvision
git clone https://github.com/pytorch/vision.git -b v0.5.1
cd vision
git reset --hard v0.6.0
python3 setup.py bdist_wheel

# check the wheel file in dist folder
# mv dist/*.whl topdir/whl
