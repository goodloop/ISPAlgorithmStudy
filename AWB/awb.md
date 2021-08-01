

# ISP——AWB(Auto White Balance)

## 现象

![](images\compare.png)

## 几个概念

人眼具有颜色恒常性，可以避免光源变化带来的颜色变化，但是图像传感器不具备这种特性，从而造成色偏，白平衡就是需要校正这个颜色的偏差；

- 颜色恒常性：颜色恒常是指在照度发生变化的条件下人们对物体表面颜色的知觉趋于稳定的心理倾向；
- 色温的定义：色温描述的是具有一定表面温度的“黑体”(blackbody)的辐射光的光谱特性。简单的理解就是颜色随温度的变化规律，比如生铁就是黑色，加热会变成橘红色，继续加热到液态会呈现偏白的颜色，这种随温度而产生的颜色变化就光谱特性。

## 白平衡校正

- 手动白平衡：在拍照前通过拍摄一个18度灰的卡片，然后计算出当时环境的白平衡的gain值对后面的图片进行校正；

## 矫正方法

- 静态矫正：通常由sensor厂商在生产后进行标定，把所有坏点的坐标位置记录下来，然后矫正的时候直接通过查表得方式找到坏点进行矫正。
- 自动白平衡：camera通过自己本身的算法，通过获取的图像自动计算出gain值对图像进行校正的方式。

## 自动白平衡算法讲解

### 灰度世界法

![](images\view.png)

灰度世界算法基于一个假说：任一幅图像,当它有足够的色彩变化,则它的RGB分量的均值会趋于相等。这是一个在自动白平衡方面应用极为广泛的理论。如上图一个颜色足够充足的画面里，假说RGB三个通道的均值是相同的。

对此算法的流程如下：

- 计算各个颜色通道的平均值；
- 寻找一个参考值K，一般情况选取Gmean;
- 计算Rgain = Gmean/Rmean, Bgain = Gmean/Bmean;
- 对图像中的每个像素都乘以对应的gain值进行校正；

### 完全反射法

完全反射也是基于一个假说：基于这样一种假设，一幅图像中最亮的像素相当于物体有光泽或镜面上的点，它传达了很多关于场景照明条件的信息。如果景物中有纯白的部分，那么就可以直接从这些像素中提取出光源信息。因为镜面或有光泽的平面本身不吸收光线，所以其反射的颜色即为光源的真实颜色，这是因为镜面或有光泽的平面的反射比函数在很长的一段波长范围内是保持不变的。完美反射法就是利用用这种特性来对图像进行调整。算法执行时，检测图像中亮度最高的像素并且将它作为参考白点。基于这种思想的方法都被称为是完美反射法，也称镜面法。通俗的意思就是整个图像中最亮的点就是白色或者镜面反射出来的，那么最亮的点就是光源的属性，但是该点本身应该是白点，以此为基础就可计算出gain值从而进行校正。

具体步骤如下，以红色通道为例：

![](images\pr.png)





### 灰度世界和完美反射结合法

就是将灰度世界和完美反射算法进行融合，具体公式如下

![](images\4.png)

通过上面的方程组就可以解出$u^{r}$和$v^{r}$ 然后对原像素进行校正：
$$
R_{new}=u^{r} R_{org}^{2}+v^{r} R_{org}
$$


### 基于模糊逻辑的算法

![](images\fuzzy_logic.png)

如图圆圈表示该颜色本身应该在坐标系中所处的位置，箭头分别表示随色温的变化发生的偏移，这个是通过先验知识得到的，后面再通过这个进行校正。

![](images\block.png)

