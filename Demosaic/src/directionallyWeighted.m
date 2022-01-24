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

%% ------------Global Value--------------
RC = 1;
GC = 2;
BC = 3;

%% --------------------------------------
orgImg = imread('images/kodim19.png');
figure();imshow(orgImg);title('org image');

bayerData = readRaw(filePath, bits, width, height);
figure();
imshow(bayerData);
title('raw image');

%% expand image inorder to make it easy to calculate edge pixels
addpath('../publicFunction');
bayerPadding = expandRaw(bayerData, 4);

imDst = zeros(height+8, width+8, 3);

%% Interpolate the missing green value of blue/red samples
for ver = 5: height + 4
    for hor = 5: width +4
        % R channal
        if(1 == mod(ver, 2) && 1 == mod(hor, 2))
            imDst(ver, hor, 1) = bayerPadding(ver, hor);
            neighborhoodData = bayerPadding(ver-4: ver+4, hor-4: hor+4);
            Wn = DW_Wn(neighborhoodData, 12);
            Kn = DW_Kn(neighborhoodData, 12);
            imDst(ver, hor, 2) = bayerPadding(ver, hor) + sum(Wn .* Kn);
        % B channal
        elseif (0 == mod(ver, 2) && 0 == mod(hor, 2))
            imDst(ver, hor, 3) = bayerPadding(ver, hor);
            neighborhoodData = bayerPadding(ver-4: ver+4, hor-4: hor+4);
            Wn = DW_Wn(neighborhoodData, 12);
            Kn = DW_Kn(neighborhoodData, 12);
            imDst(ver, hor, 2) = bayerPadding(ver, hor) + sum(Wn .* Kn);
        % Gr
        elseif (1 == mod(ver, 2) && 0 == mod(hor, 2))
            imDst(ver, hor, 2) = bayerPadding(ver, hor);
        % Gb
        elseif (0 == mod(ver, 2) && 1 == mod(hor, 2))
            imDst(ver, hor, 2) = bayerPadding(ver, hor);
        end
    end
end

% expand the imDst
imDst(:, 1: 4, :) = imDst(:, 5: 8, :);
imDst(:, width+5: width+8, :) = imDst(:, width+1: width+4, :);
imDst(1:4, : , :) = imDst(5: 8, :, :);
imDst(height+5: height+8, : , :) = imDst(height+1: height+4, :, :);

%% Interpolate the missing red/blue values of blue/red samples.
for ver = 5: height + 4
    for hor = 5: width +4
        % R channal
        if(1 == mod(ver, 2) && 1 == mod(hor, 2))
            neighborRaw = bayerPadding(ver-4: ver+4, hor-4: hor+4);
            Wn = DW_Wn(neighborRaw, 4);
            neighborhoodData = imDst(ver-4: ver+4, hor-4: hor+4, :);
            Kn = DW_Kn(neighborhoodData, 4, BC);
            imDst(ver, hor, 3) = imDst(ver, hor, 2) - sum(Wn .* Kn);
        % B channal
        elseif (0 == mod(ver, 2) && 0 == mod(hor, 2))
            neighborRaw = bayerPadding(ver-4: ver+4, hor-4: hor+4);
            Wn = DW_Wn(neighborRaw, 4);
            neighborhoodData = imDst(ver-4: ver+4, hor-4: hor+4, :);
            Kn = DW_Kn(neighborhoodData, 4, RC);
            imDst(ver, hor, 1) = imDst(ver, hor, 2) - sum(Wn .* Kn);
        else
            continue
        end
    end
end
% expand the imDst
imDst(:, 1: 4, :) = imDst(:, 5: 8, :);
imDst(:, width+5: width+8, :) = imDst(:, width+1: width+4, :);
imDst(1:4, : , :) = imDst(5: 8, :, :);
imDst(height+5: height+8, : , :) = imDst(height+1: height+4, :, :);

%% Interpolate missing red/blue values of green samples.
for ver = 5: height + 4
    for hor = 5: width +4
        neighborhoodData = imDst(ver-4: ver+4, hor-4: hor+4, :);
        % R channal
        if(1 == mod(ver, 2) && 1 == mod(hor, 2))
            continue
        % B channal
        elseif (0 == mod(ver, 2) && 0 == mod(hor, 2))
            continue
        % G
        else
            Wrn = DW_Wn(neighborhoodData, 12, GC, RC);
            Wbn = DW_Wn(neighborhoodData, 12, GC, BC);
            Krn = DW_Kn(neighborhoodData, 12, RC);
            Kbn = DW_Kn(neighborhoodData, 12, BC);
            imDst(ver, hor, 1) = imDst(ver, hor, 2) - sum(Wrn .* Krn);
            imDst(ver, hor, 3) = imDst(ver, hor, 2) - sum(Wbn .* Kbn);
        end
    end
end
% expand the imDst
imDst(:, 1: 4, :) = imDst(:, 5: 8, :);
imDst(:, width+5: width+8, :) = imDst(:, width+1: width+4, :);
imDst(1:4, : , :) = imDst(5: 8, :, :);
imDst(height+5: height+8, : , :) = imDst(height+1: height+4, :, :);
figure();imshow(uint8(imDst));title('now');

%% Adjust the estimated green values of red/blue samples
for ver = 5: height + 4
    for hor = 5: width +4
        neighborhoodData = imDst(ver-4: ver+4, hor-4: hor+4, :);
        % R channal
        if(1 == mod(ver, 2) && 1 == mod(hor, 2))
            Wrn = DW_Wn(neighborhoodData, 12, RC, GC);           
            Krn = DW_Kn(neighborhoodData, 12, RC);
            imDst(ver, hor, 2) = imDst(ver, hor, 1) + sum(Wrn .* Krn);
        % B channal
        elseif (0 == mod(ver, 2) && 0 == mod(hor, 2))
            Wbn = DW_Wn(neighborhoodData, 12, BC, GC);
            Kbn = DW_Kn(neighborhoodData, 12, BC);
            imDst(ver, hor, 2) = imDst(ver, hor, 3) + sum(Wbn .* Kbn);
        % G
        else
            continue
        end
    end
end
demosaicImg = imDst(5: height + 4, 5: width +4, :);
figure();imshow(uint8(demosaicImg));title('demosaicking image');









