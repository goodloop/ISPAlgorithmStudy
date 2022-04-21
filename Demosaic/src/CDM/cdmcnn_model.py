# MIT License
#
# Pytorch implementation of: 
#    COLOR IMAGE DEMOSAICKING VIA DEEP RESIDUAL LEARNING
#    2017 IEEE International Conference on Multimedia and Expo (ICME)
# 
# Copyright (c) 2019 adapted by Gabriele Facciolo

import torch
import torch.nn as nn


class CONV_BN_RELU(nn.Module):
    '''
    PyTorch Module grouping together a 2D CONV, BatchNorm and ReLU layers.
    This will simplify the definition of the DnCNN network.
    By default (skipBN=False, convHasBias=False) 
    '''

    def __init__(self, in_channels=128, out_channels=128, kernel_size=7, 
                 stride=1, padding=3, skipBN=False, convHasBias=False):
        '''
        Constructor
        Args:
            - in_channels: number of input channels from precedding layer
            - out_channels: number of output channels
            - kernel_size: size of conv. kernel
            - stride: stride of convolutions
            - padding: number of zero padding
            - skipBN: skip the BN step (default=False)
            - convHasBias: define conv with bias (default=False)
        Return: initialized module
        '''
        super(__class__, self).__init__()

        self.layers = []

        self.conv = nn.Conv2d(in_channels, out_channels, kernel_size, 
                              stride=stride, padding=padding, bias=convHasBias)

        self.layers.append(self.conv)
        
        if not skipBN:
            self.bn   = nn.BatchNorm2d(out_channels)
            self.layers.append(self.bn)

        self.relu = nn.ReLU(inplace=True)
        self.layers.append(self.relu)
        

        self.convbnrelu = nn.Sequential(*self.layers)
        
    def forward(self, x):
        '''
        Applies the layer forward to input x
        '''
        #out = self.conv(x)
        #out = self.bn(out)
        #out = self.relu(out)
        #return(out)

        return self.convbnrelu(x)

    
    
