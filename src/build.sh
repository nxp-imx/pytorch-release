#！/bin/bash

# Copyright 2021 NXP
# SPDX-License-Identifier: BSD-3-Clause

CWD=$(dirname $(readlink -f "$0"))

# check out pytorch code
if [ ! -d pytorch ]; then
  git clone --recursive git://github.com/pytorch/pytorch
fi
cd pytorch
git checkout v2.0.0 -b v2.0.0
git reset --hard v2.0.0
git submodule sync
git submodule update --init --recursive

cd third_party/sleef
git reset --hard 3.5.1
cd -

# build pytorch wheel file
export MAX_JOBS=2
export USE_CUDA=0
export USE_NNPACK=0
export USE_QNNPACK=0
export USE_DISTRIBUTED=0
export USE_MLDNN=0
export USE_FBGEMM=0
export CMAKE_PREFIX_PATH=/usr/bin
export PYTORCH_BUILD_VERSION=2.0.0
export PYTORCH_BUILD_NUMBER=1

python3 setup.py bdist_wheel

# check the wheel file in dist folder
# mv dist/*.whl topdir/whl


# build the wheel file for torchvision
cd $CWD
if [ ! -d vision ]; then
  git clone git://github.com/pytorch/vision.git
fi
cd vision
git checkout v0.15.1 -b v0.15.1
git reset --hard v0.15.1

# pytorch is build dependcy for torchvision, check and install it.
torch_pkg="$(python3 -m pip list --format=freeze | grep "torch==2.0.0")"
if [ -z "$torch_pkg" ]; then
  torch_wheel=$(ls $CWD/pytorch/dist/torch-*.whl)
  yes | python3 -m pip install $torch_wheel
fi

export BUILD_VERSION=0.15.1
export TORCHVISION_USE_FFMPEG=0
python3 setup.py bdist_wheel

# check the wheel file in dist folder
# mv dist/*.whl topdir/whl
