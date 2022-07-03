# ISP——CCM

## CCM的作用

<img src="D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\CCM_off.jpg" style="zoom: 10%;" />

<img src="D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\CCM_on.jpg" alt="CCM_on" style="zoom:10%;" />

如图所示，CCM(Color Correction Matrix)的作用就是通过一个3X3的矩阵使得颜色更接近人眼所感受的颜色。人眼之所以能感受到自然界的颜色是因为人眼的视锥细胞在起作用。人眼主要通过三种视锥细胞感受三种不同波长的光从而感受颜色。如图所示是人眼感受不同波长的反应曲线，分别对应三种不同的波长，所以通常用RGB三原色来表示颜色。

![](D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\LMS.png)

如图是IMX415C和ICX262AQ两种sensor的感光特性，可以看出来和人眼的感光曲线有很大的不同，而且同样SONY生产的sensor各自的感光曲线的特性也有很大差异，所以如果直接用sensor感光的特性来表示颜色回合人眼有很大的差异，且同一种颜色通过不同sensor感光后得到的数据是不一样的，而对于显示器而言就会表现出不同的颜色，这是我们不希望看到的，我们希望同一种颜色即使使用不同的sensor也能得到相同的RGB数据且和人眼感受的颜色一致或者接近。

![FSM-IMX415C](D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\FSM-IMX415C.png)

![ICX262AQ](D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\ICX262AQ.png)

为了达到上述的要求，我们可以理解为人眼对物体感受的颜色是我们的目标，那么就需要将sensor感光数据经过某种变换达到我们的目标。假设人眼能感受到的颜色种类有m种，那么自然界的颜色就可以表示为一个3Xm的矩阵，同理sensor对自然界的感光也可以得到一个3Xm的矩阵。

![](D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\CCMtarget.png)

那么我们需要做的就是将右侧sensor感光的数据转换到左侧人眼感光的数据上来。



## 颜色学基础

上面已经谈到了CCM的作用，也知道CCM的目的，那么有个很重要的东西我们需要了解，那就是CCM的目标矩阵，就是上图中左侧的目标是是什么？又是如何得到的呢？

这里就不得不提到颜色匹配实验了。

### CIE RGB 

<img src="D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\colorMatchingExperiment.png" style="zoom:50%;" />

该实验原理如图所示，右侧有两个屏幕，一侧有一个可以改变波长的光源，一侧是固定三种波长（红绿蓝）的光源，然后人眼通过一个角度去看这两个屏幕。f光源改变不同的波长呈现出不同的颜色，然后通过P1，P2，P3三个波长的光源不同的强度的混合，使得人眼感受到两个屏幕的颜色一致，然后记录下此时的三色值，那么该三色值就表示f测波长对应的颜色值。CIE通过该实验就得到了CIE RGB颜色空间的数据

<img src="D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\CIERGB.png" style="zoom:50%;" />

从图中可以看到CIE RGB有数据是负数，这个是因为某个波长颜色的光通过P1，P2，P3在一侧混合无法得到，那么就需要将某个光源放到f测去才能到达这种效果，那么此时就相当于对改颜色做了减法，那么就出现了负数。

![](D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\CIERGB-3D.png)



上图CIE RGB空间为三维的不方便操作，那么就对RGB做归一化，使得R+G+B=1，那么一直其中两个颜色就可以得到第三个颜色，从而将三维空间降维到二维方便操作。

![](D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\CIERGB1.png)

### CIE XYZ

由于CIE RGB会出现负数，不适合理解和操作，所以人为定义一组新的三原色XYZ，实现通过整数表示所有颜色。经过一系列的坐标变换之后就可以重新得到一个XYZ的颜色空间，同理经过归一化之后可以投影到二维空间方便理解。至于其中一些列的变化网上有很多帖子，感兴趣的可以去查看，这里不做过多展开。

![](D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\CIEXYZ1.png)

### sRGB

![](D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\colorSpace.jpg)

sRGB就是由惠普和微软一起开发的一个用于显示器的颜色空间，因为现实器也不可能现实自然界所有的颜色，所以就在xy坐标系中选取一个三角形范围作为现实器的显示色域。同时通过定义不同的区域还有Adobe RGB色域空间和其他。目前ISP中CCM的目标通常是以sRGB为目标。



## 颜色校正算法

这里叫颜色校正算法其实主要是针对转换过程而言，因为CCM只是转换算法的一种。上面我们已经知道我们整个过程其实就是将一个矩阵转换为另外一个矩阵，那么我们首先能想到的就是LUT，就是将两个矩阵表示的颜色都通过一张表来表示对应的关系，那么进来一个颜色就可以通过查表快速得到想要的颜色。

![](D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\3DLUT.jpg)

当然实际中没法把所有的颜色的数据都得到，那么就通过采样的到部分坐标的数据形成一个三维表，其他不在采样点位置的数据就可以通过插值的方式求出来。

除了上述的LUT的方式还有神经网络的方式，因为其实输入就是一个矩阵，输出也是一个矩阵，那么中间通过网络连接，然后通过数据训练也能得到一个转换的网络参数。

![](D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\nn.png)

上述两种方式是实现颜色转换的一种方式，但是不是CCM方式，这里作为一种补充讲解。

其实通过前面的分位我们可以知道我们的操作就是从一个3Xm的矩阵转换到另一个3Xm的矩阵，那么很容易就能想到通过一个3X3的矩阵的乘法来完成这种转换

![](D:\ISP\PersonalProjects\ISPAlgorithmStudy\CCM\images\colorTrans.png)

这个3X3的矩阵就是我们需要的颜色校正矩阵，也就是本文的重点CCM。

## CCM求解方式

CCM算法的原理其实很简单，就是通过一个3X3的矩阵完场两个矩阵之间的转换。我们的目标就是求解这个矩阵。这么个式子的求解让人第一反应就是通过矩阵操作，用线性代数的方式求解，但是这么做有一个问题。通常CCM之前已经完成的白平衡操作，那么如果求解出来的矩阵不能满足M11+M12+M13=M21+M22+M23=M31+M32+M33这个限制条件，那么经过CCM之后白平衡就会失效，这个是我们不希望的，所以通常不会通过简单的矩阵求解的方式来做，而是通过带限制条件的优化方程的方式来求解，这样求解出来的矩阵就能保证白平衡不被破坏。

还有一点需要注意在迭代的过程中通常不会直接用RGB之间的转换，也就是CCM这个看似一个3X3的矩阵其实是有好几个矩阵叠加到一块儿形成的一个矩阵，因为在优化的过程中需要一个损失函数，通过这个值来判断是否停止迭代，通过这个值选择了CIR Lab空间，至于为什么这么做可以去
[B站视频CCM相关讲解]: https://www.bilibili.com/video/BV123411M7E4?spm_id_from=333.999.0.0	"B站视频CCM相关讲解"

查看更详细的讲解。

## 相关链接

- zhihu： [ISP图像处理 - 知乎 (zhihu.com)](https://www.zhihu.com/column/c_1389227246742335488)
- CSDN：[ISP图像处理_wtzhu_13的博客-CSDN博客](https://blog.csdn.net/wtzhu_13/category_11144092.html?spm=1001.2014.3001.5482)
- Bilibili：[食鱼者的个人空间_哔哩哔哩_Bilibili](https://space.bilibili.com/439454715/video)
- Gitee：[ISPAlgorithmStudy: ISP算法学习汇总，主要是论文总结 (gitee.com)](https://gitee.com/wtzhu13/ISPAlgorithmStudy)