class DnCNN(nn.Module):
    '''
    PyTorch module for the DnCNN network.
    '''

    def __init__(self, in_channels=1, out_channels=1, num_layers=17, 
                 features=64, kernel_size=3, residual=True):
        '''
        Constructor for a DnCNN network.
        Args:
            - in_channels: input image channels (default 1)
            - out_channels: output image channels (default 1)
            - num_layers: number of layers (default 17)
            - num_features: number of hidden features (default 64)
            - kernel_size: size of conv. kernel (default 3)
            - residual: use residual learning (default True)
        Return: network with randomly initialized weights
        '''
        super(__class__, self).__init__()
        
        self.residual = residual
        
        # a list for the layers
        self.layers = []  
        
        # first layer 
        self.layers.append(CONV_BN_RELU(in_channels=in_channels,
                                        out_channels=features,
                                        kernel_size=kernel_size,
                                        stride=1, padding=kernel_size//2,
                                        convHasBias=True,
                                        skipBN=True))
        # intermediate layers
        for _ in range(num_layers-2):
            self.layers.append(CONV_BN_RELU(in_channels=features,
                                            out_channels=features,
                                            kernel_size=kernel_size,
                                            stride=1, padding=kernel_size//2,
                                            convHasBias=False,
                                            skipBN=False))
        # last layer 
        self.layers.append(nn.Conv2d(in_channels=features,
                                     out_channels=out_channels,
                                     kernel_size=kernel_size,
                                     stride=1, padding=kernel_size//2))
        # chain the layers
        self.dncnn = nn.Sequential(*self.layers)

        
    def forward(self, x):
        ''' Forward operation of the network on input x.'''
        out = self.dncnn(x)
        
        if self.residual: # residual learning
            out = x + out 
        
        return(out)

    
    
class CDMCNN(nn.Module):
    '''
    PyTorch module for the DnCNN network.
    '''

    def __init__(self,  features=64, kernel_size=3):
        '''
        Constructor for a DnCNN network.
        Args:
            - num_features: number of hidden features (default 64)
            - kernel_size: size of conv. kernel (default 3)
        Return: network with randomly initialized weights
        '''
        super(__class__, self).__init__()
        
        
        self.step1 = DnCNN(in_channels=3, out_channels=3, num_layers=5, 
                 features=64, kernel_size=3, residual=True)
        
        self.step2 = DnCNN(in_channels=3, out_channels=3, num_layers=6, 
                 features=64, kernel_size=3, residual=True)
    

        

    def forward(self, x):
        ''' Forward operation of the network on input x.'''

        # REORDER RB,G
        x = torch.index_select(x, 1, torch.tensor([0,2,1])) 

        outG1 = self.step1(x)
        out   = self.step2(outG1)

        # ORDER RB,G   to   RGB
        out   = torch.index_select(out,   1, torch.tensor([0,2,1])) 
        outG1 = torch.index_select(outG1, 1, torch.tensor([0,2,1])) 

        return(out, outG1)





def CDMCNN_pretrained(savefile=None, verbose=False):
    '''
    Loads the pretrained weights of DnCNN for grayscale images from 
    https://github.com/csrjtan/CDM-CNN/raw/master/src/model_10.mat
    Args:
        - savefile: is the .pt file to save the model weights 
        - verbose : verbose output
    Returns:
        - CDMCNN() model     
    '''
    
    import torch
    import os
    import urllib.request
    import numpy as np
    import hdf5storage

    here = os.path.dirname(__file__)

    ### caching system
    cached_model_fname = here+'/cached_CDM-CNN_model_10.pt'
    try: 
        os.stat(cached_model_fname)
        if torch.cuda.is_available():
            loadmap = {'cuda:0': 'gpu'}
        else:
            loadmap = {'cuda:0': 'cpu'}
        m = torch.load(cached_model_fname, map_location=loadmap)
        print('downloading pretrained model - using cached model: %s'%cached_model_fname)
        return m
    except OSError:
        pass

    
    ### download the pretained weights
    mat_model_URL = 'https://github.com/csrjtan/CDM-CNN/raw/4c91fc1c3bb82490b3e5371a515807774f7e0da1/src/model_10.mat'
    mat_model_fname = 'CDM-CNN_model_10.mat'
    try:
        os.stat(here+'/'+mat_model_fname)
    except OSError:
        print('downloading pretrained model')
        urllib.request.urlretrieve(mat_model_URL, here+'/'+mat_model_fname)

    # read the matlab file
    mat = hdf5storage.loadmat(here+'/'+mat_model_fname)

    # load all weights from the matlab file 
    mcn_weights={}
    for l in mat['net']['params'][0][0][0]: 
        mcn_weights[l[0][0]] = l[1]
    # transpose from matconvnet to pytorch conv order
    TRANSPOSE_PATTERN = [3, 2, 0, 1]


    ### create the model and load all the weights
    m = CDMCNN()

    dtype = torch.FloatTensor

    ################# FIRST PART
    layers = m.step1.layers

    # conv 
    for i in range(1,5): 
        lab = 'layer1%df'%i
        w = mcn_weights[lab]
        if verbose:
            print(lab, w.shape)
            print(layers[i-1].conv.weight.shape)
        layers[i-1].conv.weight = torch.nn.Parameter( dtype( np.reshape(w.transpose(TRANSPOSE_PATTERN) , layers[i-1].conv.weight.shape) ) )

        if i==1:
            lab = 'layer1%db'%i
            w = mcn_weights[lab]
            if verbose:
                print(lab, w.shape)
                print (layers[i-1].conv.bias.shape)

            layers[i-1].conv.bias = torch.nn.Parameter( dtype(w.squeeze()) )

        else:
            # BN filter and bias 
            labw = 'layer1{}b1'.format(i)
            labb = 'layer1{}b2'.format(i)
            labmoments = 'layer1{}b3'.format(i) # moments
            w = mcn_weights[labw]
            b = mcn_weights[labb]
            moments = mcn_weights[labmoments]
            if verbose:
                print(labw, w.shape)
                print(labb, b.shape)
                print(layers[i-1].bn.bias.shape)

            eps = layers[i-1].bn.eps = 1e-5; # hardcoded
            layers[i-1].bn.weight = torch.nn.Parameter( dtype(w) )     
            layers[i-1].bn.bias   = torch.nn.Parameter( dtype(b) )
            layers[i-1].bn.running_mean = dtype(moments[:,0])
            # PyTorch stores running variances, rather than running 
            # standard deviations (as done by matconvnet)
            layers[i-1].bn.running_var  = dtype((moments[:,1] ** 2) - eps)


    # re-assemble the last layer
    i=5

    labwRB = 'layer1{}fRB'.format(i)
    labbRB = 'layer1{}bRB'.format(i)
    labwG  = 'layer1{}fG'.format(i)
    labbG  = 'layer1{}bG'.format(i)

    if verbose:
        for x in [labwG, labbG, labwRB, labbRB]:
            print (x, mcn_weights[x].shape)

    # ORDER RB,G
    b = np.array([mcn_weights[labbRB][0][0], mcn_weights[labbRB][1][0], mcn_weights[labbG][0][0]])
    w = np.zeros( (3, 3, 64, 3))
    w[:,:,:,0] = mcn_weights[labwRB][:,:,:,0]
    w[:,:,:,1] = mcn_weights[labwRB][:,:,:,1]
    w[:,:,:,2] = mcn_weights[labwG]
    layers[i-1].bias   = torch.nn.Parameter( dtype( b.squeeze() ) )
    layers[i-1].weight = torch.nn.Parameter( dtype( np.reshape(w.transpose(TRANSPOSE_PATTERN) , layers[i-1].weight.shape) ) ) 


    ################# SECOND PART

    layers = m.step2.layers

    # conv 
    for i in range(1,6): 
        lab = 'layer2%df'%i
        w = mcn_weights[lab]
        if verbose:
            print(lab, w.shape)
            print (layers[i-1].conv.weight.shape)

        layers[i-1].conv.weight = torch.nn.Parameter( dtype( np.reshape(w.transpose(TRANSPOSE_PATTERN) , layers[i-1].conv.weight.shape) ) )

        if i==1:
            lab = 'layer2%db'%i
            w = mcn_weights[lab]
            if verbose:
                print(lab, w.shape)
                print (layers[i-1].conv.bias.shape)

            layers[i-1].conv.bias = torch.nn.Parameter( dtype(w.squeeze()) )

        else:
            # BN filter and bias 
            labw = 'layer2{}b1'.format(i)        # weight
            labb = 'layer2{}b2'.format(i)        # bias
            labmoments = 'layer2{}b3'.format(i)  # moments
            w = mcn_weights[labw]
            b = mcn_weights[labb]
            moments = mcn_weights[labmoments]
            if verbose:
                print(labw, w.shape)
                print(labb, b.shape)
                print(layers[i-1].bn.bias.shape)

            eps = layers[i-1].bn.eps = 1e-5; # 
            layers[i-1].bn.weight = torch.nn.Parameter( dtype(w) )     
            layers[i-1].bn.bias   = torch.nn.Parameter( dtype(b) )
            layers[i-1].bn.running_mean = dtype(moments[:,0])
            layers[i-1].bn.running_var  = dtype((moments[:,1] ** 2) - eps)


    # re-assemble the last layer
    i=5

    labwRB = 'layer2{}fRB'.format(i)
    labbRB = 'layer2{}bRB'.format(i)
    labwG  = 'layer2{}fG'.format(i)
    labbG  = 'layer2{}bG'.format(i)

    if verbose:
        for x in [labwG, labbG, labwRB, labbRB]:
            print (x, mcn_weights[x].shape)

    # ORDER RB,G
    b = np.array([mcn_weights[labbRB][0][0], mcn_weights[labbRB][1][0], mcn_weights[labbG][0][0]])
    w = np.zeros( (3, 3, 64, 3))
    w[:,:,:,0] = mcn_weights[labwRB][:,:,:,0]
    w[:,:,:,1] = mcn_weights[labwRB][:,:,:,1]
    w[:,:,:,2] = mcn_weights[labwG]
    layers[i].bias   = torch.nn.Parameter( dtype( b.squeeze() ) )
    layers[i].weight = torch.nn.Parameter( dtype( np.reshape(w.transpose(TRANSPOSE_PATTERN) , layers[i].weight.shape) ) ) 



    ### fill cache 
    try: 
        os.stat(cached_model_fname)
    except OSError:
        torch.save(m, cached_model_fname)


    if savefile:
        torch.save(m, savefile)

    return m







