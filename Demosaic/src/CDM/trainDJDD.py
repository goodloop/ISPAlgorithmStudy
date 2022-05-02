# !/usr/bin/python3
# -*- coding: utf-8 -*-

"""
@Author: Fred
@Project:
@File: trainDJDD.py
@Describe: training the model of DJDD using the crop data
@Date: 2022-04-22
@E-mail: wtzhu_13@163.com
@Version:
@Copyright: All rights reserved wtzhu
------------------------------------------
author      |   Date    |   Describe
------------------------------------------
wtzhu       | 20220422  | training model
------------------------------------------    
"""
import torch
from torch import nn
from torch.utils.data import DataLoader
from torch.utils.tensorboard import SummaryWriter
from torchvision import transforms
from DeepJointDemosaickingAndDenoising import DJDDNetwork
from dataSet import MyData
import datetime
import time

# device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# data
train_transform = transforms.Compose([transforms.ToTensor(), transforms.CenterCrop((480, 640))])
# prepare for training data
train_root_dir = "D:\\ISP\\PersonalProjects\\data\\djddData\\train"
train_sample_dir = "samples"
train_label_dir = "labels"
train_dataset = MyData(train_root_dir, train_sample_dir, train_label_dir, train_transform)


# prepare for test data
test_root_dir = "D:\\ISP\\PersonalProjects\\data\\djddData\\Validations"
test_sample_dir = "samples"
test_label_dir = "labels"
test_dataset = MyData(test_root_dir, test_sample_dir, test_label_dir, train_transform)

print("training data size {}".format(len(train_dataset)))
print("test data size {}".format(len(test_dataset)))

# load data
train_dataloader = DataLoader(train_dataset, batch_size=4, num_workers=0)
test_dataloader = DataLoader(test_dataset, batch_size=4, num_workers=0)

# load model
train_model = torch.load("model_cpu_100.pth")
train_model.to(device)
# print(train_model)

# set loss func
loss_fuc = nn.MSELoss()
# loss_fuc.to(device)

# optimizer
lr = 0.01
optimizer = torch.optim.RMSprop(train_model.parameters(), lr=lr)

epochs = 10
train_step = 0
test_step = 0
min_loss = 3e+22
writer = SummaryWriter("train_logs")

start_time = time.time()
for epoch in range(epochs):
    train_model.train()
    for i, data in enumerate(train_dataloader):
        # print("----bach {}--- is OK".format(i+1))
        imgs, labels = data
        imgs = imgs.to(device)
        labels = labels.to(device)
        outputs = train_model(imgs)
        loss = loss_fuc(outputs, labels)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        train_step += 1

        if train_step % 10 == 0:
            print("训练次数：{}, Loss: {} ".format(train_step, loss.item()),
                  datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
            writer.add_scalar("train_loss", loss.item(), train_step)
            batch_time = time.time()
            print("used time {}s".format(batch_time-start_time))
    train_model.eval()
    test_loss = 0
    with torch.no_grad():
        for data in test_dataloader:
            imgs, labels = data
            imgs = imgs.to(device)
            labels = labels.to(device)
            outputs = train_model(imgs)
            test_loss = loss_fuc(outputs, labels)

            if test_loss < min_loss:
                min_loss = test_loss
                print("save model")
                torch.save(train_model, 'model.pth')
    print("loss on test data: {} ".format(test_loss), datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    writer.add_scalar("test_loss", test_loss.item(), test_step)
    test_step += 1
writer.close()
print("finish training")
end_time = time.time()
print("total time: {}min".format((end_time-start_time)/60))
