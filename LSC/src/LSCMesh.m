%% --------------------------------
%% author:wtzhu
%% date: 20210706
%% fuction: main file of LSCMesh
%% --------------------------------
clc, clear, close all;
% --------parameters of correction------------
filePath = 'images/lscRefImg.jpg';
side_num = 17;
% --------------------------------------------

% --------load data---------------------------
% load org image
image = imread(filePath);
[height, width] = size(image);
sideX = floor(height/side_num);
sideY = floor(width/side_num);

% load gain of each channel
load('./src/data/Gain.mat');

% --------------correction-------------------
disImg = zeros(size(image));
gainStepX = 0;
gainStepY = 0;
gainTab = zeros(size(image));
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
        gainTab(i, j) = (Gain(gainStepX+1, gainStepY) - Gain(gainStepX, gainStepY)) * (i - (gainStepX - 1) * sideX)/sideX +...
                        (Gain(gainStepX, gainStepY+1) - Gain(gainStepX, gainStepY)) * (j - (gainStepY - 1) * sideY)/sideY +...
                        (Gain(gainStepX+1, gainStepY+1) + Gain(gainStepX, gainStepY) - Gain(gainStepX+1, gainStepY)- Gain(gainStepX, gainStepY + 1)) *...
                        (i - (gainStepX - 1) * sideX)/sideX * (j - (gainStepY - 1) * sideY)/sideY + Gain(gainStepX, gainStepY);
    end
end
disImg = double(image) .* gainTab;

figure();
subplot(121);imshow(image);title('org image');
subplot(122);imshow(uint8(disImg));title('corrected image');


        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