通过以上两种方式将图像分成8块，然后通过模糊逻辑的方式计算出每个快的一个权重，这个权重和亮度和色度相关，然后通过模糊逻辑方式进行确定。求得权重后就可以计算出整个图像的加权均值，如下图10a，黑点表示八个块的分布，X表示加权后整个图像的位置。然后目的是要让加权的这个值往白点上靠，就通过调整增益的方式调试，调整完增益后，每个块儿的均值又会发生变化，然后又重新计算出每个块的权重，再通过权重计算出整个图像的均值，如图10b，整个图像的均值已经靠近原点了。然后如果X和白点的差距在一个设定的范围内则认为完成白平衡，否则继续调整增益重复上述步骤进行校正。

![](images\logic_cor.png)

### 基于白点的算法

1. 将RGB颜色空间转换到YUV空间，转换公式如下：

![](images\RGB2YUV.png)

2. 通过限定YUV的区域来判断是否为白点，如下论文通过四个限制条件俩限制白点，满足条件的点就是白点，参与后续的计算，否则不是点直接舍弃

   ![](images\grayPint.png)

   3. 通过以上四个限制条件找到白点集合后，就可以对白点集合运用GW算法或者其他算法计算gain值从而进行后续的校正；

### 基于色温的方法

![](images\T.png)

1. 通过在不同色温的环境下拍摄灰卡可以得到上面的两个曲线，一个是gain值的关系曲线，另一个是R/G与色温T的关系，那么如果获取了一张图像知道了拍摄的色温，就可以通过第二张图获取R/G的值，然后将这个值代回图一就能计算出B/G从而获得R和B的gain值;

2. 通过一定的技术手段获取色温即可，一种方法就是通过加一个色温传感器获取环境色温，这个努比亚和oppo都有相关的专利提到，这个不是常规的方式不讲解。另一种就是通过计算求出T，下面的论文就提供了一种方式

   ![](images\BaseOnT.png)

   该算法通过以下步骤迭代获取色温：

   - 定义Tmin=2000K，Tmax=15000K;
   - 判断Tmax-Tmin是否大于10，如果小如或等于10，那么久可以直接返回T，此时T可以去min,man或者二者的均值，如果满足大于10的条件，则T=(Tmin+Tmax)/2;
   - 通过图中一些列的公式，通过T就可以计算出一个R'G'B'。这些公式都是通过实验拟合总结的；
   - 对于原始图像可以求出各个通道的均值RGB，如果B'/R'>B/R那么Tmax=T，否则Tmin=T;重复上述步骤即可迭代求出色温T。



### 基于边缘的方法

![](images\edge.png)

1. 先通过一定的手段，比如梯度的方式求出图像中的边缘，然后在边缘各侧各取两个点参与计算；
2. 通过上述得到的参考点集合，就可以运行灰度世界或者其他的算法求出gain值；

该算法的有点在于，减少的大色块的干扰，因为一般认为边缘就是色块变化的的分界线，那么提取边缘两侧的样本点就可以满足颜色充分的条件，那么就可以运用灰度世界法求出gain.而且有大色块的时候计算的也是也只是选取边缘的几个点，就可以避免大色块分量太大造成白平衡异常的问题。

### 多方法融合法

![](images\wb.png)

如图是一款ISP主控的白平衡tuning的图片。每个蓝色的框就代表一种色温，比如9代表2000K,8代表2500K，这个是通过实验和经验值确定的。图中绿色的点就是通过白点算法筛选出来的白点候选点。然后调试的时候就是在不同色温下拍摄灰卡，然后挪动蓝色选框，使其包围绿点，然后右上角就是估计色温，调试的时候就是使得这个估计色温和真是色温不要相差太多。然后通过标定若干组色温之后就确定了该方案的一个色温曲线。后续再pipeline中通过白点检测算法筛选出白点，然后根据白点的分布，可以找到大多数白点分布的色温，那么该色温就是当前的色温，然后通过色温再按照前面提到的算法就可以计算出一个gain值，然后再和灰度世界算法进行一个blending就可以得到最终ISP中使用的gain值。

## 代码实现

用代码实现GW,PR和QCGP算法，核心代码如下，完整代码可以在gitee仓库中下载，然后该算法也有Python版的在仓库中

