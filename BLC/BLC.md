# ISP——BLC(Black Level Correction)

## BL产生的原因

### 暗电流

暗电流（dark current），也称无照电流，指在没有光照射的状态下,在太阳电池、光敏二极管、光导电元件、光电管等的受光元件中流动的电流，一般由于载流子的扩散或者器件内部缺陷造成。目前常用的CMOS就是光电器件，所以也会有暗电流，导致光照为0的时候也有电压输出。

![](images\反向漏电流.jpg)

如图是二极管的伏安特性曲线，从图中可以看出在反向截止区域电流并不是完全为0，而我们的COMS内部其实也是PN结构成的，所以符合该特性，并且光电二极管是工作在反向电压下，所以无光照是的这个微小电流就是暗电流。

### AD前添加一个固定值

1. sensor到ISP会有一个AD转换的过程，而AD芯片都会有一个灵敏度，当电压低于这个阈值的时候无法进行AD转换，所以就人为添加一个常量使得原本低于阈值的这部分值也能被AD转换；

2. 因为人眼对暗部细节更加敏感，而对高亮区没那么敏感，所以就增加一个常量牺牲人眼不敏感的亮区来保留更大暗区细节。

   ![](images\1.png)

以上两点的意思就是将AB提升到A'B',使得这个区间的值都能完成AD转换，而且这段区域能更好的保留暗区，也就是人眼敏感的部分，牺牲BC部分，因为这部分信息是人眼不敏感的，这样就更符合人眼的需求。

## BL校正

BL的校正现在一般会分为sensor端和ISP端两部分，但是我们专栏重点讨论ISP PIPELINE里的算法，所以sensor中的算法不重点讨论。

### SENSOR端

![](images\sensorPixelBlock.png)

如图这个是某一sensor像素阵列的分布，这个sensor最大出图分辨率为3280*2464，也就有效像素区。然后下面灰色部分还有个有效OPB区，这个区域就是sensor就行OB区域。这两个部分最大的区别在于，有效像素区是可以正常曝光的，而OB区在工艺上让它不能接受光子，最简单的想法就是在感光表明涂一层黑色的不感光物质，这样就能通过OB区无光照是的值来校正有效像素去的值。最简单的操作就是对OB去的像素值去平均，然后每个像素值减去这个值完成校正。当然现在sensor也会有些些高端的校正算法。

![](images\比亚迪.png)

![斯特维](images\斯特维.png)

如图中思特威和比亚迪就提出了两种更加高级的算法，正如刚才所说，sensor端的处理不是本专栏的重点，所以不进行重点说明，有兴趣的可以自行研究，需要资料的可以留言。

### ISP端

ISP端的算法都是通过一副黑帧RAW图，然后对RAW图进行操作。下面都是以8位的进行说明。

#### 扣除固定值法

![](images\1.png)

扣除固定值法就是每个通道扣除一个固定值，就如上图，将A'b'平移到AB就行。

具体的做法如下：

![](images\bayer.png)

1. 采集黑帧RAW图，将其分为Gr,Gb,R,B四个通道；

2. 对四个通道求平均值（有的算法也用中位值或者别的方式）；

3. 后续图像每个通道都减去2中计算出的各个通道的校正值；

4. 对Gr和Gb通道进行归一化，就是A'b'平移到AB后最大值就是B点的纵坐标，但是我们需要把这个值恢复到255使得恢复后的像素值范围依旧是0-255；
   $$
   \operatorname{Gin} \times \frac{255}{255-B L}
   $$
   通过上述公式就可以完成校正。然后需要注意的是RB通道不用归一化到0-255区间，因为后续的AWB中会通过gain将其范围提升到0-255，这个后续再AWB算法中再讨论。

目前这种方式用的比较多，比如我接触的海思和Sonix都是用这种简单粗暴的方法，因为上面也说过Sensor端自己会有一个BL处理，所以后端通过这种简单的方式也能完成校正。

#### ISO联动法

