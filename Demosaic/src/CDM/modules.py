# clone from https://github.com/mgharbi/demosaicnet

from collections import OrderedDict
from pkg_resources import resource_filename

import numpy as np
import torch as th
import torch.nn as nn


_BAYER_WEIGHTS = resource_filename(__name__, 'data/bayer.pth')


class BayerDemosaick(nn.Module):
    """Released version of the network, best quality.

    This model differs from the published description. It has a mask/filter split
    towards the end of the processing. Masks and filters are multiplied with each
    other. This is not key to performance and can be ignored when training new
    models from scratch.
    """

    def __init__(self, depth=15, width=64, pretrained=True, pad=False):
        super(BayerDemosaick, self).__init__()

        self.depth = depth
        self.width = width

        if pad:
            pad = 1
        else:
            pad = 0

        self.layers = OrderedDict([
            ("pack_mosaic", nn.Conv2d(3, 4, 2, stride=2)),  # Downsample 2x2 to re-establish translation invariance
        ])
        for i in range(depth):
            n_out = width
            n_in = width
            if i == 0:
                n_in = 4
            if i == depth - 1:
                n_out = 2 * width
            self.layers["conv{}".format(i + 1)] = nn.Conv2d(n_in, n_out, 3, padding=pad)
            self.layers["relu{}".format(i + 1)] = nn.ReLU(inplace=True)

        self.main_processor = nn.Sequential(self.layers)
        self.residual_predictor = nn.Conv2d(width, 12, 1)
        self.upsampler = nn.ConvTranspose2d(12, 3, 2, stride=2, groups=3)

        self.fullres_processor = nn.Sequential(OrderedDict([
            ("post_conv", nn.Conv2d(6, width, 3, padding=pad)),
            ("post_relu", nn.ReLU(inplace=True)),
            ("output", nn.Conv2d(width, 3, 1)),
        ]))

        # Load weights
        if pretrained:
            assert depth == 15, "pretrained bayer model has depth=15."
            assert width == 64, "pretrained bayer model has width=64."
            state_dict = th.load(_BAYER_WEIGHTS)
            print(self.load_state_dict(state_dict))

    def forward(self, mosaic):
        """Demosaicks a Bayer image.

        Args:
          mosaic (th.Tensor):  input Bayer mosaic

        Returns:
          th.Tensor: the demosaicked image
        """

        # 1/4 resolution features
        features = self.main_processor(mosaic)
        filters, masks = features[:, 0:self.width], features[:, self.width:2 * self.width]
        filtered = filters * masks
        residual = self.residual_predictor(filtered)

        # Match mosaic and residual
        upsampled = self.upsampler(residual)
        cropped = _crop_like(mosaic, upsampled)

        packed = th.cat([cropped, upsampled], 1)  # skip connection
        output = self.fullres_processor(packed)
        return output


def _crop_like(src, tgt):
    """Crop a source image to match the spatial dimensions of a target.

    Args:
        src (th.Tensor or np.ndarray): image to be cropped
        tgt (th.Tensor or np.ndarray): reference image
    """
    src_sz = np.array(src.shape)
    tgt_sz = np.array(tgt.shape)

    # Assumes the spatial dimensions are the last two
    crop = (src_sz[-2:] - tgt_sz[-2:])
    crop_t = crop[0] // 2
    crop_b = crop[0] - crop_t
    crop_l = crop[1] // 2
    crop_r = crop[1] - crop_l
    crop //= 2
    if (np.array([crop_t, crop_b, crop_r, crop_l]) > 0).any():
        return src[..., crop_t:src_sz[-2] - crop_b, crop_l:src_sz[-1] - crop_r]
    else:
        return src


if __name__ == '__main__':
    net = BayerDemosaick()
    inTensor = th.randn(1, 3, 128, 128)
    out = net.forward(inTensor)
    print(out.shape)