gw.m代码：

```matlab
function correctedImg = gw(img)
% gw.m    correct wb with gray world
%   Input:
%       img             org image
%   Output:
%       correctedImg    the corrected image
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-07-30
% Note: 
[height, width, ch] = size(img);
r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);

% get the mean of three channels
rMean = double(mean(mean(r)));
gMean = double(mean(mean(g)));
bMean = double(mean(mean(b)));

% get the rGain and bGain based on gMean to make sure that 
% the mean of the three channels are the same value after correcting,;
rGain = gMean / rMean;
bGain = gMean / bMean;

correctedImg = zeros(height, width, ch);
correctedImg(:,:,1) = r * rGain;
correctedImg(:,:,2) = g;
correctedImg(:,:,3) = b * bGain;
% make sure there is no overflow
correctedImg(correctedImg>255) = 255;
correctedImg = uint8(correctedImg);
end
```



pr.m代码：

```matlab
function correctedImg = pr(img)
% pr.m    correct wb with perfect reflector
%   Input:
%       img             org image
%   Output:
%       correctedImg    the corrected image
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-07-30
% Note: 
[height, width, ch] = size(img);
r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);

rMax = double(max(max(r)));
gMax = double(max(max(g)));
bMax = double(max(max(b)));

rGain = gMax / rMax;
bGain = gMax / bMax;

correctedImg = zeros(height, width, ch);
correctedImg(:,:,1) = r * rGain;
correctedImg(:,:,2) = g;
correctedImg(:,:,3) = b * bGain;
% make sure there is no overflow
correctedImg(correctedImg>255) = 255;
correctedImg = uint8(correctedImg);

end
```



QCGP代码：

```matlab
function correctedImg = qcgp(img)
% qcgp.m    correct wb with QCGP
%   Input:
%       img             org image
%   Output:
%       correctedImg    the corrected image
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-07-30
% Note: 
I = double(img);
[height, width, ch] = size(img);
r = I(:,:,1);
g = I(:,:,2);
b = I(:,:,3);

% get the mean and max of three channels
rMean = double(mean(mean(r)));
gMean = double(mean(mean(g)));
bMean = double(mean(mean(b)));

rMax = double(max(max(r)));
gMax = double(max(max(g)));
bMax = double(max(max(b)));

kMean = mean([rMean, gMean, bMean]);
kMax = mean([rMax, gMax, bMax]);

correctedImg = zeros(height, width, ch);

% calculate the coefficient
a = [rMean.*rMean, rMean; rMax.*rMax, rMax];
p = a \ [kMean; kMax];
correctedImg(:,:,1) = p(1) * (r.*r) + p(2) * r;

a = [gMean.*gMean, gMean; gMax.*gMax, gMax];
p = a \ [kMean; kMax];
correctedImg(:,:,2) = p(1) * (g.*g) + p(2) * g;


a = [bMean.*bMean, bMean; bMax.*bMax, bMax];
p = a \ [kMean; kMax];
correctedImg(:,:,3) = p(1) * (b.*b) + p(2) * b;

% make sure there is no overflow
correctedImg(correctedImg>255) = 255;
correctedImg = uint8(correctedImg);
end
```

![](images\2.jpg)

## 相关链接

- zhihu： [ISP图像处理 - 知乎 (zhihu.com)](https://www.zhihu.com/column/c_1389227246742335488)
- CSDN：[ISP图像处理_wtzhu_13的博客-CSDN博客](https://blog.csdn.net/wtzhu_13/category_11144092.html?spm=1001.2014.3001.5482)
- Bilibili：[食鱼者的个人空间_哔哩哔哩_Bilibili](https://space.bilibili.com/439454715/video)
- Gitee：[ISPAlgorithmStudy: ISP算法学习汇总，主要是论文总结 (gitee.com)](https://gitee.com/wtzhu13/ISPAlgorithmStudy)

