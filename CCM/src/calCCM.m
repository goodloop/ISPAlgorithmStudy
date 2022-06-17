%% --------------------------------
%% author:Fred
%% date: 20220617
%% fuction: 
%% note:
%% --------------------------------
clc;
close all;
clear;

%% ---------load data--------------
targetRGB = load('targetRGB.mat');
targetRGB = reshape(targetRGB.ROI_mean_value, [], 3);
cameraRGB = load('cameraRGB.mat');
cameraRGB = reshape(cameraRGB.ROI_mean_value, [], 3);

targetLAB = rgb2lab(targetRGB);
