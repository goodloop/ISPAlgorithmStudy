#!/usr/bin/env python
# MIT License
#
# Pytorch implementation of: 
#    COLOR IMAGE DEMOSAICKING VIA DEEP RESIDUAL LEARNING
#    Tan, Runjie and Zhang, Kai and Zuo, Wangmeng and Zhang, Lei
#    2017 IEEE International Conference on Multimedia and Expo (ICME)
# 
# Copyright (c) 2019 Gabriele Facciolo
# derived from Demosaicnet code Copyright (c) 2016 Michael Gharbi
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

"""Run the demosaicking network on an image or a directory containing multiple images."""

import argparse
import skimage.io
import numpy as np
import os
import re
import time
import torch as th
from tqdm import tqdm
import matplotlib.pyplot as plt

import cdmcnn_model as cdmcnn


def _psnr(a, b, crop=0, maxval=1.0):
    """Computes PSNR on a cropped version of a,b"""

    if crop > 0:
        aa = a[crop:-crop, crop:-crop, :]
        bb = b[crop:-crop, crop:-crop, :]
    else:
        aa = a
        bb = b

    d = np.mean(np.square(aa - bb))
    d = -10 * np.log10(d / (maxval * maxval))
    return d


def _uint2float(I):
    if I.dtype == np.uint8:
        I = I.astype(np.float32)
        I = I * 0.00390625
    elif I.dtype == np.uint16:
        I = I.astype(np.float32)
        I = I / 65535.0
    else:
        raise ValueError("not a uint type {}".format(I.dtype))

    return I


def _float2uint(I, dtype):
    if dtype == np.uint8:
        I /= 0.00390625
        I += 0.5
        I = np.clip(I, 0, 255)
        I = I.astype(np.uint8)
    elif dtype == np.uint16:
        I *= 65535.0
        I += 0.5
        I = np.clip(I, 0, 65535)
        I = I.astype(np.uint16)
    else:
        raise ValueError("not a uint type {}".format(dtype))

    return I


def _blob_to_image(blob):
    # input shape h,w,c
    shape = blob.data.shape
    sz = shape[1:]
    out = np.copy(blob.data)
    out = np.reshape(out, sz)
    out = out.transpose((1, 2, 0))
    return out


def bayer_mosaic(im):
    """Bayer mosaic.
    
     G R G R
     B G B G
     G R G R
     B G B G
    """

    mos = np.copy(im)
    mask = np.zeros(im.shape)

    # Red
    mask[0, 0::2, 1::2] = 1

    # green
    mask[1, 0::2, 0::2] = 1
    mask[1, 1::2, 1::2] = 1

    # blue
    mask[2, 1::2, 0::2] = 1

    return mos * mask, mask


def demosaick(net, M):
    from scipy import ndimage
    ### INTERPOLATION of the mask
    #                           [1 2 1]           [0 1 0]
    # R,B template:H_r = H_b =1/4[2 4 2]  H_g = 1/4[1 4 1]
    #                           [1 2 1]           [0 1 0]
    Hg = np.array([[0., 1., 0.],
                   [1., 4., 1.],
                   [0., 1., 0.]])
    Hr = np.array([[1., 2., 1.],
                   [2., 4., 2.],
                   [1., 2., 1.]])
    M[0, 0, :, :] = ndimage.convolve(M[0, 0, :, :], Hr, mode='constant', cval=0.0) / 4.0
    M[0, 1, :, :] = ndimage.convolve(M[0, 1, :, :], Hg, mode='constant', cval=0.0) / 4.0
    M[0, 2, :, :] = ndimage.convolve(M[0, 2, :, :], Hr, mode='constant', cval=0.0) / 4.0

    # get the device of the network and apply it to the variables
    dev = next(net.parameters()).device

    M = th.from_numpy(M).to(device=dev, dtype=th.float)

    start = time.time()

    out, outG = net(M)

    tot_time_ref = time.time() - start

    out = out.cpu().detach().numpy()
    outG = outG.cpu().detach().numpy()

    # reimpose GRBG mosaick
    out[0, 1, 0::2, 0::2] = M[0, 1, 0::2, 0::2]
    out[0, 0, 0::2, 1::2] = M[0, 0, 0::2, 1::2]
    out[0, 2, 1::2, 0::2] = M[0, 2, 1::2, 0::2]
    out[0, 1, 1::2, 1::2] = M[0, 1, 1::2, 1::2]

    tot_time_ref *= 1000
    print("Time  {:.0f} ms".format(tot_time_ref))

    return out, tot_time_ref


def demosaick_load_model(network_path=None):
    if network_path:
        m = th.load(network_path, map_location={'cuda:0': 'cpu'})
    else:
        print("Loading Matconvnet weights")
        m = cdmcnn.CDMCNN_pretrained()
    return m


