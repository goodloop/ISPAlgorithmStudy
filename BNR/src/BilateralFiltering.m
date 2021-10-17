%% --------------------------------
%% author:wtzhu
%% email:wtzhu_13@163.com
%% date: 20211011
%% fuction: 双边滤波
%% --------------------------------
clc;clear;close all;

% gaussian filter
% the weight is only related to distance
x = 1:200;
y = 1:200;
[X, Y] = meshgrid(x, y);
D = (X-100).^2+(Y-100).^2;
z1 = exp(-D/2000);
figure();
mesh(x, y, z1)
title('高斯模型')

% add pixel value weight;
a = ones(200)*220;
a(:,1:100) = 20;
a(1:100,:) = 20;
figure();
imshow(uint8(a));
title('图像')
z2 = zeros(200);
for i=1:200
    for j=1:200
        z2(i, j) = exp(-(a(i, j)-220)^2/1800);
    end
end
figure();
mesh(x, y, z2);
title('像素权重');
z = z1.*z2;
figure();
mesh(x, y, z)
title('双边模型')

