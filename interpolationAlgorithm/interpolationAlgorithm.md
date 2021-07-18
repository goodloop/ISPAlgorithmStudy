# ISP——图像插值算法

[TOC]

差值算法作为一种最常用的算法，在图像放大、旋转等多种变换中都有用到。由于图像进行某种变换后新的图像的像素并非完全和原始图像的像素一一对应，所以导致新的图像中会出现很多“空穴”，这是就需要对这些“空穴”进行填补。所谓插值算法也就是填补的方式。本文主要通过造轮子的方式通过图像放大来介绍三种最常见的插值算法：邻域插值、双线性插值和双三次插值。希望对各位理解插值算法有所帮助。



## 空间映射关系

在开始正式介绍插值之前，需要先介绍一下空间坐标的映射关系。

### 前向映射

前向映射就是从原图像坐标计算出目标图像坐标。用一下公式表示
$$
g(x’,y’) = f(a(x,y), b(x,y))
$$


### 反向映射

反向映射从结果图像的坐标计算原图像的坐标。用一下公式表示
$$
g(a’(x,y), b’(x,y)) = f(x,y);
$$
一般在图像缩放是使用反向映射的方式，通过新的图像的点坐标求出在原始图像中的位置，然后通过原始图像周围的点的值来填充，即插值算出该点的值。

## 邻域插值

邻域插值也叫最近邻插值，是指将目标图像中的点，对应到原图像中后，找到最相邻的整数点，作为插值后的输出。



![1](.\images\1.jpg)

如图所示，P为新图像中的点经过反向映射后在原始图像中的位置。最近邻的意思就是P点原始图像中的哪个点最近，就用该点的值赋值给P。编程时的主要思路就是通过P点坐标的小数位进行四舍五入，求出最近的点，然后直接把该点的值赋值过去就好了。

### 代码如下：

```matlab
%% --------------------------------
%% author:wtzhu
%% date: 20210131
%% fuction: 邻域插值
%% --------------------------------

clc,clear,close all;
% 读取图片
orgImage = imread('lena.bmp');
figure;imshow(orgImage);title('org image');

% 获取长宽
[width, height] = size(orgImage);
m = width / 2;
n =  height / 2;
smallImage = zeros(m,n);
% 降采样，将原图缩减为原来的1/2
for i=1:m
    for j=1:n
        smallImage(i,j) = orgImage(2*i,2*j);
    end
end
figure;imshow(uint8(smallImage));title('small image');

% 插值时需要特殊处理四周最外圈的行和列，本算法中将其向外扩展一圈，用最外圈的值填充
headRowMat = smallImage(1,:);%取f的第1行
tailRowMat = smallImage(m,:);%取f的第m行
% 行扩展后，列扩展时需要注意四个角需要单独扩展进去，不然就成了十字架形的
headColumnMat = [smallImage(1,1), smallImage(:,1)', smallImage(m,1)];
tailColumnMat = [smallImage(1,n), smallImage(:,n)', smallImage(m,n)];
expandImage = [headRowMat; smallImage; tailRowMat];
expandImage = [headColumnMat; expandImage'; tailColumnMat];
expandImage = uint8(expandImage');
figure;imshow(expandImage);title('expand image');

% 按比例放大
[smallWidth, smallHeight] = size(smallImage);
% 设置放大系数
magnification = 2;
newWidth = magnification * smallWidth;
newHeight = magnification * smallHeight;
% 创建一个新的矩阵，用于承接变换后的图像
newImage = zeros(newWidth, newHeight);

% 循环计算出新图像的像素值
for i = 1 : newWidth
   for j = 1: newHeight
       detaX = rem(i, magnification) / magnification;
       floorX = floor(i / magnification) + 1;
       detaY = rem(j, magnification) / magnification;
       floorY = floor(j / magnification) + 1;
       if detaX < 0.5 && detaY < 0.5
            newImage(i, j) = expandImage(floorX, floorY);
       elseif detaX < 0.5 && detaY >= 0.5
            newImage(i, j) = expandImage(floorX, floorY + 1);
       elseif detaX >= 0.5 && detaY < 0.5
            newImage(i, j) = expandImage(floorX + 1, floorY);
       else
            newImage(i, j) = expandImage(floorX + 1, floorY + 1);
       end
   end
end
figure;imshow(uint8(newImage));title('NeighborhoodInterpolation');
```

