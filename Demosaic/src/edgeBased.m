%% --------------------------------
%% author:wtzhu
%% date: 20220122
%% fuction: The code of reference
%% note: 
%% reference: "An Efficient Edge-Based Technique for Color Filter Array Demosaicking"
%% --------------------------------
clc;clear;close all;

%% ------------Raw Format----------------
filePath = 'images/kodim19_8bits_RGGB.raw';
bayerFormat = 'RGGB';
width = 512;
height= 768;
bits = 8;
%% --------------------------------------
bayerData = readRaw(filePath, bits, width, height);
figure();
imshow(bayerData);
title('raw image');

%% expand image inorder to make it easy to calculate edge pixels
bayerPadding = zeros(height + 2,width+2);
bayerPadding(2:height+1,2:width+1) = uint32(bayerData);
bayerPadding(1,:) = bayerPadding(3,:);
bayerPadding(height+2,:) = bayerPadding(height,:);
bayerPadding(:,1) = bayerPadding(:,3);
bayerPadding(:,width+2) = bayerPadding(:,width);

%% main code of imterpolation
imDst = zeros(height+2, width+2, 3);


