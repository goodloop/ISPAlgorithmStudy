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
figure();
imshow(image_r);

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
%         if (i / sideX)-floor(i / sideX)<0.5
            rGainP1 = rGain(gainStepX, gainStepY) * (gainStepY * sideY - j) / sideY   +...
                     rGain(gainStepX+1, gainStepY + 1) *(j - (gainStepY-1) * sideY) / sideY;
            rGainP2 = rGain(gainStepX, gainStepY+1) * (gainStepY * sideY - j) / sideY   +...
                     rGain(gainStepX+1, gainStepY) *(j - (gainStepY-1) * sideY) / sideY;
            rGainP = (rGainP1 + rGainP2)/2;
            
            gGainP1 = gGain(gainStepX, gainStepY) * (gainStepY * sideY - j) / sideY   +...
                     gGain(gainStepX+1, gainStepY + 1) *(j - (gainStepY-1) * sideY) / sideY;
            gGainP2 = gGain(gainStepX, gainStepY+1) * (gainStepY * sideY - j) / sideY   +...
                     gGain(gainStepX+1, gainStepY) *(j - (gainStepY-1) * sideY) / sideY;
            gGainP = (gGainP1 + gGainP2)/2;
            
            bGainP1 = bGain(gainStepX, gainStepY) * (gainStepY * sideY - j) / sideY   +...
                     bGain(gainStepX+1, gainStepY + 1) *(j - (gainStepY-1) * sideY) / sideY;
            bGainP2 = bGain(gainStepX, gainStepY+1) * (gainStepY * sideY - j) / sideY   +...
                     bGain(gainStepX+1, gainStepY) *(j - (gainStepY-1) * sideY) / sideY;
            bGainP = (bGainP1 + bGainP2)/2;
            
%         else
%            rGainP = rGain(gainStepX+1, gainStepY) * (gainStepY * sideY - j) / sideY   +...
%                      rGain(gainStepX+1, gainStepY + 1) *(j - (gainStepY-1) * sideY) / sideY;
%             gGainP = gGain(gainStepX+1, gainStepY) * (gainStepY * sideY - j) / sideY   +...
%                      gGain(gainStepX+1, gainStepY + 1) *(j - (gainStepY-1) * sideY) / sideY;
%             bGainP = bGain(gainStepX+1, gainStepY) * (gainStepY * sideY - j) / sideY   +...
%                      bGain(gainStepX+1, gainStepY + 1) *(j - (gainStepY-1) * sideY) / sideY; 
%         end

%         rGainP = (rGain(gainStepX, gainStepY+1)-rGain(gainStepX, gainStepY)) * (gainStepY * sideY - j) + ...
%                  (rGain(gainStepX+1, gainStepY)-rGain(gainStepX, gainStepY)) * (gainStepX * sideX - i)  + ...
%                  (rGain(gainStepX+1, gainStepY+1)+rGain(gainStepX, gainStepY)-rGain(gainStepX, gainStepY+1)-rGain(gainStepX+1, gainStepY)) * ...
%                  (gainStepY * sideY - j) * (gainStepX * sideX - i) + rGain(gainStepX, gainStepY);
%         gGainP = (gGain(gainStepX, gainStepY+1)-gGain(gainStepX, gainStepY)) * (gainStepY * sideY - j) + ...
%                  (gGain(gainStepX+1, gainStepY)-gGain(gainStepX, gainStepY)) * (gainStepX * sideX - i) + ...
%                  (gGain(gainStepX+1, gainStepY+1)+gGain(gainStepX, gainStepY)-gGain(gainStepX, gainStepY+1)-gGain(gainStepX+1, gainStepY)) * ...
%                  (gainStepY * sideY - j) * (gainStepX * sideX - i) + gGain(gainStepX, gainStepY);
%         bGainP = (bGain(gainStepX, gainStepY+1)-bGain(gainStepX, gainStepY)) * (gainStepY * sideY - j) + ...
%                  (bGain(gainStepX+1, gainStepY)-bGain(gainStepX, gainStepY)) * (gainStepX * sideX - i) + ...
%                  (bGain(gainStepX+1, gainStepY+1)+bGain(gainStepX, gainStepY)-bGain(gainStepX, gainStepY+1)-bGain(gainStepX+1, gainStepY)) * ...
%                  (gainStepY * sideY - j) * (gainStepX * sideX - i) + bGain(gainStepX, gainStepY);
        

        disImg(i, j, 1) =  image_r(i, j) * rGainP;    
        disImg(i, j, 2) =  image_g(i, j) * gGainP;
        disImg(i, j, 3) =  image_b(i, j) * bGainP;
    end
end

figure();
imshow(uint8(disImg));
title('dis image')
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
