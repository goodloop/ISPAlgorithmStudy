# !/usr/bin/python3
# -*- coding: utf-8 -*-

"""
@Author: Fred
@Project:
@File: dataPreprocessing.py
@Describe: preprocessing the image data for training
               crop the images whose size is above VGA to VGA
@Date: 2022-04-22
@E-mail: wtzhu_13@163.com
@Version:
@Copyright: All rights reserved wtzhu
------------------------------------------
author      |   Date    |   Describe
------------------------------------------
Fred        | 20220422  | crop image to the same size
------------------------------------------    
"""
import math
import os
import cv2 as cv
import numpy as np
import skimage.io
from shutil import copyfile
import matplotlib.pyplot as plt

data_dir = "E:\\Fred\\ISP\\trainData\\AboveVGA"
cropImages_dir = "E:\\Fred\\ISP\\trainData\\cropImages"


def crop_image_to_VGA():
    images_list = os.listdir(data_dir)
    width_new, high_new = (640, 480)

    for image_name in images_list:
        img = cv.imread(os.path.join(data_dir, image_name))
        height, width, channel = img.shape
        img_crop = img[math.ceil((height - high_new) / 2): height - ((height - high_new) // 2), math.ceil((width - width_new) / 2): width - ((width - width_new) // 2), :]
        # print("==== crop {} to {}*{} ====".format(image_name, img_crop.shape[1], img_crop.shape[0]))
        if img_crop.shape != (480, 640, 3):
            print(image_name, img_crop.shape)
        # saveName = image_name.replace("bmp", "jpg")
        # cv.imwrite(os.path.join(cropImages_dir, saveName), img_crop)


def jpg2RAW():
    # todo jpg to raw
    """Bayer mosaic.
         G R G R
         B G B G
         G R G R
         B G B G
    """
    images_list = os.listdir(cropImages_dir)
    for im in images_list:
        img = cv.imread(os.path.join(cropImages_dir, im))
        # mos = np.copy(img)
        # mask = np.zeros(img.shape)
        # print(mask.shape)
        # # blue
        # mask[0::2, 1::2, 0] = 1
        #
        # # green
        # mask[0::2, 0::2, 1] = 1
        # mask[1::2, 1::2, 1] = 1
        #
        # # red
        # mask[1::2, 0::2, 2] = 1
        #
        # masic_image = mos * mask
        # a = masic_image.astype(np.uint8)
        # plt.figure()
        # plt.imshow(a)
        # plt.show()


if __name__ == '__main__':
    # jpg2RAW()
    crop_image_to_VGA()
