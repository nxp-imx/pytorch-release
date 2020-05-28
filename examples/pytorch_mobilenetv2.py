# Copyright 2020 NXP
# SPDX-License-Identifier: BSD-3-Clause

import os
from urllib.parse import urlparse
import urllib.request
import torch
from torchvision import models
from torchvision import transforms
from PIL import Image
import numpy as np
import ssl

def show_progress(count, block_size, total_size):
    downloaded = count * block_size
    percent = 100. * downloaded / total_size
    end_str = '\r'
    if(percent >= 100):
        end_str = '\n'
        percent = 100
    print('... %.2f%%, downloaded size: %.2f MB' % (percent, downloaded/1024/1024), end=end_str)

def download_file(url: str):
    name = urlparse(url)
    name = os.path.basename(name.path)

    if(os.path.exists(name)):
        return name
    else:
        print('File does not exist, download it from {}'.format(url))
        urllib.request.urlretrieve(url, filename=name, reporthook=show_progress)

    return name

ssl._create_default_https_context = ssl._create_unverified_context
model_file = download_file('https://download.pytorch.org/models/mobilenet_v2-b0353104.pth')
label_file = download_file('https://raw.githubusercontent.com/Lasagne/Recipes/master/examples/resnet50/imagenet_classes.txt')
image_file = download_file('https://s3.amazonaws.com/model-server/inputs/kitten.jpg')

#Constructs a MobileNetV2 architecture
model = models.MobileNetV2()
model.load_state_dict(torch.load(model_file))
# Put the model in eval mode
model.eval()

preprocess = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

img = Image.open(image_file)
img_t = preprocess(img)
batch_t = torch.unsqueeze(img_t, 0)

with torch.no_grad():
    output = model(batch_t)

with open(label_file) as f:
    classes = [line.strip() for line in f.readlines()]

percentage = torch.nn.functional.softmax(output[0], dim=0) * 100
tensor_sort, index_sort = torch.sort(percentage, descending=True)
[print((classes[idx], percentage[idx].item())) for idx in index_sort[:5]]