因为暗电流这些会和gain值还有温度等相关，所以通过联动的方式确定每个条件下的校正值。然后后面先通过参数查得相应的校正值进行校正。

具体做法如下：

1. 初始化一个ISO值（其实就是AG和DG的组合），然后重复固定值中的做法，采集黑帧，标定出各个通道的校正值；
2. 在初始化ISO的基础通过等差或者等比数列的方式增长ISO，然后重复1步骤求取各个通道的校正值；
3. 将这个二维数据做成一个LUT，后续图像通过ISO值查找相应的校正值进行校正。不在LUT中的ISO值的参数可以通过插值的方式求得。

#### 曲线拟合法

上面两个方法校正出来的每个通道的校正值是个固定值，但是我们知道，实际在像素不同位置黑帧的数据是不一样的，所以更准确的方式就是每个点都求出一个校正值对该点进行校正。但是现在一般像素值都很高，不可能把每个点的值都存下来，这样内存需求太大，所以就同过采样的方式。就是在黑帧中选择一些像素点求出该点的校正值，然后把坐标和校正值存在一个LUT中，后续其他的像素点的校正值就可一个通过坐标和这个LUT进性插值求得校正值，从而实现每个点的精准校正。

![](images\多方法融合.png)

如图这篇专利中就是建立了AG的LUT，曝光时间的LUT，然后坐标的LUT，相当于在ISO联动方式的基础加上了坐标位置信息，实现了每个点的精准校正。

### 校正总结

![](\images\block diagram.png)

如图是数据流程图，可以看出sensor端可以进行模拟处理和数字处理，而ISP端智能进行数字处理，因为ISP接受的信号是经过AD转换后的数字信号，所以在sensor端处理就可以有更加精细，如上面比亚迪的专利中提到的，sensor端粗条可以通过模拟信号来处理，然后细调再通过数字处理的方式来处理。所以综上分析一般ISP端可以通过比较简单的校正来完成，这样可以节省硬件资源。这也就是大多是ISP芯片用的处理方式都很简单的原因。

## 具体实现

