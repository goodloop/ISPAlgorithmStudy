%% --------------------------------
%% author:wtzhu
%% date: 20210629
%% fuction: main file of BLC
%% --------------------------------
clc;clear;close all;

% ------------Raw Format----------------
bayerFormat = 'RGGB';
row = 3840;
col = 2160;
bits = 8;
% --------------------------------------

data = readRaw('BLC_8bits.raw', bits, row, col);
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
R_mean = uint8(mean(mean(R)));
Gr_mean = uint8(mean(mean(Gr)));
Gb_mean = uint8(mean(mean(Gb)));
B_mean = uint8(mean(mean(B)));
fprintf('R:%d Gr:%d Gb:%d B:%d\n', R_mean, Gr_mean, Gb_mean, B_mean);
