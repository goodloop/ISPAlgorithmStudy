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
import argparse
import numpy as np


# todo rgb2raw
def rgb2raw(org_img):
    """
    G B
    R G
    """
    mos = np.copy(org_img)
    mask = np.zeros(org_img.shape)
    # red
    mask[0::2, 1::2, 0] = 1

    # green
    mask[0::2, 0::2, 1] = 1
    mask[1::2, 1::2, 1] = 1

    # blue
    mask[1::2, 0::2, 2] = 1

    masic_image = mos * mask

    raw = masic_image.astype(np.uint8)
    return raw


def main(args):
    # todo org-> cfa

    model = DJDDNetwork()
    # model.load_state_dict(torch.load("model_GPU_2000.pth"))
    model = torch.load("model_cpu_100.pth")
    model.eval()
    # raw = cv.imread("../../images/00025_raw.png")
    org_img = cv.imread(args.input)
    org_rgb_img = cv.cvtColor(org_img, cv.COLOR_BGR2RGB)
    plt.figure()
    plt.imshow(org_rgb_img)
    plt.title("org")

    raw = rgb2raw(org_img)
    cv.imwrite(args.output_mosaicked, raw, [cv.IMWRITE_PNG_COMPRESSION, 0])
    plt.figure()
    plt.imshow(raw)
    plt.title("raw")

    # ndarray to tensor
    transform = torchvision.transforms.ToTensor()
    tensor_raw = transform(raw)
    # Turn 3 dimensions into 4 dimensions that model need
    tensor_raw = torch.unsqueeze(tensor_raw, dim=0)
    # 4 dimensions tensor to 3 dimensions np.array
    output = (model(tensor_raw)[0].detach().numpy().transpose(1, 2, 0) * 255).astype('uint8')
    img = cv.cvtColor(output, cv.COLOR_BGR2RGB)
    cv.imwrite(args.output, output, [cv.IMWRITE_PNG_COMPRESSION, 0])  # , [int(cv.IMWRITE_JPEG_QUALITY), 100]
    print("output shape: {}".format(img.shape))
    plt.figure()
    plt.imshow(img)
    plt.title("output")
    plt.show()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=str, default="kodim19.png", help="path to input image.")
    parser.add_argument("--output", type=str, default="output.png", help="path to output image.")
    parser.add_argument("--output_mosaicked", type=str, default="cfa.png", help="path to ouput cfa image")
    args = parser.parse_args()
    main(args)