def main(args):
    # Load the network for the specific application
    model_ref = demosaick_load_model(args.net_path)
    print(model_ref)
    if args.gpu:
        model_ref.cuda()
    else:
        model_ref.cpu()

    model_ref.eval()

    # Pad image to avoid border effects 
    crop = 48
    print("Crop", crop)

    Iref = skimage.io.imread(args.input)
    plt.figure("org")
    plt.imshow(Iref)
    # plt.show()
    if len(Iref.shape) == 4:  # removes alpha
        Iref = Iref[:, :, :3]
    dtype = Iref.dtype
    if dtype not in [np.uint8, np.uint16, np.float16, np.float32, np.float64]:
        raise ValueError('Input type not handled: {}'.format(dtype))

    # if integers make floats
    if dtype in [np.uint8, np.uint16]:
        Iref = _uint2float(Iref)  # 归一化，将值除以最大值

    if args.linear_input:
        print("  - Input is linear, mapping to sRGB for processing")
        Iref = np.power(Iref, 1.0 / 2.2)

    if len(Iref.shape) == 2:
        # Offset the image to match to the mosaic pattern
        if args.offset_x > 0:
            print('  - offset x')
            # Iref = Iref[:, 1:]
            Iref = np.pad(Iref, [(0, 0), (args.offset_x, 0)], 'symmetric')

        if args.offset_y > 0:
            print('  - offset y')
            # Iref = Iref[1:, :]
            Iref = np.pad(Iref, [(args.offset_y, 0), (0, 0)], 'symmetric')
        has_groundtruth = False
        Iref = np.dstack((Iref, Iref, Iref))
    else:
        # No need for offsets if we have the ground-truth
        has_groundtruth = True

    I = Iref * 1

    if crop > 0:
        c = crop + (crop % 2)  # Make sure we don't change the pattern's period
        I = np.pad(I, [(c, c), (c, c), (0, 0)], 'symmetric')

    if has_groundtruth:
        print('  - making mosaick')
    else:
        print('  - formatting mosaick')

    I = np.array(I).transpose(2, 0, 1).astype(np.float32)

    M = bayer_mosaic(I)
    tmp = np.array(M[0]).transpose(1, 2, 0).astype(np.float32)
    plt.figure("CFA")
    plt.imshow(tmp)
    plt.show()
    # c1 = np.copy(tmp)
    # c = _float2uint(c1, dtype)
    # skimage.io.imsave("CFA.png", c)
    # im = np.expand_dims(im, 0)
    # the othe field is just the mask
    M = np.array(M)[:1, :, :, :]  # CFA图像，但是有三个通道的CFA

    with th.no_grad():
        R, runtime = demosaick(model_ref, M)

    R = R.squeeze().transpose(1, 2, 0)
    R = R.clip(0, 1)
    M = M.transpose((2, 3, 1, 0)).squeeze()

    # Remove the padding
    if crop > 0:
        R = R[c:-c, c:-c, :]
        I = I[c:-c, c:-c, :]
        M = M[c:-c, c:-c, :]

    if not has_groundtruth:
        if args.offset_x > 0:
            print('  - remove offset x')
            R = R[:, args.offset_x:]
            I = I[:, args.offset_x:]
            M = M[:, args.offset_x:]

        if args.offset_y > 0:
            print('  - remove offset y')
            R = R[args.offset_y:, :]
            I = I[args.offset_y:, :]
            M = M[args.offset_y:, :]

    if len(Iref.shape) == 2:
        # Offset the image to match the our mosaic pattern
        if args.offset_x == 1:
            print('  - offset x')
            Iref = Iref[:, 1:]

        if args.offset_y == 1:
            print('  - offset y')
            Iref = Iref[1:, :]
        has_groundtruth = False

    if args.linear_input:
        print("  - Input is linear, mapping output back from sRGB")
        R = np.power(R, 2.2)

    if has_groundtruth:
        p = _psnr(R, Iref, crop=crop)
        file_psnr = open(args.output_psnr, 'w')
        file_psnr.write(str(p))
        file_psnr.close()
        print('  PSNR = {:.1f} dB, time = {} ms'.format(p, int(runtime)))
    else:
        print('  - raw image without groundtruth, bypassing metric')
    out = _float2uint(R, dtype)
    out_mosaicked = _float2uint(M, dtype)

    # Write output image
    skimage.io.imsave(args.output, out)
    skimage.io.imsave(args.output_mosaicked, out_mosaicked)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument('--input', type=str, default='input.png', help='path to input image.')
    parser.add_argument('--net_path', type=str, default=None, help='path to model folder.')
    parser.add_argument('--output', type=str, default='output.png', help='path to output image.')
    parser.add_argument('--output_mosaicked', type=str, default='cfa.png', help='path to output image.')
    parser.add_argument('--output_psnr', type=str, default='psnr.txt', help='path to output psnr.')
    parser.add_argument('--offset_x', type=int, default=0, help='number of pixels to offset the mosaick in the x-axis.')
    parser.add_argument('--offset_y', type=int, default=0, help='number of pixels to offset the mosaick in the y-axis.')
    parser.add_argument('--gpu', dest='gpu', action='store_true', help='use the GPU for processing.')

    parser.add_argument('--linear_input', dest='linear_input', action='store_true')

    parser.set_defaults(gpu=False, linear_input=False)

    args = parser.parse_args()

    main(args)
