%% --------------------------------
%% author:wtzhu
%% date: 20210629
%% fuction: main file of BLC
%% --------------------------------
clc;clear;close all;
bayerFormat = 'RGGB';
row = 3840;
col = 2160;
data = readRaw('BLC_8bits.raw', 8, 3840, 2160);
R = data(1:2:end, 1:2:end);
Gr = data(1:2:end, 2:2:end);
Gb = data(2:2:end, 1:2:end);
B = data(2:2:end, 2:2:end);