运行结果如图![最邻近插值](.\images\2.jpg)

---



## 双线性插值

双线性插值算法就是在最近邻插值算法的基础上，用周围的四个点通过线性插值的方式计算出该点的值。

![](.\images\3.jpg)

如图，就是先通过A1和A2两个点通过线性插值的方式计算出B1的值，然后通过A3和A4计算出B2的值，然后通过B1和B2计算出P点的值。通过三维图可能更容易理解



![](.\images\4.png)

算法推导过程：

首先通过A和B计算出N的值有方程：
$$
\begin{align} \frac{Z_{B}-Z_{A}}{Y_{1}-Y_{0}} = \frac{Z_{N}-Z_{A}}{Y-Y_{0}} \tag{1} \end{align}
$$


通过C和D求出M的值：
$$
\begin{align} \frac{Z_{C}-Z_{D}}{Y_{1}-Y_{0}} = \frac{Z_{M}-Z_{D}}{Y-Y_{0}} \tag{2} \end{align}
$$
最后通过M和N求出O的值：
$$
\begin{align} \frac{Z_{M}-Z_{N}}{X_{1}-X_{0}} = \frac{Z-Z_{N}}{X-X_{0}} \tag{3} \end{align}
$$
综合式（1）、（2）、（3）得：
$$
Z=(Z_{C}-Z_{A})*X + (Z_{B}-Z_{A})*Y + (Z_{D}+Z_{A}-Z_{B}-Z_{C})*X*Y + Z_{A}
$$

### 代码如下：

```matlab
%% --------------------------------
%% author:wtzhu
%% date: 20210202
%% fuction: 双线性插值
%% f(x,y) = [f(1,0)-f(0,0)]*x+[f(0,1)-f(0,0)]*y+[f(1,1)+f(0,0)-f(1,0)-f(0,1)]*xy+f(0,0)
%% x,y都是归一化的值
%% --------------------------------

clc,clear,close all;
% 读取图片
orgImage = imread('lena.bmp');
figure;imshow(orgImage);title('org image');

% 获取长宽
[width, height] = size(orgImage);
m = width / 2;
n =  height / 2;
smallImage = zeros(m,n);
% 降采样，将原图缩减为原来的1/2
for i=1:m
    for j=1:n
        smallImage(i,j) = orgImage(2*i,2*j);
    end
end
figure;imshow(uint8(smallImage));title('small image');

% 插值时需要特殊处理四周最外圈的行和列，本算法中将其向外扩展一圈，用最外圈的值填充
headRowMat = smallImage(1,:);%取f的第1行
tailRowMat = smallImage(m,:);%取f的第m行
% 行扩展后，列扩展时需要注意四个角需要单独扩展进去，不然就成了十字架形的
headColumnMat = [smallImage(1,1), smallImage(:,1)', smallImage(m,1)];
tailColumnMat = [smallImage(1,n), smallImage(:,n)', smallImage(m,n)];
expandImage = [headRowMat; smallImage; tailRowMat];
expandImage = [headColumnMat; expandImage'; tailColumnMat];
expandImage = uint8(expandImage');
figure;imshow(expandImage);title('expand image');

% 按比例放大
[smallWidth, smallHeight] = size(smallImage);
% 设置放大系数
magnification = 2;
newWidth = magnification * smallWidth;
newHeight = magnification * smallHeight;
% 创建一个新的矩阵，用于承接变换后的图像
newImage = zeros(newWidth, newHeight);

% f(x,y) = [f(1,0)-f(0,0)]*x+[f(0,1)-f(0,0)]*y+[f(1,1)+f(0,0)-f(1,0)-f(0,1)]*xy+f(0,0)
for i = 1 : newWidth
   for j = 1: newHeight
       detaX = rem(i, magnification) / magnification;
       floorX = floor(i / magnification) + 1;
       detaY = rem(j, magnification) / magnification;
       floorY = floor(j / magnification) + 1;
       newImage(i, j) = (expandImage(floorX + 1,floorY) - expandImage(floorX,floorY)) * detaX + ... 
                        (expandImage(floorX, floorY + 1) - expandImage(floorX, floorY)) * detaY + ...
                        (expandImage(floorX+1, floorY+1) + expandImage(floorX, floorY) - ...
                            expandImage(floorX+1, floorY) - expandImage(floorX, floorY+1)) * detaX * detaY + ...
                        expandImage(floorX, floorY);
   end
end
figure;imshow(uint8(newImage));title('BilinearInterpolation');


```