```matlab
%% --------------------------------
%% author:wtzhu
%% date: 20210629
%% fuction: main file of BLC
%% --------------------------------
clc;clear;close all;

% ------------Raw Format----------------
filePath = 'images/HisiRAW_4208x3120_8bits_RGGB.raw';
bayerFormat = 'RGGB';
row = 4208;
col = 3120;
bits = 8;
% --------------------------------------

%  I(1:2:end, 1:2:end) = R(1:1:end, 1:1:end);

data = readRaw(filePath, bits, row, col);
% get the four channels by bayerFormat
switch bayerFormat
    case 'RGGB'
        disp('bayerFormat: RGGB');
        R = data(1:2:end, 1:2:end);
        Gr = data(1:2:end, 2:2:end);
        Gb = data(2:2:end, 1:2:end);
        B = data(2:2:end, 2:2:end);
    case 'GRBG'
        disp('bayerFormat: GRBG');
        Gr = data(1:2:end, 1:2:end);
        R = data(1:2:end, 2:2:end);
        B = data(2:2:end, 1:2:end);
        Gb = data(2:2:end, 2:2:end);
    case 'GBRG'
        disp('bayerFormat: GBRG');
        Gb = data(1:2:end, 1:2:end);
        B = data(1:2:end, 2:2:end);
        R = data(2:2:end, 1:2:end);
        Gr = data(2:2:end, 2:2:end);
    case 'BGGR'
        disp('bayerFormat: BGGR');
        B = data(1:2:end, 1:2:end);
        Gb = data(1:2:end, 2:2:end);
        Gr = data(2:2:end, 1:2:end);
        R = data(2:2:end, 2:2:end);
end
% calculate the Correction coefficient of every channel
R_mean = round(mean(mean(R)));
Gr_mean = round(mean(mean(Gr)));
Gb_mean = round(mean(mean(Gb)));
B_mean = round(mean(mean(B)));

% Correct each channel separately
cR = R-R_mean;
cGr = Gr-Gr_mean;
cGb = Gb-Gb_mean;
cB = B-B_mean;
fprintf('R:%d Gr:%d Gb:%d B:%d\n', R_mean, Gr_mean, Gb_mean, B_mean);

cData = zeros(size(data));
% Restore the image with four channels
switch bayerFormat
    case 'RGGB'
        disp('bayerFormat: RGGB');
        cData(1:2:end, 1:2:end) = cR(1:1:end, 1:1:end);
        cData(1:2:end, 2:2:end) = cGr(1:1:end, 1:1:end);
        cData(2:2:end, 1:2:end) = cGb(1:1:end, 1:1:end);
        cData(2:2:end, 2:2:end) = cB(1:1:end, 1:1:end);
    case 'GRBG'
        disp('bayerFormat: GRBG');
        cData(1:2:end, 1:2:end) = cGr(1:1:end, 1:1:end);
        datacData(1:2:end, 2:2:end) = cR(1:1:end, 1:1:end);
        cData(2:2:end, 1:2:end) = cB(1:1:end, 1:1:end);
        data(2:2:end, 2:2:end) = cGb(1:1:end, 1:1:end);
    case 'GBRG'
        disp('bayerFormat: GBRG');
        cData(1:2:end, 1:2:end) = cGb(1:1:end, 1:1:end);
        cData(1:2:end, 2:2:end) = cB(1:1:end, 1:1:end);
        cData(2:2:end, 1:2:end) = cR(1:1:end, 1:1:end);
        cData(2:2:end, 2:2:end) = cGr(1:1:end, 1:1:end);
    case 'BGGR'
        disp('bayerFormat: BGGR');
        cData(1:2:end, 1:2:end) = cB(1:1:end, 1:1:end);
        cData(1:2:end, 2:2:end) = cGb(1:1:end, 1:1:end);
        cData(2:2:end, 1:2:end) = cGr(1:1:end, 1:1:end);
        cData(2:2:end, 2:2:end) = cR(1:1:end, 1:1:end);
end
show(data, cData, bits, Gr_mean);
```

readRaw.m:

```matlab
function rawData = readRaw(fileName, bitsNum, row, col)
% readRaw.m    get rawData from HiRawImage
%   Input:
%       fileName    the path of HiRawImage 
%       bitsNum      the number of bits of raw image
%       row         the row of the raw image
%       col         the column of the raw image
%   Output:
%       rawData     the matrix of raw image data
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-06-29
% Note: 

% get fileID
fin = fopen(fileName, 'r');
% format precision
switch bitsNum
    case 8
        disp('bits: 8');
        format = sprintf('uint8=>uint8');
    case 10
        disp('bits: 10');
        format = sprintf('uint16=>uint16');
    case 12
        disp('bits: 12');
        format = sprintf('uint16=>uint16');
    case 16
        disp('bits: 16');
        format = sprintf('uint16=>uint16');
end
I = fread(fin, row*col, format);
% plot(I, '.');
z = reshape(I, row, col);
z = z';
rawData = z;
% imshow(z);
end
```

校正效果

![](\images\BLC.jpg)

## 提示：

1. 为了方便下载，本项目没有更新到github，用的gitee，可以在[ISPAlgorithmStudy: ISP算法学习汇总，主要是论文总结 (gitee.com)](https://gitee.com/wtzhu13/ISPAlgorithmStudy)仓库中获取相关的资料代码等。
2. 本期B站有视频同步讲解，[ISP算法精讲——BLC_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1AL411W7kT)，可以关注B站，后续会有更多算法的视频讲解同步；
3. 知乎专栏[ISP图像处理 - 知乎 (zhihu.com)](https://www.zhihu.com/column/c_1389227246742335488)也会有算法简介同步；
4. CSDN专栏[ISP图像处理_wtzhu_13的博客-CSDN博客](https://blog.csdn.net/wtzhu_13/category_11144092.html?spm=1001.2014.3001.5482)