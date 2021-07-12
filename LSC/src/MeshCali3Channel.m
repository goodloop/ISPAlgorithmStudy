%% --------------------------------
%% author:wtzhu
%% date: 20210712
%% fuction: main file of MeshCali3Channel
%% --------------------------------
clc;clear;close all;

% --------parameters of calibretion------------
filePath = 'images/lsc.bmp';
side_num = 16;
meshON = 1;
% ---------------------------------------------

image = imread(filePath);
[height, width, channel] = size(image);
side_y = floor(height/side_num);
side_x = floor(width/side_num);
h = imshow(image);
if meshON
    for i = 1:side_num-1
        line([i*side_x, i*side_x], [1, height], 'color', 'r');
        line([1, width], [i*side_y, i*side_y], 'color', 'r');
    end        
end
title('refImg');

image_r = image(:,:,1);
image_g = image(:,:,2);
image_b = image(:,:,3);

%% compress resolution
image_point_r = zeros(side_num+1,side_num+1);
image_point_g = zeros(side_num+1,side_num+1);
image_point_b = zeros(side_num+1,side_num+1);
for i = 0:side_num
    for j = 0:side_num
        x_clip = floor([j*side_x - side_x/2, j*side_x + side_x/2]);
        y_clip = floor([i*side_y - side_y/2, i*side_y + side_y/2]);
        % make sure that the last point on the edge
        if(i==side_num && y_clip(2) ~= height) 
            y_clip(2) = height;
        end
        if(j==side_num && x_clip(2) ~= width) 
            x_clip(2) = width;
        end
        x_clip(x_clip<1) = 1;
        x_clip(x_clip>width) = width;
        y_clip(y_clip<1) = 1;
        y_clip(y_clip>height) = height;
        data_r = image_r(y_clip(1):y_clip(2), x_clip(1):x_clip(2));
        image_point_r(i+1,j+1) = mean(mean(data_r));
        
        data_g = image_g(y_clip(1):y_clip(2), x_clip(1):x_clip(2));
        image_point_g(i+1,j+1) = mean(mean(data_g));
        
        data_b = image_b(y_clip(1):y_clip(2), x_clip(1):x_clip(2));
        image_point_b(i+1,j+1) = mean(mean(data_b));
    end
end

rGain = zeros(side_num+1,side_num+1);
gGain = zeros(side_num+1,side_num+1);
bGain = zeros(side_num+1,side_num+1);

%% caculate lsc luma gain
for i = 1:side_num+1
    for j = 1:side_num+1
        rGain(i,j) = image_point_r(uint8(side_num/2) +1, uint8(side_num/2) +1) / image_point_r(i,j);
        gGain(i,j) = image_point_g(uint8(side_num/2) +1, uint8(side_num/2) +1) / image_point_g(i,j);
        bGain(i,j) = image_point_b(uint8(side_num/2) +1, uint8(side_num/2) +1) / image_point_b(i,j);
    end
end
save('./src/data/rGain.mat', 'rGain');
save('./src/data/gGain.mat', 'gGain');
save('./src/data/bGain.mat', 'bGain');





