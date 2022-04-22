# !/usr/bin/python3
# -*- coding: utf-8 -*-

"""
@Author: Fred
@Project:
@File: DeepJointDemosaickingAndDenoising.py
@Describe: Pytorch implementation the demosaicking model of:
                Deep Joint Demosaicking and Denoising
                Micha¨el Gharbi, Gaurav Chaurasia, Sylvain Paris, Fr´edo Durand
@Date: 20220421
@E-mail: wtzhu_13@163.com
@Version:
@Copyright: All rights reserved wtzhu
------------------------------------------
author      |   Date    |   Describe
------------------------------------------
wtzhu       |           |
------------------------------------------    
"""

from collections import OrderedDict
import torch as th
import torch.nn as nn

# _BAYER_WEIGHTS = resource_filename(__name__, 'data/bayer.pth')


class DJDDNetwork(nn.Module):
    def __init__(self, width=64, depth=16, pre_trained=False, padding=True):
        super(DJDDNetwork, self).__init__()

        self.width = width
        self.depth = depth

        # downSampled to 4 channels
        self.down_sample = nn.Conv2d(3, 4, (2, 2), stride=(2, 2))
        # Conv2d and Relu
        self.layers = OrderedDict()
        if padding:
            padding = 1
        else:
            padding = 0
        for i in range(depth - 1):
            in_size = width
            out_size = width
            if i == 0:
                in_size = 4
            self.layers["Conv_{}".format(i + 1)] = \
                nn.Conv2d(in_size, out_size, kernel_size=(3, 3), padding=padding)
            self.layers["ReLU_{}".format(i + 1)] = nn.ReLU(inplace=True)

        self.main_layers = nn.Sequential(self.layers)
        # residual
        self.residual = nn.Conv2d(width, 12, (1, 1))
        # upSampled
        self.up_sample = nn.ConvTranspose2d(12, 3, (2, 2), stride=(2, 2))

        self.final_process = nn.Sequential(
            nn.Conv2d(6, width, (3, 3), padding=padding),
            nn.ReLU(inplace=True),
            nn.Conv2d(width, 3, (1, 1))
        )
        # Load weights
        if pre_trained:
            # toDo load pre_trained weight
            print("load weight")

    def forward(self, inputs):
        F0 = self.down_sample(inputs)
        features = self.main_layers(F0)
        residual = self.residual(features)
        FD1 = self.up_sample(residual)
        FD1 = th.cat((inputs, FD1), dim=1)
        outputs = self.final_process(FD1)
        return outputs


if __name__ == '__main__':
    net = DJDDNetwork()
    print(net)
    inTensor = th.randn(1, 3, 128, 128)
    output = net(inTensor)
    print(output.shape)
