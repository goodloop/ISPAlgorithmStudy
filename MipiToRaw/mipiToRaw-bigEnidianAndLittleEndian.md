# mipiToRaw-bigEnidianAndLittleEndian（大端小端数据补充）

在上一篇[《MIPI数据与RAW数据的转换》](https://zhuanlan.zhihu.com/p/385817986)中有读者提出了大端小端的问题，其实上篇写的时候就是为了避免将读者带进这种存储方式中而失去理解算法的主体的误区，就没提这个东西，因为理解好了算法本质，对于这种存储方式的不同稍作变化就OK了。但是既然有人提到这个，为了方便理解上一篇算法，这里就补充一下相关的说明。

## 大小端储存

大端存储与小端存储模式主要指的是数据在计算机中存储的两种字节优先顺序。小端存储指从内存的低地址开始，先存储数据的低序字节再存高序字节；相反，大端存储指从内存的低地址开始，先存储数据的高序字节再存储数据的低序字节。这么说可能不好理解，下面举个例子说明，以4bytes的int类型来举例：



![](E:\Fred\ISP\ISPAlgorithmStudy\MipiToRaw\imgs\1.jpg)

0x12345678如图所示刚好同一种颜色就占用一个字节，然后这种表示就是左到右分位是高位到地位。

那么再内存中的存储方式如下

![](E:\Fred\ISP\ISPAlgorithmStudy\MipiToRaw\imgs\2.jpg)

简单说就是

- 小端存储如上面一行，数据的低位存放在内存地址的低地址，数据的高位存放在内存地址的高地址；
- 大端存储如下面一行，数据的高位存放在内存地址的低地址，数据的低位存放在内存地址的高地址。

**注：**

	1. **一定区分好数据的高低位，内存地址的高低地址，这两个概念是不一样的。**
 	2. **数据是以字节，也就是八位为最小的存储单元。**

## 字节序和位序

大小端是针对字节序而言的，意思就是大小端针对的是上图每个相同颜色（字节）的分布顺序，是绿黄橙红还是红橙黄绿，而不针对每个颜色内部位的排序，当然不排除也有位的排序不同的情况，但是目前我没遇到过，所以暂且不讨论。

![](E:\Fred\ISP\ISPAlgorithmStudy\MipiToRaw\imgs\3.jpg)

如图所示，无论大端存储还是小端存储，每个字节内部的每一位二进制的排序是不变的，只是每八位的排序分前后而已。所以一定要区别好字节序和位序的区别。

## 回到MIPI和RAW数据的转换

再回到上篇文中例子

![](E:\Fred\ISP\ISPAlgorithmStudy\MipiToRaw\imgs\rawToMipi.jpg)

314，242，273，840四个像素值转换为MIPI格式后位0x55,0x3c,0x44,0xD2,0x19五个值，联系本文提到的大小端，无非就是这五个值得排列顺序不同而已

![](E:\Fred\ISP\ISPAlgorithmStudy\MipiToRaw\imgs\4.jpg)

如图，只是这五个字节得排序不同，但是每个字节内部位序是一样得，那么你获取高低位得移位方式就是一样的。再回到上篇博文的代码讨论

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

这个代码是按照上图上面一行的顺序来写的，所以10bits多出来的两个字节存放在后面，所以MIPI转RAW的时候就用mipiRawArr[4] >> (i\*2) 的方式取这两位比如0x55的多出来的两位就左移两位。然后换个方式存储的话0x55的也是左移两位，不同的是合并成10位的时候从后面去除0x55。

所以简单改成以下就可以搞定了。

```c
for(int i=5; i>0; i--)
{
	outRawArr[5-i] = ((outRawArr[5-i] | (short)mipiRawArr[i]) << 2) &0x3FF | ((mipiRawArr[0] >> ((5-i）*2)) & 0x03);
}
```

## 说明

补充本文主要是为了方便理解上一篇文中提到的数据转换给是，不是重点讨论数据内部的存储方式。