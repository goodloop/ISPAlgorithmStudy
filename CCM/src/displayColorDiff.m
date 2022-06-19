%% --------------------------------
%% author:Fred
%% date: 20220619
%% fuction: 
%% note:
%% --------------------------------
clc;
close all;
clear;

I = imread('./images/Colorchecker.jpg');
imshow(I);

display('please draw ROI of balck point');
blackPoint = drawpoint;
display('please draw ROI of white point');
whitePoint = drawpoint;
display('please draw ROI of dark skin point');
darkSkinPoint = drawpoint;
display('please draw ROI of bluish green point');
bluishGreenPoint = drawpoint;

cornerPoints = [blackPoint.Position;
    whitePoint.Position;
    darkSkinPoint.Position;
    bluishGreenPoint.Position];
chart = colorChecker(I, 'RegistrationPoints', cornerPoints);
displayChart(chart);
colorTable = measureColor(chart);
figure
plotChromaticity(colorTable);








