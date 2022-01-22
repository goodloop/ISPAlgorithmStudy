%% --------------------------------
%% author:wtzhu
%% date: 20220122
%% fuction: The code of reference
%% note: 
%% reference: "Directionally weighted color interpolation for digital cameras"
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
addpath('../publicFunction');
bayerPadding = expandRaw(bayerData, 4);

%% main code of imterpolation
imDst = zeros(height+8, width+8, 3);
for ver = 5: height + 4
    for hor = 5: width +4
        fprintf('%d %d\n', ver, hor);
        % R channal
        if(1 == mod(ver, 2) && 1 == mod(hor, 2))
            disp('deal with R');
            neighborhoodData = bayerPadding(ver-4: ver+4, hor-4: hor+4);
            [G, B] = DW_GB2R(neighborhoodData);
        % B channal
        elseif (0 == mod(ver, 2) && 0 == mod(hor, 2))
            disp('deal with B')
        % Gr
        elseif (1 == mod(ver, 2) && 0 == mod(hor, 2))
            disp('deal with Gr')
        % Gb
        elseif (0 == mod(ver, 2) && 1 == mod(hor, 2))
            disp('deal with Gb')
        end
      
    end
end