结果如图![](.\images\4.jpg)

## 双三次插值

在满足Nyquist 条件下，从离散信号x(nTs)可恢复连续信号可恢复连续信号x(t) ： 
$$
x(t)=\sum_{i=-\infty}^{+\infty} x\left(n T_{s}\right) \sin c\left(\frac{\pi}{T_{S}}\left(t-n T_{s}\right)\right)
$$
![](.\images\5.jpg)

那么就联想到图像是否也能通过这种方式复原。

考虑到计算量，我们只取-2到2这个区间的点来计算



![](.\images\6.jpg)

然后我们通过
$$
S(x)=\left[\begin{array}{cc}
1-2|x|^{2}+|x|^{3} & |x|<1 \\
4-8|x|+5|x|^{2}-|x|^{3} & 1 \leq|x| \leq 2 \\
0 & |x|>2
\end{array}\right.
$$
来分段拟合曲线，从而求出待求点的值。

### 代码如下：

```matlab
%% --------------------------------
%% author:wtzhu
%% date: 20210202
%% fuction: 双三次内插法
%% --------------------------------
clc,clear,close all;
orgImage = imread('lena.bmp');
[width, height] = size(orgImage);%将图像隔行隔列抽取元素，得到缩小的图像f
figure; imshow(orgImage); title('org image');%显示原图像

m = width/2;
n = height/2;
smallImage = zeros(m, n);
for i = 1: m
    for j = 1: n
        smallImage(i, j) = orgImage(2*i, 2*j);
    end
end
figure;imshow(uint8(smallImage));title('small image');%显示缩小的图像


magnification = 2;%设置放大倍数
a = smallImage(1,:);%取f的第1行
c = smallImage(m,:);%取f的第m行
%将待插值图像矩阵前后各扩展两行两列,共扩展四行四列到f1
b = [smallImage(1,1), smallImage(1,1), smallImage(:,1)', smallImage(m,1), smallImage(m,1)];
d = [smallImage(1,n), smallImage(1,n), smallImage(:,n)', smallImage(m,n), smallImage(m,n)];
a1 = [a; a; smallImage; c; c];
b1 = [b; b; a1'; d; d];
expandImage = double(b1');

newImage = zeros(magnification*m,magnification*n);
for i = 1:magnification * m%利用双三次插值公式对新图象所有像素赋值
    u = rem(i, magnification)/magnification;
    i1 = floor(i/magnification) + 2;%floor()向左取整，floor(1.3)=floor(1.7)=1
    A = [sw(1+u) sw(u) sw(1-u) sw(2-u)];
    for j = 1:magnification*n
        v = rem(j, magnification)/magnification; j1=floor(j/magnification)+2;
        C = [sw(1+v); sw(v);  sw(1-v); sw(2-v)];
        B = [expandImage(i1-1,j1-1) expandImage(i1-1,j1) expandImage(i1-1,j1+1) expandImage(i1-1,j1+2); 
             expandImage(i1,j1-1) expandImage(i1,j1) expandImage(i1,j1+1) expandImage(i1,j1+2);
             expandImage(i1+1,j1-1) expandImage(i1+1,j1) expandImage(i1+1,j1+1) expandImage(i1+1,j1+2);
             expandImage(i1+2,j1-1) expandImage(i1+2,j1) expandImage(i1+2,j1+1) expandImage(i1+2,j1+2)];
        newImage(i,j) = (A*B*C);
    end
end
%显示插值后的图像
figure,imshow(uint8(newImage));title('BicubicInterpolation');
```

```matlab
%% --------------------------------
%% author:wtzhu
%% date: 20210202
%% fuction: 双三次插值算法sin函数的拟合函数
%% --------------------------------
function A = sw(w1)
w = abs(w1);
if w < 1 && w >= 0
   A = 1 - 2 * w^2 + w^3;  
elseif w >= 1 && w < 2
   A = 4 - 8 * w + 5 * w^2 - w^3;
else
   A = 0;
end
```



运行结果：![](.\images\7.jpg)

## 总结

通过分析三种算法可以看出，最邻近方式最简单，计算量小，但是插值效果一般；

双三次插值算法的计算量最大，但是插值出来的效果最好；

双线性插值算法则介于两者之间。