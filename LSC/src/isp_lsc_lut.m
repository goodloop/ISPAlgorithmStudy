function [image_r_gain, image_gr_gain, image_gb_gain, image_b_gain] = ...
isp_lsc_lut(image_r, image_gr, image_gb, image_b, side_num)
[height, width] = size(image_r);
side_y = floor(height/side_num);
side_x = floor(width/side_num);

% figure,imshow(image_r);
% hold on;
% for k=0:side_num
%     line_x = side_x * k;
%     line_y = side_y * k;
%     if(k==side_num && line_y ~= width) line_y = height;end
%     if(k==side_num && line_x ~= width) line_x = width;end
%     line([line_x,line_x],[0,height],'Color','red');
%     line([0,width], [line_y, line_y],'Color','red');
% %     line(Xd,Yd,'Color','red');
% end
% hold off

%% compress resolution
image_point = zeros(side_num,side_num);
for i = 0:side_num
    for j = 0:side_num
        x_clip = floor([j*side_x - side_x/2, j*side_x + side_x/2]);
        y_clip = floor([i*side_y - side_y/2, i*side_y + side_y/2]);
        if(i==side_num && y_clip(2) ~= height) y_clip(2) = height;end
        if(j==side_num && x_clip(2) ~= width) x_clip(2) = width;end
        x_clip(x_clip<1) = 1;x_clip(x_clip>width) = width;
        y_clip(y_clip<1) = 1;y_clip(y_clip>height) = height;
        data_r_in = image_r(y_clip(1):y_clip(2), x_clip(1):x_clip(2));
        image_r_point(i+1,j+1) = mean(mean(data_r_in));
        data_gr_in = image_gr(y_clip(1):y_clip(2), x_clip(1):x_clip(2));
        image_gr_point(i+1,j+1) = mean(mean(data_gr_in));
        data_gb_in = image_gb(y_clip(1):y_clip(2), x_clip(1):x_clip(2));
        image_gb_point(i+1,j+1) = mean(mean(data_gb_in));
        data_b_in = image_b(y_clip(1):y_clip(2), x_clip(1):x_clip(2));
        image_b_point(i+1,j+1) = mean(mean(data_b_in));
    end
end

% figure,imshow(uint8(image_r_point));
%% caculate lsc luma gain
for i = 1:side_num+1
    for j = 1:side_num+1
        image_r_luma_gain_point(i,j) = mean2(image_r_point(uint8(side_num/2)-1:uint8(side_num/2)+1, uint8(side_num/2)-1:uint8(side_num/2)+1)) / image_r_point(i,j);
        image_gr_luma_gain_point(i,j) = mean2(image_gr_point(uint8(side_num/2)-1:uint8(side_num/2)+1, uint8(side_num/2)-1:uint8(side_num/2)+1)) / image_gr_point(i,j);
        image_gb_luma_gain_point(i,j) = mean2(image_gb_point(uint8(side_num/2)-1:uint8(side_num/2)+1, uint8(side_num/2)-1:uint8(side_num/2)+1)) / image_gb_point(i,j);
        image_b_luma_gain_point(i,j) = mean2(image_b_point(uint8(side_num/2)-1:uint8(side_num/2)+1, uint8(side_num/2)-1:uint8(side_num/2)+1)) / image_b_point(i,j);
    end
end
