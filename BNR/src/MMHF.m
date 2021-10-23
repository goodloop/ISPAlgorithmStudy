%% --------------------------------
%% author:wtzhu
%% email:wtzhu_13@163.com
%% date: 20212023
%% fuction: multistage median hybird filters
%% --------------------------------

close all;
clear all;
clc
img = imread('./images/lena.bmp');
I = double(img);
figure();
imshow(uint8(I));
title('org file');

I_noise = I + 10 * randn(size(I));
figure();
imshow(uint8(I_noise));
title('noise file');
[m,n] = size(I_noise);

DenoisedImg = zeros(m,n);
PaddedImg = padarray(I,[1, 1],'symmetric','both');

tic
for i = 1: m
    for j = 1: n
        roi = PaddedImg(i:i+2, j:j+2);
        % first stage: average and median
        mean_V = mean(roi(:,2));
        mean_H = mean(roi(2,:));
        median_HV = median([mean_V, roi(2, 2)], mean_H);
        
        mean45 = mean([roi(1, 3), roi(2, 2), roi(3, 1)]);
        mean135 = mean([roi(1, 1), roi(2, 2), roi(3, 3)]);
        median_diag = median([mean45, roi(2, 2)], mean135);
        
        % second stage
        DenoisedImg(i, j) = median([median_HV, roi(2,2), median_diag]);
    end
end
figure();
imshow(uint8(DenoisedImg));
title('denoise file');
toc

b=medfilt2(I_noise,[3,3]);
figure();
imshow(uint8(b));
title('median denoise file');










