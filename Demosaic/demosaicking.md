# ISP——Demosaicking



## 前言

人眼之所以有能感受到自然界的颜色，是因为人眼的感光细胞中有三种锥体细胞对红绿蓝三种颜色敏感，所以我们就可以通过RGB三种颜色来表示一个颜色空间，通过这个颜色空间中的点就能表示自然界中所有的颜色。那么数码相机只要能类似人一样获取自然界中的这三个分量，那么就能复现人眼看到的颜色。相机系统用的感光器件只是一个光电转换器件，所以感光器件只对亮度分量敏感，无法感知颜色，所以需要通过滤光片将光线分解成RGB三个分量然后再用感光期间去接受。那么最直接的方式就是用三个滤光片分别过滤出RGB三个通道的分量，然后用三个感光器件去分别接受三个通道的强度，然后再将这三个通道的值叠加到一起就能复现出正常的颜色。这种涉及称为3CCD，这种方式大概可以用如下简图表示。但是这种方式工艺复杂且成本较高，所以到目前位置在消费领域基本没有这种操作。

![](E:\Fred\ISP\ISPAlgorithmStudy\Demosaic\images\3CCD.png)

由于其缺陷，所以柯达公司的科学家Bryce Bayer（1929-2012）发明了一个突破性的解决方案。这个方案不需要使用昂贵的光学棱镜，也不需要使用3个CCD阵列，只需要在一个CCD阵列上制造三种不同的滤光膜，构成一个滤光膜阵列（Color Filter Array，CFA），就形成一个廉价而高效的解决方案。这种方式就是在感光器件上面通过交替的滤光透镜过滤出三中颜色分量形成如图的RGB三色交替的图像。后期再通过一定的算法通过周边的颜色恢复出确实的颜色，最终形成RGB的颜色，这种后期的处理方式就是本文讨论的重点，一般称作去马赛克算法（demosaicking）。

![](E:\Fred\ISP\ISPAlgorithmStudy\Demosaic\images\CMOSStructure.png)

![](E:\Fred\ISP\ISPAlgorithmStudy\BNR\images\CFA.png)

## 算法解释

### 简单的线性插值

![](E:\Fred\ISP\ISPAlgorithmStudy\Demosaic\images\linearInterpolation.png)

如图是Bayer格式的raw图，RGB三种颜色交替覆盖，且绿色分量是RB分量的两倍。由于这种特殊的分布方式，所以可以通过最贱的线性插值的方式通过附近的已知的颜色插值出同一通道缺失的分量。例如途中G13点为绿色，缺失了R和B，但是G13左右的R是已知的，那么就可以通过左右红色分量插值出该点缺失的红色，同理可以通过上下的蓝色分量插值出该点缺失的蓝色分量。对于R14缺失的G和B，但是周围相邻的有4个G是已知的，就可以通过这四个点插值出该点缺失的G，同理可以通过周围四个B插值出该点的B。具体的代码实现：

