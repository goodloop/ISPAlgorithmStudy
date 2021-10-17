%% --------------------------------
%% author:wtzhu
%% email:wtzhu_13@163.com
%% date: 20211012
%% fuction: Non-Local Means
%% --------------------------------
close all;
clear all;
clc
img = imread('./images/lena.bmp');
I = double(img);
% I = double(imresize(img, [64, 64]));
figure();
imshow(uint8(I));
I_noise = I + 10 * randn(size(I));
figure();
imshow(uint8(I_noise));

% -----------------------------------
ds = 2;
Ds = 5;
h = 10;
% -----------------------------------

[m,n] = size(I_noise);
DenoisedImg = zeros(m,n);
PaddedImg = padarray(I,[ds+Ds,ds+Ds],'symmetric','both');

kernel = ones(2*ds+1,2*ds+1);
kernel = kernel./((2*ds+1)*(2*ds+1));
h2=h*h;

tic
for i=1:m
    for j=1:n
        num = 0;
        i1=i+ds+Ds;
        j1=j+ds+Ds;
        W1=PaddedImg(i1-ds:i1+ds,j1-ds:j1+ds);  % current window
        fprintf('=======current point: (%d, %d)\n', i, j);
        wmax=0;
        average=0;
        sweight=0;
        
        % search window
        % This window is not a fixed size, 
        % it shrinks when it's in the corner or border
        swmin = i1 - Ds;
        swmax = i1 + Ds;
        shmin = j1 - Ds;
        shmax = j1 + Ds;
        
        for r = swmin: swmax
            for s = shmin: shmax
                if(r==i1 && s==j1)
                    continue;
                end
                W2 = PaddedImg(r-ds:r+ds,s-ds:s+ds); % the window is to be compared with current window
                num = num + 1;
                % Use the mean directly in order to simplify the calculate
                Dist2 = sum(sum(kernel.*(W1-W2).*(W1-W2)));	
                w = exp(-Dist2/h2);   % the weight of the compared window
                if(w > wmax)
                    wmax = w;
                end
                sweight = sweight + w;  % sum the weight to normalize
                average = average + w*PaddedImg(r,s);
            end
        end
        fprintf('num of win: %d\n', num);
        average = average + wmax*PaddedImg(i1,j1);
        sweight = sweight+wmax;
        DenoisedImg(i,j) = average/sweight;
    end
end
figure();
imshow(uint8(DenoisedImg));
toc
