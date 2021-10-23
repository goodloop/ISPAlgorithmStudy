%% --------------------------------
%% author:wtzhu
%% email:wtzhu_13@163.com
%% date: 20212023
%% fuction: multistage median filters
%% --------------------------------

close all;
clear all;
clc
img = imread('./images/lena.bmp');
I = double(img);
% I = double(imresize(img, [64, 64]));
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

for i = 1: m
    for j = 1: n
        roi = PaddedImg(i:i+2, j:j+2);
        % first stage
        median_HV = median([roi(1,2), roi(2,1), roi(2,2), roi(2,3), roi(3,2)]);
        median_diag = median([roi(1,1), roi(1,3), roi(2,2), roi(3,1), roi(3,3)]);
        % second stage
        DenoisedImg(i, j) = median([median_HV, roi(2,2), median_diag]);
    end
end
figure();
imshow(uint8(DenoisedImg));
title('denoise file');












