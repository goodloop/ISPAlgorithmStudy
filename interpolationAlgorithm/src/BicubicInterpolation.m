%% --------------------------------
%% author:wtzhu
%% date: 20210202
%% fuction: 双三次内插法
%% --------------------------------
clc,clear,close all;
orgImage = imread('./images/lena.bmp');
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
figure,
% subplot(121);imshow(uint8(smallImage));title('small image');%显示缩小的图像
imshow(uint8(newImage));title('BicubicInterpolation');


