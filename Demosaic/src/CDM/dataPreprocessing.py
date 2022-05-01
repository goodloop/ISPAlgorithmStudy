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
import shutil

import cv2 as cv
import numpy as np
import skimage.io
from shutil import copyfile
import matplotlib.pyplot as plt
import skimage.io

org_data_dir = "E:\\Fred\\ISP\\trainData\\djddData\\train"
cropImages_dir = "E:\\Fred\\ISP\\trainData\\djddData\\train\\labels"
mosaicking_dir = "E:\\Fred\\ISP\\trainData\\djddData\\train\\samples"


def filter_VGA():
    # todo filter the image whose size if above VGA
    images_list = os.listdir(org_data_dir)
    VGA_num = 0
    for img_name in images_list:
        img = cv.imread(os.path.join(org_data_dir, img_name))
        height, width, channel = img.shape
        width_new, high_new = (640, 480)
        if width >= 640 and height >= 480:
            VGA_num += 1
            img_crop = img[math.ceil((height - high_new) / 2): height - ((height - high_new) // 2),
                           math.ceil((width - width_new) / 2): width - ((width - width_new) // 2), :]
            print("{}. ==== crop {} to {}*{} ====".format(VGA_num, img_name, img_crop.shape[1], img_crop.shape[0]))
            if img_crop.shape != (480, 640, 3):
                print(img_name, img_crop.shape)
            save_name = img_name.replace("bmp", "jpg")
            cv.imwrite(os.path.join(cropImages_dir, save_name), img_crop)


def jpg2RAW():
    # todo jpg to raw
    """Bayer mosaic.
         G B
         R G
    """
    images_list = os.listdir(cropImages_dir)
    for i, im in enumerate(images_list):
        img = cv.imread(os.path.join(cropImages_dir, im))
        mos = np.copy(img)
        mask = np.zeros(img.shape)
        print("{}, {}===2RAW===".format((i+1), im))
        # blue
        mask[0::2, 1::2, 0] = 1

        # green
        mask[0::2, 0::2, 1] = 1
        mask[1::2, 1::2, 1] = 1

        # red
        mask[1::2, 0::2, 2] = 1

        masic_image = mos * mask

        a = masic_image.astype(np.uint8)
        cv.imwrite(os.path.join(mosaicking_dir, im.replace(".jpg", "_raw.png")), a, [int(cv.IMWRITE_JPEG_QUALITY), 100])
        # b = cv.imread(os.path.join(mosaicking_dir, im.replace(".jpg", "_raw.png")))
        # rgb_img = cv.cvtColor(b, cv.COLOR_BGR2RGB)
        # plt.figure()
        # plt.imshow(rgb_img)
        # plt.show()


if __name__ == '__main__':
    jpg2RAW()
    # filter_VGA()
