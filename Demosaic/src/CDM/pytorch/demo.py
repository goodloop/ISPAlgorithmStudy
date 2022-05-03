# !/usr/bin/python3
# -*- coding: utf-8 -*-

"""
@Author: Fred
@Project:
@File: demo.py
@Describe:
@Date: 20220426
@E-mail: wtzhu_13@163.com
@Version:
@Copyright: All rights reserved wtzhu
------------------------------------------
author      |   Date    |   Describe
------------------------------------------
wtzhu       |           |
------------------------------------------
"""
import torchvision
from torch import nn
import torch
import cv2 as cv
import matplotlib.pyplot as plt
from DeepJointDemosaickingAndDenoising import DJDDNetwork


model = DJDDNetwork()
model.load_state_dict(torch.load("model_GPU_2000.pth"))
# model = torch.load("model_cpu_100.pth")
model.eval()
raw = cv.imread("../../images/00025_raw.png")

# ndarray to tensor
transform = torchvision.transforms.ToTensor()
tensor_raw = transform(raw)
# Turn 3 dimensions into 4 dimensions that model need
tensor_raw = torch.unsqueeze(tensor_raw, dim=0)
print(tensor_raw.shape)
# 4 dimensions tensor to 3 dimensions np.array
output = model(tensor_raw)[0].detach().numpy().transpose(1, 2, 0)   # .astype('uint8')
img = cv.cvtColor(output, cv.COLOR_BGR2RGB)
# cv.imwrite("output1.jpg", output.astype('uint8'))  # , [int(cv.IMWRITE_JPEG_QUALITY), 100]
print(img.shape)
plt.figure()
plt.imshow(img)
plt.show()



