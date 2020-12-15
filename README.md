# About pytorch-release
This release includes building script and python wheel packages(.whl) for pytorch and torchvision on aarch64 platform.
An example to show how to use the pytroch engine is included as well. Currently it supports the native building on NXP aarch64 platform with BSP SDK.

# Build
1. Get the latest IMX BSP from https://source.codeaurora.org/external/imx/imx-manifest.

2. Set up the build environment for one of the NXP aarch64 platforms and edit the
conf/local.conf to add the following dependency for pytorch native build:
```
IMAGE_INSTALL_append = " python3-dev python3-pip python3-wheel python3-pillow python3-setuptools python3-numpy python3-pyyaml python3-cffi python3-future cmake ninja packagegroup-core-buildessential git git-perltools libxcrypt libxcrypt-dev python3-typing-extensions"
```
3. Build the BSP images like the following command:
```
$ bitbake imx-image-full
```
4. Clone this repo and execute the build script on NXP aarch64 platform to generate wheel packages:
```
$ cd /path/to/pytorch-release/src
$ ./build.sh
```

# Installation
$ pip3 install /path/to/torch-1.7.1-cp38-cp38-linux_aarch64.whl

$ pip3 install /path/to/torchvision-0.8.2-cp38-cp38-linux_aarch64.whl

# API overview

#### Getting started
Load the model file and take mobilenetv2 model for example:
```python
model = models.MobileNetV2()
model.load_state_dict(torch.load('./mobilenet_v2-b0353104.pth'))
# Put the model in eval mode
model.eval()
```
Load an image and preprocess it:
```python
img = Image.open(image_file)
img_t = preprocess(img)
batch_t = torch.unsqueeze(img_t, 0)
```
Perform inference and get the results back:
```python
with torch.no_grad():
    output = model(batch_t)
percentage = torch.nn.functional.softmax(output[0], dim=0) * 100
tensor_sort, index_sort = torch.sort(percentage, descending=True)
[print((classes[idx], percentage[idx].item())) for idx in index_sort[:5]]
```

#### Running examples

There is an example located in the examples folder, which require urllib, PIL and maybe some other Python3 modules depending on your image.
You may install the missing modules using pip3.

To run the example you may simply execute it using the Python3 interpreter. There are no arguments and the resources are downloaded by the scripts:
```bash
$ python3 pytorch_mobilenetv2.py
```

The output should look similar to the following:
```
File does not exist, download it from https://download.pytorch.org/models/mobilenet_v2-b0353104.pth
... 100.00%, downloaded size: 13.55 MB
File does not exist, download it from https://raw.githubusercontent.com/Lasagne/Recipes/master/examples/resnet50/imagenet_classes.txt
... 100.00%, downloaded size: 0.02 MB
File does not exist, download it from https://s3.amazonaws.com/model-server/inputs/kitten.jpg
... 100.00%, downloaded size: 0.11 MB
('tabby, tabby cat', 46.34805679321289)
('tiger cat', 35.17839431762695)
('Egyptian cat', 15.802854537963867)
('lynx, catamount', 1.1611212491989136)
('tiger, Panthera tigris', 0.20774540305137634)


```
