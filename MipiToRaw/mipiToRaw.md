# ISP--MIPI数据与RAW数据的转换

## 问题

最近在用海思的raw来做ISP算法的研究，在获取raw图的过程发现了一个问题如下图

![rawInfo](\imgs\rawInfo.jpg)

途中可以看出来10bits、12bits、16bits的数据量是一样的，而且还刚好是8bits的两倍，说明8bits的数据是通过一个字节来存储，而其他三种都是通过两个字节来存储。这个就能很好的解释这种现象。但是我又发现抓图工具抓图的时候的数据量和这个不一样：



![](\imgs\8bits.jpg)

![10bits](\imgs\10bits.jpg)

<img src="\imgs\12bits.jpg" alt="12bits" />

<img src="\imgs\16bits.jpg" alt="12bits" style="zoom:100%;" />

从着几张图中的数据量来看发现不同格式的数据需要receive的数据量不通，这说明数据传输过程中用的数据格式和存储用的数据格式有所不同，带着问题就开始查资料，最终锁定在了mipi数据格式和raw数据格式的不同上。

## mipi和raw格式简介

网上的简介，摘抄过来
传感器采集的RAW数据通常为10bit，存储RAW数据需要两个Byte，而其中有6个bit位是空着的，这样就有存储空间浪费。MIPI RAW数据充分利用了这个特性，采用5个Byte，共40bit存储4个RAW数据。那么怎么理解这个意思呢，下面通过一张图来解释(主要通过10bits来解释，其他格式是类似的)

![](\imgs\rawToMipi.jpg)

如上图，加入10bits的raw图上又四个像素，像素值分别为341，242，273，840，那么他们在raw图中的存储方式就如途中红红绿绿的那一堆二进制，每个像素值都需要用两个字节来存储，也就是存储这四个像素值需要8个字节的空间。每个像素两个字节就有16bits的空间，但是实际值只有10bits，所以有6bits的空间是浪费的就如图中红色部分。而MIPI为了充分利用空间就将每个像素数据的高八位单独用一个字节存储，而低两位单独用一个字节存放，那么每四个像素就会多出8位，刚好可以再多用一个字节存储，存储方式如图用不同颜色表示，所以MIPI的方式存放4个10bits的数据只需要5个字节，节省很多空间。

**注：为什么不是将高两位拿出来单独存储，然后多出来的两位顺序为什么不能反过来，比如图中多出来的字节存储为01100100，这两点可能需要具体去看MIPI手册，因为目前我就是研究一下具体的转换方式，具体存放方式用的时候可以换，所以还没有深入研究。如果有谁能解释好这个也请整理篇博客回复在下面。**

## mipi和raw之间的相互转换

在上面格式简介中理解清楚了就很好实现这个之间的转换了。思路如下：

1. raw->mipi:

   1. 将两个字节的像素值右移两位就能得到高八位的数据直接存储为一个字节；

   2. 将四个字节的像素值强制类型转换为一个字节，也就是将高位舍弃，然后将得到的值与0x03位于就能得到地两位的值，用于存储到单独的一个字节中；

   3. 初始化一个单独的字节空空间每一位都赋值位0，然后将2中的到的一个字节左移n*2位（因为地位每两位都被前面像素值多出来的两位占据了），然后将初始化的这个字节与这个移位后的字节进行按位或操作即可；

   4. 将上面的操作重复四次，就能将四个像素值存储到五个字节中，具体代码如下

      ```c
      for(int i=0; i<4; i++)
      {
          mipiRawArr[i] = (char)(orgRaw10BitsArr[i] >> 2);
          mipiRawArr[4] = mipiRawArr[4] | ((((char)orgRaw10BitsArr[i]) & 0x03)<< (2*i));
      }
      ```

2. mipi->raw:就是将上面的操作反过来

   1. 先将一个字节存储的数据强制类型转换位两个字节的类型，然后左移两位，这样就能得到高八位数据；

   2. 将单独存储的那个字节左移2*n位然后与0x03进行按位与操作就能得到低两位数据；

   3. 将1中得到的两个字节的数据与2中得到的数据进行按位或操作就能完整回复10bits的存储方式，具体代码实现如下

      ```c
      for(int i=0; i<4; i++)
      {
      	outRawArr[i] = ((outRawArr[i] | (short)mipiRawArr[i]) << 2) &0x3FF | ((mipiRawArr[4] >> (i*2)) & 0x03);
      }
      ```

      注：为了防止出现移位的时候异常，1中左移两位后和0x3FF进行一次按位与操作，将不用的六位数据都清零；

通过以上的方式进行了实验，用文中开始说的像素值341，242，273，840四个来模拟，先将其转换为mipi数据并保存到二进制文件中，再将mipi数据转换位raw格式保存到一个二进制文件中，然后对比发现是一致的，说明算法工作正常；

![](\imgs\1625138248(1).png)

而且计算结果业余计算器算出来一致。

## 完整的代码

```c
#include <stdio.h>

int main(int argc, char *argv[])
{
    short orgRaw10BitsArr[4] = {0x0155, 0x00f2, 0x0111, 0x0348};
    FILE *fOrgRaw = fopen("org.dat", "wb+");
    FILE *fMipiRaw = fopen("mipiRaw.dat", "wb");
    FILE *fOutRaw = fopen("out.dat", "wb+");

    // raw to mipi
    // 1.get the high 8-bit data and set to a new byte
    // 2.get the low 2-bit data and set to the individual byte, note the pos of the 2-bit
    char mipiRawArr[5] = {0};
    
    for(int i=0; i<4; i++)
    {
        mipiRawArr[i] = (char)(orgRaw10BitsArr[i] >> 2);
        mipiRawArr[4] = mipiRawArr[4] | ((((char)orgRaw10BitsArr[i]) & 0x03)<< (2*i));
    }

    // mipi to raw
    // 1. transform 8-bit to 16-bit and two shift to the left leave room for the low 2-bit
    // 2. get the low 2-bit
    // 3. combine the high 8-bit and the low 2-bit into one which is 10bits
    short outRawArr[4] = {0};
    for(int i=0; i<4; i++)
    {
        outRawArr[i] = ((outRawArr[i] | (short)mipiRawArr[i]) << 2) &0x3FF | ((mipiRawArr[4] >> (i*2)) & 0x03);
    }

    // save as .dat file
    fwrite(mipiRawArr, 1, 5, fMipiRaw);
    fwrite(outRawArr, 1, 8, fOutRaw);
    fwrite(orgRaw10BitsArr, 1, 8, fOrgRaw);
    
    fclose(fMipiRaw);
    fclose(fOutRaw);
    fclose(fOrgRaw);
    return 0;
}
```



## 总结

文中通过四个像素来模拟现象，如果要对整幅图像进行操作，就是将整个图像分成四个四个一组，然后每一组进行这个算法操作即可，类似于滑动窗口的操作。

然后我们再回到文中开头的问题上，看看接受过程中10bits的时候需要16473704bytes，存储下来的10bits数据位25643kb，两者比值刚好与40/64（原本需要64位存储的数据只需要40位就能存储）近似，不完全相同的原因一方面是本地显示的是kb后面的数据不知多少，所以也是近似计算的，零一仿麦呢实际传输的时候可能还涉及校验位这些数据，但是已经能说明两种数据存储方式不同导致的。

**福利：本文所有资料均可在[ISPAlgorithmStudy: ISP算法学习汇总，主要是论文总结 (gitee.com)](https://gitee.com/wtzhu13/ISPAlgorithmStudy)仓库中获取**