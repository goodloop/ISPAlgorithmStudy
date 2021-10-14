%% --------------------------------
%% author:wtzhu
%% email:wtzhu_13@163.com
%% date: 20210306
%% fuction: 均值滤波
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
meanKernal = uint8([1 1 1;
              1 1 1
              1 1 1]);

for i =2: m+1
    for j =2: n+1
       imgRoi = [expandImage(i-1, j-1) expandImage(i-1, j) expandImage(i-1, j+1);
                 expandImage(i  , j-1) expandImage(i  , j) expandImage(i  , j+1);
                 expandImage(i+1, j-1) expandImage(i+1, j) expandImage(i+1, j+1)];
       newImg(i-1, j-1) = uint8(sum(sum(imgRoi.*meanKernal))/9);
    end
end
newImg = uint8(newImg);
subplot(223);imshow(newImg);title('new image');
subplot(224);imshow(newImg-img);title('newImg-img');


