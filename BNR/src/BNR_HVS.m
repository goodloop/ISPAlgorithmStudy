%% --------------------------------
%% author:wtzhu
%% email:wtzhu_13@163.com
%% date: 20211202
%% fuction: Based on paper titled "Noise Reduction for CFA Image Sensors
%%          Exploiting HVS Behaviour," by Angelo Bosco, Sebastiano Battiato,
%%          Arcangelo Bruna and Rosetta Rizzo
%% --------------------------------

close all;
clear all;
clc;

%% --------------parameters set---------------------------------
neighborhood_size = 5;
initial_noise_level = 30;
hvs_min = 5;
hvs_max = 10;
threshold_red_blue = 12;
BayerFormat = 'RGGB';


%% ----------------preparatory procedure------------------------
% get org image
addpath('../publicFunction');
org_img = imread('images/kodak_fence.tif');
double_img = double(org_img);
[h, w, c] = size(double_img);
figure();
imshow(org_img);
title('org image');

% rgb2raw
rggb_raw = RGB2Raw('../BNR/images/kodak_fence.tif', BayerFormat);
figure();
imshow(rggb_raw,[]);
title('raw');

% add noise to raw
noise_add = 10*randn(h, w);
noise_raw = rggb_raw + noise_add;
noise_raw(noise_raw<0) = 0;
noise_raw(noise_raw>255) = 255;
figure();
imshow(noise_raw,[]);
title('noise raw');

%% -------------Denoise-----------------------------------------
% pad raw
pixel_pad = floor(neighborhood_size / 2);
pad_raw = expandRaw(noise_raw, pixel_pad);

denoised_out = zeros(h, w);
% texture_degree_debug = zeros(h, w);

for i = pixel_pad+1: h+pixel_pad
    for j = pixel_pad+1: w+pixel_pad
        % center pixel
        center_pixel = pad_raw(i, j);
        
        % signal analyzer block
        half_max = floor(255 / 2);
        if center_pixel <= half_max
            hvs_weight = -(((hvs_max - hvs_min) * double(center_pixel)) / half_max) + hvs_max;
        else
            hvs_weight = (((center_pixel - 255) * (hvs_max - hvs_min)) / (255 - half_max)) + hvs_max;
        end
        
        % noise level estimator previous value
        if j < (2*pixel_pad + 1)
            noise_level_previous_red = initial_noise_level;
            noise_level_previous_blue = initial_noise_level;
            noise_level_previous_green = initial_noise_level;
        else
            noise_level_previous_green = noise_level_current_green;
            if mod(i, 2) ~= 0       % red
                noise_level_previous_red = noise_level_current_red;
            elseif mod(i, 2) == 0   % blue
                noise_level_previous_blue = noise_level_current_blue;
            end
        end
        
        % Processings depending on Green or Red/Blue
        
        neighborhood = [pad_raw(i - 2, j - 2), pad_raw(i - 2, j), pad_raw(i - 2, j + 2), ...
                           pad_raw(i, j - 2),                        pad_raw(i, j + 2), ...
                           pad_raw(i + 2, j - 2), pad_raw(i + 2, j), pad_raw(i + 2, j + 2)];
        d = abs(neighborhood - center_pixel);
        d_max = max(d);
        d_min = min(d);
        % Red channel
        if mod(i, 2) == 1 && mod(j, 2) == 1
           % calculate texture_threshold
           texture_threshold = hvs_weight + noise_level_previous_red;
           
           % texture degree analyzer
           if (d_max <= threshold_red_blue)
                texture_degree = 1;
           elseif ((d_max > threshold_red_blue) && (d_max <= texture_threshold))
                texture_degree = -((d_max - threshold_red_blue) / (texture_threshold - threshold_red_blue)) + 1;
           elseif (d_max > texture_threshold)
                texture_degree = 0;
           end
           
           % noise level estimator update
           noise_level_current_red = texture_degree * d_max + (1 - texture_degree) * noise_level_previous_red;
           
        % Blue channel
        elseif mod(i, 2) == 0 && mod(j, 2) == 0
            texture_threshold = hvs_weight + noise_level_previous_blue;
            % texture degree analyzer
           if (d_max <= threshold_red_blue)
                texture_degree = 1;
           elseif ((d_max > threshold_red_blue) && (d_max <= texture_threshold))
                texture_degree = -((d_max - threshold_red_blue) / (texture_threshold - threshold_red_blue)) + 1;
           elseif (d_max > texture_threshold)
                texture_degree = 0;
           end
            
           % noise level estimator update
           noise_level_current_blue = texture_degree * d_max + (1 - texture_degree) * noise_level_previous_blue; 
        % Green channel    
        else    
            texture_threshold = hvs_weight + noise_level_previous_green;
            % texture degree analyzer
            if (d_max == 0)
                texture_degree = 1;
            elseif ((d_max > 0) && (d_max <= texture_threshold))
                texture_degree = -(d_max / texture_threshold) + 1;
            elseif (d_max > texture_threshold)
                texture_degree = 0;
            end
            
            % noise level estimator update
            noise_level_current_green = texture_degree * d_max + (1 - texture_degree) * noise_level_previous_green;
            
        end
        % similarity threshold calculation
        if (texture_degree == 1)
            threshold_low = d_max;
            threshold_high = d_max;
        elseif (texture_degree == 0)
            threshold_low = d_min;
            threshold_high = (d_max + d_min) / 2;
        elseif ((texture_degree > 0) && (texture_degree < 1))
            threshold_high = (d_max + ((d_max + d_min) / 2)) / 2;
            threshold_low = (d_min + threshold_high) / 2;
        end
        
        % weight computation
        size_d = size(d);
        length_d = size_d(2);
        weight = zeros(size(d));
        pf = 0;
        for w_i = 1: length_d
            if (d(w_i) <= threshold_low)
                weight(w_i) = 1;
            elseif (d(w_i) > threshold_high)
                weight(w_i) = 0;
            elseif ((d(w_i) > threshold_low) && (d(w_i) < threshold_high))
                weight(w_i) = 1 + ((d(w_i) - threshold_low) / (threshold_low - threshold_high));
            end
            pf = pf + weight(w_i) * neighborhood(w_i)+ (1 - weight(w_i)) * center_pixel;
        end
        denoised_out(i - pixel_pad, j - pixel_pad) = pf / length_d;
    end
end
figure();imshow(uint8(denoised_out),[]);title('denoise');
figure();imshow((noise_raw-rggb_raw), []);title('noise');
figure();imshow((denoised_out-rggb_raw), []);title('noise reduced');























