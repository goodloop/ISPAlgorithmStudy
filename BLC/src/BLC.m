%% --------------------------------
%% author:wtzhu
%% date: 20210629
%% fuction: main file of BLC
%% --------------------------------
clc;clear;close all;

% ------------Raw Format----------------
filePath = 'images/HisiRAW_4208x3120_8bits_RGGB.raw';
bayerFormat = 'RGGB';
row = 4208;
col = 3120;
bits = 8;
% --------------------------------------

%  I(1:2:end, 1:2:end) = R(1:1:end, 1:1:end);

data = readRaw(filePath, bits, row, col);
% get the four channels by bayerFormat
switch bayerFormat
    case 'RGGB'
        disp('bayerFormat: RGGB');
        R = data(1:2:end, 1:2:end);
        Gr = data(1:2:end, 2:2:end);
        Gb = data(2:2:end, 1:2:end);
        B = data(2:2:end, 2:2:end);
    case 'GRBG'
        disp('bayerFormat: GRBG');
        Gr = data(1:2:end, 1:2:end);
        R = data(1:2:end, 2:2:end);
        B = data(2:2:end, 1:2:end);
        Gb = data(2:2:end, 2:2:end);
    case 'GBRG'
        disp('bayerFormat: GBRG');
        Gb = data(1:2:end, 1:2:end);
        B = data(1:2:end, 2:2:end);
        R = data(2:2:end, 1:2:end);
        Gr = data(2:2:end, 2:2:end);
    case 'BGGR'
        disp('bayerFormat: BGGR');
        B = data(1:2:end, 1:2:end);
        Gb = data(1:2:end, 2:2:end);
        Gr = data(2:2:end, 1:2:end);
        R = data(2:2:end, 2:2:end);
end
% calculate the Correction coefficient of every channel
R_mean = round(mean(mean(R)));
Gr_mean = round(mean(mean(Gr)));
Gb_mean = round(mean(mean(Gb)));
B_mean = round(mean(mean(B)));

% Correct each channel separately
cR = R-R_mean;
cGr = Gr-Gr_mean;
cGb = Gb-Gb_mean;
cB = B-B_mean;
fprintf('R:%d Gr:%d Gb:%d B:%d\n', R_mean, Gr_mean, Gb_mean, B_mean);

cData = zeros(size(data));
% Restore the image with four channels
switch bayerFormat
    case 'RGGB'
        disp('bayerFormat: RGGB');
        cData(1:2:end, 1:2:end) = cR(1:1:end, 1:1:end);
        cData(1:2:end, 2:2:end) = cGr(1:1:end, 1:1:end);
        cData(2:2:end, 1:2:end) = cGb(1:1:end, 1:1:end);
        cData(2:2:end, 2:2:end) = cB(1:1:end, 1:1:end);
    case 'GRBG'
        disp('bayerFormat: GRBG');
        cData(1:2:end, 1:2:end) = cGr(1:1:end, 1:1:end);
        cData(1:2:end, 2:2:end) = cR(1:1:end, 1:1:end);
        cData(2:2:end, 1:2:end) = cB(1:1:end, 1:1:end);
        data(2:2:end, 2:2:end) = cGb(1:1:end, 1:1:end);
    case 'GBRG'
        disp('bayerFormat: GBRG');
        cData(1:2:end, 1:2:end) = cGb(1:1:end, 1:1:end);
        cData(1:2:end, 2:2:end) = cB(1:1:end, 1:1:end);
        cData(2:2:end, 1:2:end) = cR(1:1:end, 1:1:end);
        cData(2:2:end, 2:2:end) = cGr(1:1:end, 1:1:end);
    case 'BGGR'
        disp('bayerFormat: BGGR');
        cData(1:2:end, 1:2:end) = cB(1:1:end, 1:1:end);
        cData(1:2:end, 2:2:end) = cGb(1:1:end, 1:1:end);
        cData(2:2:end, 1:2:end) = cGr(1:1:end, 1:1:end);
        cData(2:2:end, 2:2:end) = cR(1:1:end, 1:1:end);
end
show(data, cData, bits, Gr_mean);

