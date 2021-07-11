load('./src/rGain.mat');
load('./src/gGain.mat');
load('./src/bGain.mat');
image_r_luma_gain_reshape = reshape(rGain, [], 1);
image_g_luma_gain_reshape = reshape(gGain, [], 1);
image_b_luma_gain_reshape = reshape(bGain, [], 1);
x = zeros(17, 17);
y = zeros(17, 17);
for i = 1:17
    for j = 1:17
        x((i-1)*17+j) = i;
        y((i-1)*17+j) = j;
    end
end
x=x';
y=y';
% scatter3(x,y,image_r_luma_gain_reshape)
% hold on
Z=[ones(length(x),1),x,y,x.^2,x.*y,y.^2,x.^3,x.^2.*y,x.*y.^2,y.^3];
[x, y]=meshgrid(1:17,1:17);
A=Z\image_r_luma_gain_reshape;
image_r_luma_gain=A(1)+A(2)*x+A(3)*y+A(4)*x.^2+A(5)*x.*y+A(6)*y.^2+A(7)*x.^3+A(8)*x.^2.*y+A(9)*x.*y.^2+A(10)*y.^3;
A=Z\image_g_luma_gain_reshape;
image_g_luma_gain=A(1)+A(2)*x+A(3)*y+A(4)*x.^2+A(5)*x.*y+A(6)*y.^2+A(7)*x.^3+A(8)*x.^2.*y+A(9)*x.*y.^2+A(10)*y.^3;
A=Z\image_b_luma_gain_reshape;
image_b_luma_gain=A(1)+A(2)*x+A(3)*y+A(4)*x.^2+A(5)*x.*y+A(6)*y.^2+A(7)*x.^3+A(8)*x.^2.*y+A(9)*x.*y.^2+A(10)*y.^3;
% surf(x,y,image_r_luma_gain)
% hold on 
% surf(x,y,image_r_luma_gain_point)


%% calulate lsc chroma gain
for i = 1:side_num+1
    for j = 1:side_num+1
        image_r_chroma_gain(i,j) = image_r_luma_gain(i,j) - image_r_luma_gain_point(i,j);
        image_g_chroma_gain(i,j) = image_g_luma_gain(i,j) - image_gr_luma_gain_point(i,j);
        image_b_chroma_gain(i,j) = image_b_luma_gain(i,j) - image_b_luma_gain_point(i,j);
    end
end
%% caculate lsc result gain
image_r_gain = image_r_luma_gain - image_r_chroma_gain;
image_gr_gain = image_gr_luma_gain - image_gr_chroma_gain;
image_gb_gain = image_gb_luma_gain - image_gb_chroma_gain;
image_b_gain = image_b_luma_gain - image_b_chroma_gain;



function image_gain_lut = lsc_data_gain_interpolation(image_gain, height, width, side_num)
side_y_ori = floor(height/side_num);
side_x_ori = floor(width/side_num);
k = 0;
l = 0;
[gain_height, gain_width] = size(image_gain);
for i = 1:gain_height-1
    for j = 1:gain_width-1
        data_gain_11 = image_gain(i, j);
        data_gain_12 = image_gain(i, j+1);
        data_gain_21 = image_gain(i+1, j);
        data_gain_22 = image_gain(i+1, j+1);
        if(j == gain_width-1 && ((j-1)*side_x + l) ~= width) 
            side_x = width - (j-1)*side_x_ori;
        else
            side_x = side_x_ori;
        end

        if(i == gain_width-1 && ((i-1)*side_y + k) ~= width)
            side_y = height - (i-1)*side_y_ori;
        else
            side_y = side_y_ori;
        end

        for k = 1:side_y
            for l = 1:side_x
                label_y1 = 1;
                label_x1 = 1;
                label_y2 = side_y;
                label_x2 = side_x;
                image_gain_lut((i-1)*side_y_ori + k, (j-1)*side_x_ori + l) = ...
                    data_gain_22/(label_x2-label_x1)/(label_y2-label_y1)* ...
                    (l - label_x1) * (k - label_y1) + ...
                    data_gain_21/(label_x2-label_x1)/(label_y2-label_y1)* ...
                    (label_x2 - l) * (k - label_y1) + ...
                    data_gain_12/(label_x2-label_x1)/(label_y2-label_y1)* ...
                    (l - label_x1) * (label_y2 - k) + ...
                    data_gain_11/(label_x2-label_x1)/(label_y2-label_y1)* ...
                    (label_x2 - l) * (label_y2 - k);
            end
        end

    end
end
end
