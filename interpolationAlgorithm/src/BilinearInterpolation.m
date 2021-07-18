%% --------------------------------
%% author:wtzhu
%% date: 20210202
%% fuction: 双线性插值
%% f(x,y) = [f(1,0)-f(0,0)]*x+[f(0,1)-f(0,0)]*y+[f(1,1)+f(0,0)-f(1,0)-f(0,1)]*xy+f(0,0)
%% x,y都是归一化的值
%% --------------------------------

clc,clear,close all;
% 读取图片
orgImage = imread('./images/lena.bmp');
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
figure;
% subplot(121);imshow(uint8(smallImage));title('small image');
imshow(uint8(newImage));title('BilinearInterpolation');