```matlab
%% --------------------------------
%% author:wtzhu
%% date: 20210705
%% fuction: main file of Demosaic. The simple linear interpolation.
%% note: add RGGB format only, other formats will be added later
%% --------------------------------
clc;clear;close all;

%% ------------Raw Format----------------
filePath = 'images/kodim19_8bits_RGGB.raw';
bayerFormat = 'RGGB';
width = 512;
height= 768;
bits = 8;
%% --------------------------------------
bayerData = readRaw(filePath, bits, width, height);
figure();
imshow(bayerData);
title('raw image');

%% expand image inorder to make it easy to calculate edge pixels
bayerPadding = zeros(height + 2,width+2);
bayerPadding(2:height+1,2:width+1) = uint32(bayerData);
bayerPadding(1,:) = bayerPadding(3,:);
bayerPadding(height+2,:) = bayerPadding(height,:);
bayerPadding(:,1) = bayerPadding(:,3);
bayerPadding(:,width+2) = bayerPadding(:,width);

%% main code of imterpolation
imDst = zeros(height+2, width+2, 3);
for ver = 2:height + 1
    for hor = 2:width + 1
        switch bayerFormat
            case 'RGGB'
                % G B -> R
                if(0 == mod(ver, 2) && 0 == mod(hor, 2))
                    imDst(ver, hor, 1) = bayerPadding(ver, hor);
                    % G -> R
                    imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                         bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                    % B -> R
                    imDst(ver, hor, 3) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                         bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                % G R -> B
                elseif (1 == mod(ver, 2) && 1 == mod(hor, 2))    
                    imDst(ver, hor, 3) = bayerPadding(ver, hor);
                    % G -> B
                    imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                         bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                    % R -> B
                    imDst(ver, hor, 1) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                         bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                elseif(0 == mod(ver, 2) && 1 == mod(hor, 2))
                    imDst(ver, hor, 2) = bayerPadding(ver, hor);
                    % R -> Gr
                    imDst(ver, hor, 1) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                    % B -> Gr
                    imDst(ver, hor, 3) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                elseif(1 == mod(ver, 2) && 0 == mod(hor, 2))
                    imDst(ver, hor, 2) = bayerPadding(ver, hor);
                    % B -> Gb
                    imDst(ver, hor, 3) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                    % R -> Gb
                    imDst(ver, hor, 1) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                end
            case 'GRBG'
                continue;
            case 'GBGR'
                continue;
            case 'BGGR'
                continue;
        end
    end
end
imDst = uint8(imDst(2:height+1,2:width+1,:));
figure,imshow(imDst);title('demosaic image');

orgImage = imread('images/kodim19.png');
figure, imshow(orgImage);title('org image');
```

<img src="E:\Fred\ISP\ISPAlgorithmStudy\Demosaic\images\kodim19.png" style="zoom: 80%;" /><img src="E:\Fred\ISP\ISPAlgorithmStudy\Demosaic\images\linear.png" alt="linear" style="zoom: 80%;" />

左侧是实验原图，右侧是通过上述的简单的线性插值出来的效果，从图中可以看出简单的线性插值出来得到效果一般。存在画面整体清晰度变差，高频存在伪彩，边缘又伪像。

### 色差法和色比法

色比法和色差法其实是基于两个假设实现插值的。其中色比法假设再一个邻域范围内不同颜色通道的值的比值是固定的，简单来说就说相邻像素的R/G的值和B/G的值是一样的，那么设计算法时就可以利用这一点。一般情况下都会先插值出G的缺失值，然后通过与G的比值恒定插值出其他的缺失值。如上展示的RAW图，可以通过G9，G13， G15，G19做简单的线性插值恢复G14，然后通过R14/G14 = R13/G13的假设恢复出R13。同理可以恢复出其他缺失的颜色。

色差法和色比法类似，色差发假设在一个邻域内不同通道的颜色插值时恒定的。只是将色比法的比值转换为差值即可。

### 基于方向加权的方法

由于上述简单的插值算法存在诸多缺陷，其主要原因就是没有针对边缘做处理。所以更好的算法就对边缘做了识别，针对边缘做特殊的处理，然后同时利用色差或色比的方法融合到一起得到更好的效果，这一块儿算法较多，博文讲起来比较费劲，我已经整理了视频，可以直接通过文末链接去[B站观看视频]([ISP_DEMOSAICKING_2_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1VS4y1m7qH?spm_id_from=333.999.0.0))讲解。

<img src="E:\Fred\ISP\ISPAlgorithmStudy\Demosaic\images\kodim19.png" style="zoom:80%;" /><img src="E:\Fred\ISP\ISPAlgorithmStudy\Demosaic\images\WD.png" alt="WD" style="zoom:80%;" />

上图左边时原图，右侧是通过方向加权后的结果，从效果看，已经比简单的线性插值的效果好了不止一点点，但是在高频上依旧会有些伪彩，这一块儿可以通过参数的优化进一步弱化。

### 基于学习的方法

通过机器学习或者深度学习的方法来处理ISP的流程也是一个新的探索，所以在这个环节也引进了相关的算法，这里我简单介绍一种，具体详细介绍可以去[B站观看详细视频讲解]([DEMOSAICKING_3_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1v54y1f7eZ?spm_id_from=333.999.0.0))。

