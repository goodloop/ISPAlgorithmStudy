%% --------------------------------
%% author:Fred
%% date: 20220602
%% fuction: 
%% note: 注意获取点的左边的顺序
% 获取六个点坐标顺序如下：
% 1--------------3-------------5
% |              |             |
% 2--------------4-------------6
%% --------------------------------
clc;clear;close all;

% 加载检测图片，路径更改为需要测试的图片的路径 
img = imread('./images/117-oldBoard-13M.png');
imshow(img);

% 获取六个点的坐标
[x,y]=ginput(6);
a1 = y(2)-y(1);
b = y(4)-y(3);
a2 = y(6)-y(5);
a = (a1 + a2) / 2;
distortion = (a - b) / b * 100;
strDis = sprintf('TV distortion is: %f %s', distortion, '%');
disp(strDis);

