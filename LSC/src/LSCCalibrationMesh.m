%% --------------------------------
%% author:wtzhu
%% date: 20210706
%% fuction: main file of LSCCalibrationMesh
%% --------------------------------
clc;clear;close all;

% --------parameters of calibretion------------
filePath = 'images/lscRefImg.jpg';
side_num = 17;
meshON = 1;
% ---------------------------------------------

image = imread(filePath);
[height, width] = size(image);
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
        data_in = image(y_clip(1):y_clip(2), x_clip(1):x_clip(2));
        image_point(i+1,j+1) = mean(mean(data_in));
    end
end

Gain = zeros(side_num+1,side_num+1);

%% caculate lsc luma gain
for i = 1:side_num+1
    for j = 1:side_num+1
        Gain(i,j) = image_point(uint8(side_num/2) +1, uint8(side_num/2) +1) / image_point(i,j);
    end
end
save('./src/data/Gain.mat', 'Gain');







