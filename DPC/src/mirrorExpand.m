function imgExpand = mirrorExpand(img, expandNum)
% mirrorExpand.m     expanding the image by mirror the edge og image
%   Input:
%       img            the org image 
%       expandNmm      the number of cols and rows to be expanded
%   Output:
%       imgExpand      the expanded image
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-07-14
% Note: the fuuction is the same as padarray(img, [expandNum expandNum], 'symmetric', 'both');
[height, width] = size(img);
imgExpand = zeros(height+expandNum*2, width+expandNum*2);
imgExpand(expandNum+1:height+expandNum, expandNum+1:width+expandNum) = img(:,:);
imgExpand(1:expandNum, expandNum+1:width+expandNum) = img(expandNum:-1:1,:);
imgExpand(height+expandNum+1:height+expandNum*2, expandNum+1:width+expandNum) = img(height:-1:height-expandNum+1,:);
imgExpand(:,1:expandNum) = imgExpand(:, 2*expandNum:-1:expandNum+1);
imgExpand(:,width+expandNum+1:width+2*expandNum) = imgExpand(:, width+expandNum:-1:width+1);
end