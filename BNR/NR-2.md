# NR基础篇下——中值滤波、多级中值滤波、多级中值混合滤波、加权中值滤波、中值有理滤波

上一篇分享了一些均值滤波相关的算法，均值滤波作为一种线性滤波器，在滤除噪声的同时也会导致边缘模糊问题。而且均值滤波对高斯噪声的效果很好，但是对于椒盐噪声的效果就很一般。但是中值滤波作为一种顺序滤波器，对于椒盐噪声的效果很好，而且保边能力很强，所以这一篇主要讨论一下中值相关的算法。

## 中值滤波

### 算法原理

中值滤波很好理解，均值滤波就是在一个小窗口中求均值来取代当前像素值，而中值滤波就是通过求小窗口中的中位值来取代当前位置的方式来滤波。

![](images\medianFilters.png)

如图绿色窗口就是当前的滤波窗口，在一个3X3的邻域窗口中进行滤波。那么中值滤波做的就是：

1. 对这个邻域中的像素值进行排序：[45, 50, 52, 60, 75, 80, 90, 200, 255];
2. 从排序后的数据中找出中位值：75；
3. 用中位值取代当前位置的像素值，所以就可以得到右侧的滤波后的数据。

### 代码实现

```matlab
%% --------------------------------
%% author:wtzhu
%% email:wtzhu_13@163.com
%% date: 20210306
%% fuction: 中值滤波
%% --------------------------------
clear;
clc;
close all;
img = imread('./images/test_pattern_blurring_orig.tif');
[m, n] = size(img);
figure;subplot(221);imshow(img);title('original image');

%% 运算的时候需要对边缘进行扩展
% 需要特殊处理四周最外圈的行和列，本算法中将其向外扩展一圈，用最外圈的值填充
headRowMat = img(1,:);%取f的第1行
tailRowMat = img(m,:);%取f的第m行
% 行扩展后，列扩展时需要注意四个角需要单独扩展进去，不然就成了十字架形的
headColumnMat = [img(1,1), img(:,1)', img(m,1)];
tailColumnMat = [img(1,n), img(:,n)', img(m,n)];
expandImage = [headRowMat; img; tailRowMat];
expandImage = [headColumnMat; expandImage'; tailColumnMat];
expandImage = uint8(expandImage');
subplot(222);imshow(expandImage);title('expand image');

newImg = zeros(m, n);
for i =2: m+1
    for j =2: n+1
       imgRoi = [expandImage(i-1, j-1) expandImage(i-1, j) expandImage(i-1, j+1) ...
                 expandImage(i  , j-1) expandImage(i  , j) expandImage(i  , j+1) ...
                 expandImage(i+1, j-1) expandImage(i+1, j) expandImage(i+1, j+1)];
       orderedList = sort(imgRoi);
       sizeRoi = size(imgRoi);
       newImg(i-1, j-1) = orderedList((sizeRoi(2)+1)/2);
    end
end
newImg = uint8(newImg);
subplot(223);imshow(newImg);title('new image');
subplot(224);imshow(uint8(newImg-img));title('newImg-img');
```

![](images\res.png)

从滤波效果图中可以看出去噪能力还可以，百块中的噪点去除了很多，而且边缘信息保留得也很好。

## 多级中值滤波

### 算法原理

简单的中值滤波器滤波效果有限，于是就有人提出了将多个中值滤波进行多级级联实现更好的滤波效果。

![](images\MMF.png)

如图就是一种多级级联的方式，先在窗口中定义一个'+'和'X'形的窗口，然后分别求出这两个窗口的中位值，然后结合当前窗口的中心点就有3个候选值，再从这三个值中求出一个中位值作为滤波后的结果。

这种方式也可以直接应用到RAW图中做BNR，需要修改的就是窗口设置为5X5，然后在做滤波的时候需要区分G和RB通道，因为这个前面已经讲过，RAW图中的RGB分布是不均匀的，G占50%，R和B各占25%。

![](images\MMFForRaw.png)

左侧就是针对G通道的滤波器，右侧是R和B通道的滤波器，都是定义了一个'+'和'X'形的窗口，不同的只是取的点的位置不同。

### 代码实现

```matlab
%% --------------------------------
%% author:wtzhu
%% email:wtzhu_13@163.com
%% date: 20211023
%% fuction: multistage median filters
%% --------------------------------

close all;
clear all;
clc
img = imread('./images/lena.bmp');
I = double(img);
% I = double(imresize(img, [64, 64]));
figure();
imshow(uint8(I));
title('org file');

I_noise = I + 10 * randn(size(I));
figure();
imshow(uint8(I_noise));
title('noise file');
[m,n] = size(I_noise);

DenoisedImg = zeros(m,n);
PaddedImg = padarray(I,[1, 1],'symmetric','both');

tic
for i = 1: m
    for j = 1: n
        roi = PaddedImg(i:i+2, j:j+2);
        % first stage
        median_HV = median([roi(1,2), roi(2,1), roi(2,2), roi(2,3), roi(3,2)]);
        median_diag = median([roi(1,1), roi(1,3), roi(2,2), roi(3,1), roi(3,3)]);
        % second stage
        DenoisedImg(i, j) = median([median_HV, roi(2,2), median_diag]);
    end
end
figure();
imshow(uint8(DenoisedImg));
title('denoise file');
toc

b = medfilt2(I_noise,[3,3]);
figure();
imshow(uint8(b));
title('median filter of matlab denoise file');

```

