%% --------------------------------
%% author:wtzhu
%% date: 20210712
%% fuction: main file of Mesh3Correct
%% --------------------------------
clc, clear, close all;
% --------parameters of correction------------
filePath = 'images/lsc.bmp';
side_num = 16;
% --------------------------------------------

% --------load data---------------------------
% load org image
image = imread(filePath);
[height, width, channel] = size(image);
sideX = floor(height/side_num);
sideY = floor(width/side_num);

image_r = image(:,:,1);
image_g = image(:,:,2);
image_b = image(:,:,3);

% load gain of each channel
load('./src/data/rGain.mat');
load('./src/data/gGain.mat');
load('./src/data/bGain.mat');
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
        % get tht gain of the point by interpolation(Bilinear interpolation)
        % f(x,y) = [f(1,0)-f(0,0)]*x+[f(0,1)-f(0,0)]*y+[f(1,1)+f(0,0)-f(1,0)-f(0,1)]*xy+f(0,0)
        rGainTmp = (rGain(gainStepX+1, gainStepY) - rGain(gainStepX, gainStepY)) * (i - (gainStepX - 1) * sideX)/sideX +...
                         (rGain(gainStepX, gainStepY+1) - rGain(gainStepX, gainStepY)) * (j - (gainStepY - 1) * sideY)/sideY +...
                         (rGain(gainStepX+1, gainStepY+1) + rGain(gainStepX, gainStepY) - rGain(gainStepX+1, gainStepY)- rGain(gainStepX, gainStepY + 1)) *...
                         (i - (gainStepX - 1) * sideX)/sideX * (j - (gainStepY - 1) * sideY)/sideY + rGain(gainStepX, gainStepY);
                     
        gGainTmp = (gGain(gainStepX+1, gainStepY) - gGain(gainStepX, gainStepY)) * (i - (gainStepX - 1) * sideX)/sideX +...
                         (gGain(gainStepX, gainStepY+1) - gGain(gainStepX, gainStepY)) * (j - (gainStepY - 1) * sideY)/sideY +...
                         (gGain(gainStepX+1, gainStepY+1) + gGain(gainStepX, gainStepY) - gGain(gainStepX+1, gainStepY)- gGain(gainStepX, gainStepY + 1)) *...
                         (i - (gainStepX - 1) * sideX)/sideX * (j - (gainStepY - 1) * sideY)/sideY + gGain(gainStepX, gainStepY);
                     
        bGainTmp = (bGain(gainStepX+1, gainStepY) - bGain(gainStepX, gainStepY)) * (i - (gainStepX - 1) * sideX)/sideX +...
                         (bGain(gainStepX, gainStepY+1) - bGain(gainStepX, gainStepY)) * (j - (gainStepY - 1) * sideY)/sideY +...
                         (bGain(gainStepX+1, gainStepY+1) + bGain(gainStepX, gainStepY) - bGain(gainStepX+1, gainStepY)- rGain(gainStepX, gainStepY + 1)) *...
                         (i - (gainStepX - 1) * sideX)/sideX * (j - (gainStepY - 1) * sideY)/sideY + bGain(gainStepX, gainStepY);
        
        disImg(i,j,1) = double(image_r(i, j)) * rGainTmp;
        disImg(i,j,2) = double(image_g(i, j)) * gGainTmp;
        disImg(i,j,3) = double(image_b(i, j)) * bGainTmp;
    end
end

figure();
subplot(121);imshow(image);title('org image');
subplot(122);imshow(uint8(disImg));title('corrected image');


        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
