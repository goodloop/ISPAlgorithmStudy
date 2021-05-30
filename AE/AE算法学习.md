# 3A算法——AE(auto exposure)

## 预实验公式+LUT法

### 算法说明

这篇论文给出的AE算法其实很简单，根据以下公式
$$
\begin{gather}
\Sigma=k 1 \times L \times G \times S \tag{1}
\end{gather}
$$
∑为ISP芯片内的统计值，可以通过读取寄存器地址直接获取，L为当前物体的亮度，G为gain值，S为曝光时间。

变换以下公式：
$$
\begin{gather}
L=\Sigma /(k 1 \times G \times S) \tag{2}
\end{gather}
$$
L是当前物体的亮度，当环境不发生变化时这个是一个定值。那么思路就很简单了，初始化的时候先给定一组GS，K为常数，然后通过寄存器读出∑的值就可以计算出L，然后通过前期试验找出不同L对应的最佳GS参数组合，然后通过LUT找到这种参数组合，重新赋值给GS即可完成曝光。

具体流程如图

![](D:\论文\AE\笔记\1.png)

同时该论文中设定L的取值范围是100Lx—100000Lx之间，这么大的范围如果一个一个测试台费时间却赵勇内存过大，所以作者就将这个范围分成一个等比数列
$$
\begin{gather}
L n=(100000 / 100)^{I /(N-1)} \times L_{(n-1)} \tag{3}
\end{gather}
$$
N为设计的地址的个数，根据这个数目将这个范围分成一个等比数列。然后进一步为了简化运算，将公式(1)取对数
$$
\begin{gather}
\log L=\log \Sigma-\log S-\log G-\log k 1 \tag{4}
\end{gather}
$$
因为Ln是等比数列，那么$\log L$ 就是等差数列，那么${L_{(n)} - L_{(n-1)}} / q$ 就是一个等差为1的等差数列，就正好设计为LUT的地址，这样用一个数组就科一解决（q为等比数列的公比）。

具体推导过程如图手稿

![](D:\论文\AE\笔记\A NEW AUTOMATIC EXPOSURE SYSTEM FOR DIGITAL STILL CAMERAS.png)

### 参考文献 

《A NEW AUTOMATIC EXPOSURE SYSTEM FOR DIGITAL STILL CAMERAS 》（Tetsuya Kuno, Hiroaki Sugiura ...）