function imgExpand = expandRaw(img, expandNum)
% expandRaw.m          expanding the raw image by move the edge og image
%   Input:
%       img            the org image 
%       expandNmm      the number of cols and rows to be expanded, must to
%                      be an even number
%   Output:
%       imgExpand      the expanded image
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-07-16
% Note: the function is simliar to padarray(img, [expandNum expandNum], 'symmetric', 'both'), but this func is moving
%       the dege of img not mirror the edge;
if mod(expandNum, 2) ~= 0
    disp('expandNum must be an even number!')
    return
end
[height, width] = size(img);
imgExpand = zeros(height+expandNum*2, width+expandNum*2);
imgExpand(expandNum+1:height+expandNum, expandNum+1:width+expandNum) = img(:,:);
imgExpand(1:expandNum, expandNum+1:width+expandNum) = img(1:expandNum,:);
imgExpand(height+expandNum+1:height+expandNum*2, expandNum+1:width+expandNum) = img(height-expandNum+1:height,:);
imgExpand(:,1:expandNum) = imgExpand(:, expandNum+1:2*expandNum);
imgExpand(:,width+expandNum+1:width+2*expandNum) = imgExpand(:, width+1:width+expandNum);
end