function Kn = DW_Kn(neighborhoodData, directionNum, channelAdded)
% DW_Kn.m    get rawData from HiRawImage
%   Input:
%       neighborhoodData    the data of neighborhood range
%       directionNum        the num of direction
%       channelAdded        the channal to be interpolated
%   Output:
%       Kn                  The color defference of each direction
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2022-01-24
% Note: 

% The default value of channalAdded is 1 if there is no input of it
if nargin < 3
    channelAdded = 1;
end
Kn = zeros(directionNum, 1);
[h, w, c] = size(neighborhoodData);
centerH = round(h/2);
centerW = round(w/2);

if c == 1
    % Take the average of the two adjacent samples of the desired color in the
    % Bayer array if the neighborhoodData is Raw
    Kn(1) = neighborhoodData(centerH, centerW-1) - (neighborhoodData(centerH, centerW) + neighborhoodData(centerH, centerW-2)) / 2;
    Kn(2) = neighborhoodData(centerH-1, centerW) - (neighborhoodData(centerH, centerW) + neighborhoodData(centerH-2, centerW)) / 2;
    Kn(3) = neighborhoodData(centerH, centerW+1) - (neighborhoodData(centerH, centerW) + neighborhoodData(centerH, centerW+2)) / 2;
    Kn(4) = neighborhoodData(centerH+1, centerW) - (neighborhoodData(centerH, centerW) + neighborhoodData(centerH+2, centerW)) / 2;

    Kn(5) = neighborhoodData(centerH-1, centerW-2) - (neighborhoodData(centerH-2, centerW-2) + neighborhoodData(centerH, centerW-2)) / 2;
    Kn(6) = neighborhoodData(centerH-2, centerW-1) - (neighborhoodData(centerH-2, centerW-2) + neighborhoodData(centerH-2, centerW)) / 2;
    Kn(7) = neighborhoodData(centerH-2, centerW+1) - (neighborhoodData(centerH-2, centerW) + neighborhoodData(centerH-2, centerW+2)) / 2;
    Kn(8) = neighborhoodData(centerH-1, centerW+2) - (neighborhoodData(centerH-2, centerW+2) + neighborhoodData(centerH, centerW+2)) / 2;
    Kn(9) = neighborhoodData(centerH+1, centerW+2) - (neighborhoodData(centerH+2, centerW+2) + neighborhoodData(centerH, centerW+2)) / 2;
    Kn(10) = neighborhoodData(centerH+2, centerW+1) - (neighborhoodData(centerH+2, centerW+2) + neighborhoodData(centerH+2, centerW)) / 2;
    Kn(11) = neighborhoodData(centerH+2, centerW-1) - (neighborhoodData(centerH+2, centerW-2) + neighborhoodData(centerH+2, centerW)) / 2;
    Kn(12) = neighborhoodData(centerH+1, centerW-2) - (neighborhoodData(centerH+2, centerW-2) + neighborhoodData(centerH, centerW-2)) / 2;
else
    switch directionNum
    case 12
        Kn(1) = neighborhoodData(centerH, centerW-1, 2) - neighborhoodData(centerH, centerW-1, channelAdded);
        Kn(2) = neighborhoodData(centerH-1, centerW, 2) - neighborhoodData(centerH-1, centerW, channelAdded );
        Kn(3) = neighborhoodData(centerH, centerW+1, 2) - neighborhoodData(centerH, centerW+1, channelAdded);
        Kn(4) = neighborhoodData(centerH+1, centerW, 2) - neighborhoodData(centerH+1, centerW, channelAdded);
        
        Kn(5) = neighborhoodData(centerH-1, centerW-2, 2) - neighborhoodData(centerH-1, centerW-2, channelAdded);
        Kn(6) = neighborhoodData(centerH-2, centerW-1, 2) - neighborhoodData(centerH-2, centerW-1, channelAdded);
        Kn(7) = neighborhoodData(centerH-2, centerW+1, 2) - neighborhoodData(centerH-2, centerW+1, channelAdded);
        Kn(8) = neighborhoodData(centerH-1, centerW+2, 2) - neighborhoodData(centerH-1, centerW+2, channelAdded);
        Kn(9) = neighborhoodData(centerH+1, centerW+2, 2) - neighborhoodData(centerH+1, centerW+2, channelAdded);
        Kn(10) = neighborhoodData(centerH+2, centerW+1, 2) - neighborhoodData(centerH+2, centerW+1, channelAdded);
        Kn(11) = neighborhoodData(centerH+2, centerW-1, 2) - neighborhoodData(centerH+2, centerW-1, channelAdded);
        Kn(12) = neighborhoodData(centerH+1, centerW-2, 2) - neighborhoodData(centerH+1, centerW-2, channelAdded);
    case 4
        Kn(1) = neighborhoodData(centerH-1, centerW-1, 2) - neighborhoodData(centerH-1, centerW-1, channelAdded);
        Kn(2) = neighborhoodData(centerH-1, centerW+1, 2) - neighborhoodData(centerH-1, centerW+1, channelAdded);
        Kn(3) = neighborhoodData(centerH+1, centerW+1, 2) - neighborhoodData(centerH+1, centerW+1, channelAdded);
        Kn(4) = neighborhoodData(centerH+1, centerW-1, 2) - neighborhoodData(centerH+1, centerW-1, channelAdded);
    end
end


