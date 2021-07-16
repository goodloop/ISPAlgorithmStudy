function correctP = judgeDefectPixel(aroundP, currentP, Th)
% judgeDefectPixel.m    correct the curren pixel
%   Input:
%       aroundP    	the pixel around the current pixel 
%       currentP    the value of current pixel
%       Th          the threshold of the defect pixel
%   Output:
%       correctP    the corrected value of the pixel
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-07-16
% Note: 
    % get the median value of the around list
    medianV = median(aroundP);
    % get the difference between the around pixel and the current pixel
    diff = aroundP - ones(1, numel(aroundP)) * currentP;
    % if all difference bigger than 0 or all smaller than 0 and all abs of the diff are bigger than Th, that pixel is
    % a defect pixel and replace it with the median;
    if (nnz(diff > 0) ==  numel(aroundP)) || (nnz(diff < 0) ==  numel(aroundP))
        if length(find((abs(diff)>Th)==1)) == numel(aroundP)
            correctP = medianV;
        else
            correctP = currentP;
        end
    else
        correctP = currentP;
    end
end