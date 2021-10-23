%% --------------------------------
%% author:wtzhu
%% email:wtzhu_13@163.com
%% date: 20211023
%% fuction: median rational hybird file filter
%% references: MEDIAN-RATIONAL HYBRID FILTERS
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
h = 2;
k = 0.01;

tic
for i = 1: m
    for j = 1: n
        roi = PaddedImg(i:i+2, j:j+2);
        median_HV = median([roi(1,2), roi(2,1), roi(2,2), roi(2,3), roi(3,2)]);
        median_diag = median([roi(1,1), roi(1,3), roi(2,2), roi(3,1), roi(3,3)]);
        CWMF = median([roi(1,2), roi(2,1), roi(2,2)*3, roi(2,3), roi(3,2)]);
        
        DenoisedImg(i, j) = CWMF + (median_HV + median_diag - 2 * CWMF) / (h + k * (median_HV - median_diag));
    end
end
toc
figure();
imshow(uint8(DenoisedImg));
title('denoise file');
b = medfilt2(I_noise,[3,3]);
figure();
imshow(uint8(b));
title('median filter of matlab denoise file');


