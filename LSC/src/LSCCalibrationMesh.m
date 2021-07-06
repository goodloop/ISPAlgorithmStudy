%% --------------------------------
%% author:wtzhu
%% date: 20210706
%% fuction: main file of LSCCalibrationMesh
%% --------------------------------
clc;clear;close all;

% --------parameters of calibretion------------
filePath = 'images/lsc.bmp';
side_num = 16;
meshON = 1;
% ---------------------------------------------

image = imread(filePath);
[height, width, chan] = size(image);
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

%% compress resolution
image_point = zeros(side_num+1,side_num+1);
image_r_point= zeros(side_num+1,side_num+1);
image_g_point= zeros(side_num+1,side_num+1);
image_b_point= zeros(side_num+1,side_num+1);

image_r = image(:,:,1);
image_g = image(:,:,2);
image_b = image(:,:,3);
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
        data_r_in = image_r(y_clip(1):y_clip(2), x_clip(1):x_clip(2));
        image_r_point(i+1,j+1) = mean(mean(data_r_in));
        data_g_in = image_g(y_clip(1):y_clip(2), x_clip(1):x_clip(2));
        image_g_point(i+1,j+1) = mean(mean(data_g_in));
        data_b_in = image_b(y_clip(1):y_clip(2), x_clip(1):x_clip(2));
        image_b_point(i+1,j+1) = mean(mean(data_b_in));
    end
end

rGain = zeros(side_num+1,side_num+1);
gGain = zeros(side_num+1,side_num+1);
bGain = zeros(side_num+1,side_num+1);

%% caculate lsc luma gain
for i = 1:side_num+1
    for j = 1:side_num+1
%         image_r_luma_gain_point(i,j) = mean2(image_r_point(uint8(side_num/2)-1:uint8(side_num/2)+1, uint8(side_num/2)-1:uint8(side_num/2)+1)) / image_r_point(i,j)*256;
%         image_g_luma_gain_point(i,j) = mean2(image_g_point(uint8(side_num/2)-1:uint8(side_num/2)+1, uint8(side_num/2)-1:uint8(side_num/2)+1)) / image_g_point(i,j)*256;
%         image_b_luma_gain_point(i,j) = mean2(image_b_point(uint8(side_num/2)-1:uint8(side_num/2)+1, uint8(side_num/2)-1:uint8(side_num/2)+1)) / image_b_point(i,j)*256;
        rGain(i,j) = image_r_point(uint8(side_num/2) +1, uint8(side_num/2) +1) / image_r_point(i,j);
        gGain(i,j) = image_g_point(uint8(side_num/2) +1, uint8(side_num/2) +1) / image_g_point(i,j);
        bGain(i,j) = image_b_point(uint8(side_num/2) +1, uint8(side_num/2) +1) / image_b_point(i,j);
    end
end
save('./src/rGain.mat', 'rGain');
save('./src/gGain.mat', 'gGain');
save('./src/bGain.mat', 'bGain');





