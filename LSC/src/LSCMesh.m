%% --------------------------------
%% author:wtzhu
%% date: 20210706
%% fuction: main file of LSCMesh
%% --------------------------------
clc, clear, close all;
% --------parameters of correction------------
filePath = 'images/lsc.bmp';
side_num = 16;
% --------------------------------------------

% --------load data---------------------------
% load org image
image = imread(filePath);
[height, width, chan] = size(image);
sideX = floor(height/side_num);
sideY = floor(width/side_num);
figure();
imshow(image);
title('org image');
image_r = image(:,:,1);
image_g = image(:,:,2);
image_b = image(:,:,3);

% load gain of each channel
load('./src/rGain.mat');
load('./src/gGain.mat');
load('./src/bGain.mat');

% --------------correction-------------------
disImg = zeros(size(image));
gainStepX = 0;
gainStepY = 0;
for i = 1:height
    for j = 1:width
        gainStepX = floor(i / sideX) + 1;
        if gainStepX > 16
            gainStepX = 16;
        end
        gainStepY = floor(j / sideY) + 1;
        if gainStepY > 16
            gainStepY = 16;
        end
        % get tht gain of the point by interpolation
        % 插值算法还有待改进
        rGainP = rGain(gainStepX, gainStepY) * (j - (gainStepY-1) * sideY) / sideY +...
                 rGain(gainStepX, gainStepY + 1) * (gainStepY * sideY - j) / sideY;
        gGainP = gGain(gainStepX, gainStepY) * (j - (gainStepY-1) * sideY) / sideY +...
                 gGain(gainStepX, gainStepY + 1) * (gainStepY * sideY - j) / sideY;
        bGainP = bGain(gainStepX, gainStepY) * (j - (gainStepY-1) * sideY) / sideY +...
                 bGain(gainStepX, gainStepY + 1) * (gainStepY * sideY - j) / sideY;
        disImg(i, j, 1) =  image_r(i, j) * rGainP;
        disImg(i, j, 2) =  image_g(i, j) * gGainP;
        disImg(i, j, 3) =  image_b(i, j) * bGainP;
    end
end
disImg = uint8(disImg);
figure();
imshow(disImg);
title('dis image')
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
