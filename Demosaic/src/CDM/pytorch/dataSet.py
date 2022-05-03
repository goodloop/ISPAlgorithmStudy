# !/usr/bin/python3
# -*- coding: utf-8 -*-

"""
@Author: Fred
@Project:
@File:
@Describe: 
@Date:
@E-mail: wtzhu_13@163.com
@Version: 
@Copyright: All rights reserved wtzhu
------------------------------------------
author      |   Date    |   Describe
------------------------------------------
wtzhu       |           |
------------------------------------------
"""
import os
import cv2 as cv
from PIL import Image
from torch.utils.data import Dataset, DataLoader
from torch.utils.tensorboard import SummaryWriter
from torchvision import transforms
from torchvision.utils import make_grid


class MyData(Dataset):

    def __init__(self, root_dir, sample_dir, label_dir, transform):
        self.root_dir = root_dir
        self.sample_dir = sample_dir
        self.label_dir = label_dir
        self.sample_list = os.listdir(os.path.join(self.root_dir, self.sample_dir))
        self.label_list = os.listdir(os.path.join(self.root_dir, self.label_dir))
        self.transform = transform

        self.sample_list.sort()
        self.label_list.sort()

    def __getitem__(self, index):
        sample_name = self.sample_list[index]
        label_name = self.label_list[index]
        # print(sample_name, "--->", label_name)
        sample_item_path = os.path.join(self.root_dir, self.sample_dir, sample_name)
        label_item_path = os.path.join(self.root_dir, self.label_dir, label_name)
        # sample = Image.open(sample_item_path)
        # label = Image.open(label_item_path)

        sample = cv.imread(sample_item_path)
        sample = cv.cvtColor(sample, cv.COLOR_BGR2RGB)
        label = cv.imread(label_item_path)
        label = cv.cvtColor(label, cv.COLOR_BGR2RGB)

        # transform = transforms.ToTensor()
        # sample = transform(sample)
        # label = transform(label)
        sample = self.transform(sample)
        label = self.transform(label)
        return sample, label

    def __len__(self):
        assert len(self.sample_list) == len(self.label_list)
        return len(self.sample_list)


if __name__ == '__main__':
    # CenterCrop(img) (PIL Image or Tensor): Image to be cropped.
    # read image by cv need to change to tensor first
    train_transform = transforms.Compose([transforms.ToTensor(), transforms.CenterCrop((480, 640))])
    train_root_dir = "E:\\Fred\\ISP\\trainData\\djddData\\train"
    train_sample_dir = "samples"
    train_label_dir = "labels"
    train_dataset = MyData(train_root_dir, train_sample_dir, train_label_dir, train_transform)

    dataloader = DataLoader(train_dataset, batch_size=10, num_workers=0)
    # writer = SummaryWriter("logs")
    for i, j in enumerate(dataloader):
        imgs, labels = j
        print("----bach {}--- is OK".format(i))
    #     writer.add_image("train_data_b2", make_grid(imgs), i)
    #     writer.add_image("labels_data_b2", make_grid(labels), i)
    # writer.close()

