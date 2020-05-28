#！/bin/bash

# Copyright 2020 NXP
# SPDX-License-Identifier: BSD-3-Clause

CWD=$(dirname $(readlink -f "$0"))

# check out pytorch code
if [ ! -d pytorch ]; then
  git clone --recursive https://github.com/pytorch/pytorch
fi
cd pytorch
git checkout v1.5.0 -b v1.5.0
git reset --hard v1.5.0
git submodule sync
git submodule update --init --recursive

# patch the code with fix on aarch64
git am $CWD/0001-QNNPACK-q8gemm-8x8-dq-aarch64-neon.S-fix-mov-operand.patch

# build pytorch wheel file
export USE_CUDA=0
export USE_NNPACK=0
export USE_QNNPACK=0
export CMAKE_PREFIX_PATH=/usr/bin
export PYTORCH_BUILD_VERSION=1.5.0
export PYTORCH_BUILD_NUMBER=1

python3 setup.py bdist_wheel

# check the wheel file in dist folder
# mv dist/*.whl topdir/whl


# build the wheel file for torchvision
cd $CWD
if [ ! -d vision ]; then
  git clone https://github.com/pytorch/vision.git -b v0.5.1
fi
cd vision
git reset --hard v0.6.0

# pytorch is build dependcy for torchvision, check and install it.
torch_pkg="$(python3 -m pip list --format=freeze | grep "torch==1.5.0")"
if [ -z "$torch_pkg" ]; then
  torch_wheel=$(ls $CWD/pytorch/dist/torch-*.whl)
  yes | python3 -m pip install $torch_wheel
fi

export BUILD_VERSION=0.6.0
python3 setup.py bdist_wheel

# check the wheel file in dist folder
# mv dist/*.whl topdir/whl