## 多级中值混合滤波

### 算法原理

前面介绍过中值滤波和均值滤波各自有各自的优点和缺点，所以就可以考虑将两者结合起来，相互弥补实现更好的滤波效果，于是就有人提出了这种多级混合滤波的方式。

![](images\MMHF.png)

算法流程：

1. 求出竖直方向相邻三个点的均值和水平方向相邻三个点的均值，再结合当前点，用这三个点再求一个中位值；
2. 求出45°和135°方向上的均值，然后结合当前点求出一个中位值；
3. 两个中位值结合当前点组成新的数组，最后求一个中位值作为当前点的值完成滤波。

这样就巧妙的将均值滤波和中位值滤波结合了。然后如果应用在RAW图上，只需要对滤波器稍作改善即可。

![](images\MMHFForRaw.png)

### 代码实现

```matlab
%% --------------------------------
%% author:wtzhu
%% email:wtzhu_13@163.com
%% date: 20211023
%% fuction: multistage median hybird filters
%% --------------------------------

close all;
clear all;
clc
img = imread('./images/lena.bmp');
I = double(img);
figure();
imshow(uint8(I));
title('org file');

I_noise = I + 10 * randn(size(I));
figure();
imshow(uint8(I_noise));
title('noise file');
[m,n] = size(I_noise);

DenoisedImg = zeros(m,n);
PaddedImg = padarray(I,[1, 1],'symmetric','both');

tic
for i = 1: m
    for j = 1: n
        roi = PaddedImg(i:i+2, j:j+2);
        % first stage: average and median
        mean_V = mean(roi(:,2));
        mean_H = mean(roi(2,:));
        median_HV = median([mean_V, roi(2, 2)], mean_H);
        
        mean45 = mean([roi(1, 3), roi(2, 2), roi(3, 1)]);
        mean135 = mean([roi(1, 1), roi(2, 2), roi(3, 3)]);
        median_diag = median([mean45, roi(2, 2)], mean135);
        
        % second stage
        DenoisedImg(i, j) = median([median_HV, roi(2,2), median_diag]);
    end
end
figure();
imshow(uint8(DenoisedImg));
title('denoise file');
toc

b = medfilt2(I_noise,[3,3]);
figure();
imshow(uint8(b));
title('median filter of matlab denoise file');

```

## 多级中值有理混合滤波

### 算法原理

![](images\MRHF.png)

#### WMF加权中值滤波

![](images\WMF.png)

加权中值滤波也很好理解，和加权均值滤波差不多，就是在原始数据的基础上给每个点分别赋予一个权重，然后在加权后的数据中取出中位值作为滤波后的值。

#### 算法流程

1. 求出'+'形和'X'形的窗口的中位值；

2. 对'+'形窗口再利用CWMF求出一个值，CWMF是WMF的一种特殊情况，就是只对中心点进行加权；

3. 对以上求出的三个参数用一下公式计算出一个新的值作为滤波后的值
   $$
   y(m, n)=\phi 2(m, n)+\frac{\phi 1(m, n)-2 * \phi 2(m, n)+\phi 3(m, n)}{h+k(\phi 1(m, n)-\phi 3(m, n))}
   $$
   

一样的，稍作改动该算法就可以用于raw格式图像

![](images\MRHFForRaw.png)

### 代码实现

```matlab
%% --------------------------------
%% author:wtzhu
%% email:wtzhu_13@163.com
%% date: 20211023
%% fuction: median rational hybird file filter
%% references: MEDIAN-RATIONAL HYBRID FILTERS
%% --------------------------------

close all;
clear all;
clc
img = imread('./images/lena.bmp');
I = double(img);
figure();
imshow(uint8(I));
title('org file');

I_noise = I + 10 * randn(size(I));
figure();
imshow(uint8(I_noise));
title('noise file');
[m,n] = size(I_noise);

DenoisedImg = zeros(m,n);
PaddedImg = padarray(I,[1, 1],'symmetric','both');

h = 2;
k = 0.01;

tic
for i = 1: m
    for j = 1: n
        roi = PaddedImg(i:i+2, j:j+2);
        median_HV = median([roi(1,2), roi(2,1), roi(2,2), roi(2,3), roi(3,2)]);
        median_diag = median([roi(1,1), roi(1,3), roi(2,2), roi(3,1), roi(3,3)]);
        CWMF = median([roi(1,2), roi(2,1), roi(2,2)*3, roi(2,3), roi(3,2)]);
        
        DenoisedImg(i, j) = CWMF + (median_HV + median_diag - 2 * CWMF) / (h + k * (median_HV - median_diag));
    end
end
toc
figure();
imshow(uint8(DenoisedImg));
title('denoise file');
b = medfilt2(I_noise,[3,3]);
figure();
imshow(uint8(b));
title('median filter of matlab denoise file');
```

## 相关链接

- zhihu： [ISP图像处理 - 知乎 (zhihu.com)](https://www.zhihu.com/column/c_1389227246742335488)
- CSDN：[ISP图像处理_wtzhu_13的博客-CSDN博客](https://blog.csdn.net/wtzhu_13/category_11144092.html?spm=1001.2014.3001.5482)
- Bilibili：[食鱼者的个人空间_哔哩哔哩_Bilibili](https://space.bilibili.com/439454715/video)
- Gitee：[ISPAlgorithmStudy: ISP算法学习汇总，主要是论文总结 (gitee.com)](https://gitee.com/wtzhu13/ISPAlgorithmStudy)