![](E:\Fred\ISP\ISPAlgorithmStudy\Demosaic\images\DDJD.png)

这个方法的作者通过如图的网络进行进行去马赛克和去噪融合的算法，这种融合处理的方式在之前的BNR章节也做了相关的说明，不在赘述，这里只讨论模型的去马赛克算法。

```python
DJDDNetwork(
  (down_sample): Conv2d(3, 4, kernel_size=(2, 2), stride=(2, 2))
  (main_layers): Sequential(
    (Conv_1): Conv2d(4, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_1): ReLU(inplace=True)
    (Conv_2): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_2): ReLU(inplace=True)
    (Conv_3): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_3): ReLU(inplace=True)
    (Conv_4): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_4): ReLU(inplace=True)
    (Conv_5): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_5): ReLU(inplace=True)
    (Conv_6): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_6): ReLU(inplace=True)
    (Conv_7): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_7): ReLU(inplace=True)
    (Conv_8): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_8): ReLU(inplace=True)
    (Conv_9): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_9): ReLU(inplace=True)
    (Conv_10): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_10): ReLU(inplace=True)
    (Conv_11): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_11): ReLU(inplace=True)
    (Conv_12): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_12): ReLU(inplace=True)
    (Conv_13): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_13): ReLU(inplace=True)
    (Conv_14): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_14): ReLU(inplace=True)
    (Conv_15): Conv2d(64, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (ReLU_15): ReLU(inplace=True)
  )
  (residual): Conv2d(64, 12, kernel_size=(1, 1), stride=(1, 1))
  (up_sample): ConvTranspose2d(12, 3, kernel_size=(2, 2), stride=(2, 2))
  (final_process): Sequential(
    (0): Conv2d(6, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (1): ReLU(inplace=True)
    (2): Conv2d(64, 3, kernel_size=(1, 1), stride=(1, 1))
  )
)
```

这里需要提一点的就是，该算法默认的raw输入为3通道，这个图可以通过一通道的raw生成，就是只保留该点原本的颜色值，其他两个通道为0即可。大体模型就是输入的RAW先通过降采样生成4通道的长宽均缩小一半的数据，这里降采样有两种方式，一种是直接将图像拆分为R，B，Gr，和Gb四个通道，然后再进网络，另一种方式就是如图代码中的方式，通过一个2X2，步长为2的卷积核进行一个卷积运算输出一个4通道。在经过降采样后再经过14次3X3的卷积并用ReLu作为激活函数，同时整个过程维持64通道。然后在15层通过3X3卷积输出一个12通道的数据，紧接着通过一个上采样卷积生成一个3通道的数据，然后将这个3通道的数据和原始的raw数据做一个叠加生成一个6通道的数据，紧接着再经过一个3X3卷积生成64通道数据，最后再通过一个3X3的卷积生成最终的图像。基于这个模型通过大量的数据来学习最终生成一个效果OK的模型。由于手头算力有限，所以我这边训练的模型效果一般，但是作者通过230万张图片经过2-3周的训练，可以得到一个很OK的模型。关于这个模型在我的仓库中提供了pytorch和paddle两个版本，有兴趣或者有算力的朋友可以将其优化一下，关于这种方式的算法建议观看[B站视频讲解](https://www.bilibili.com/video/BV1v54y1f7eZ?spm_id_from=333.999.0.0)。

## 相关链接

- zhihu： [ISP图像处理 - 知乎 (zhihu.com)](https://www.zhihu.com/column/c_1389227246742335488)
- CSDN：[ISP图像处理_wtzhu_13的博客-CSDN博客](https://blog.csdn.net/wtzhu_13/category_11144092.html?spm=1001.2014.3001.5482)
- Bilibili：[食鱼者的个人空间_哔哩哔哩_Bilibili](https://space.bilibili.com/439454715/video)
- Gitee：[ISPAlgorithmStudy: ISP算法学习汇总，主要是论文总结 (gitee.com)](https://gitee.com/wtzhu13/ISPAlgorithmStudy)