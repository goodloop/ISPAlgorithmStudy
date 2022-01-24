function Wn = DW_Wn(neighborhoodData, directionNum, channelDeal, channelAdded)
% DW_Wn.m    get rawData from HiRawImage
%   Input:
%       neighborhoodData    the data of neighborhood range
%       directionNum        the num of direction
%       channalAdded        the channel need to be added
%   Output:
%       Wn                  The weignt of each direction
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2022-01-24
% Note: 
if nargin < 3
    channelDeal = 1;
    channelAdded = 1;
end
In = zeros(directionNum, 1);
Wn = zeros(directionNum, 1);
[h, w, c] = size(neighborhoodData);
centerH = round(h/2);
centerW = round(w/2);
sumIn = 0;
switch directionNum
    case 12
        In(1) = abs(neighborhoodData(centerH, centerW-1, channelAdded) - neighborhoodData(centerH, centerW+1, channelAdded)) + ...
                abs(neighborhoodData(centerH, centerW-2, channelDeal) - neighborhoodData(centerH, centerW, channelDeal));

        In(2) = abs(neighborhoodData(centerH-1, centerW, channelAdded) - neighborhoodData(centerH+1, centerW, channelAdded)) + ...
                abs(neighborhoodData(centerH-2, centerW, channelDeal) - neighborhoodData(centerH, centerW, channelDeal));

        In(3) = abs(neighborhoodData(centerH, centerW+1, channelAdded) - neighborhoodData(centerH, centerW-1, channelAdded)) + ...
                abs(neighborhoodData(centerH, centerW+2, channelDeal) - neighborhoodData(centerH, centerW, channelDeal));

        In(4) = abs(neighborhoodData(centerH+1, centerW, channelAdded) - neighborhoodData(centerH-1, centerW, channelAdded)) + ...
                abs(neighborhoodData(centerH+2, centerW) - neighborhoodData(centerH, centerW));    

        In(5) = 0.5*(abs(neighborhoodData(centerH-1, centerW-2, channelAdded) - neighborhoodData(centerH+1, centerW+2, channelAdded)) + ...
                     abs(neighborhoodData(centerH-2, centerW-4, channelDeal) - neighborhoodData(centerH, centerW, channelDeal)));

        In(6) = 0.5*(abs(neighborhoodData(centerH-2, centerW-1, channelAdded) - neighborhoodData(centerH+2, centerW+1, channelAdded)) + ...
                     abs(neighborhoodData(centerH-4, centerW-2, channelDeal) - neighborhoodData(centerH, centerW, channelDeal)));

        In(7) = 0.5*(abs(neighborhoodData(centerH-2, centerW+1, channelAdded) - neighborhoodData(centerH+2, centerW-1, channelAdded)) + ...
                     abs(neighborhoodData(centerH-4, centerW+2, channelDeal) - neighborhoodData(centerH, centerW, channelDeal)));

        In(8) = 0.5*(abs(neighborhoodData(centerH-1, centerW+2, channelAdded) - neighborhoodData(centerH+1, centerW-2, channelAdded)) + ...
                     abs(neighborhoodData(centerH-2, centerW+4, channelDeal) - neighborhoodData(centerH, centerW, channelDeal)));

        In(9) = 0.5*(abs(neighborhoodData(centerH+1, centerW+2, channelAdded) - neighborhoodData(centerH-1, centerW-2, channelAdded)) + ...
                     abs(neighborhoodData(centerH+2, centerW+4, channelDeal) - neighborhoodData(centerH, centerW, channelDeal))); 

        In(10) = 0.5*(abs(neighborhoodData(centerH+2, centerW+1, channelAdded) - neighborhoodData(centerH-2, centerW-1, channelAdded)) + ...
                      abs(neighborhoodData(centerH+4, centerW+2, channelDeal) - neighborhoodData(centerH, centerW, channelDeal)));

        In(11) = 0.5*(abs(neighborhoodData(centerH+2, centerW-1, channelAdded) - neighborhoodData(centerH-2, centerW+1, channelAdded)) + ...
                      abs(neighborhoodData(centerH+4, centerW-2, channelDeal) - neighborhoodData(centerH, centerW, channelDeal)));

        In(12) = 0.5*(abs(neighborhoodData(centerH+1, centerW-2, channelAdded) - neighborhoodData(centerH-1, centerW+2, channelAdded)) + ...
                      abs(neighborhoodData(centerH+2, centerW-4, channelDeal) - neighborhoodData(centerH, centerW, channelDeal)));   
        
        for i =1 :12
            sumIn = sumIn + (1/(1+In(i)));
        end
        for i =1 :12
            Wn(i) = (1/(1+In(i)))/sumIn;
        end
    case 4
        In(1) = abs(neighborhoodData(centerH-1, centerW-1) - neighborhoodData(centerH+1, centerW+1)) + ...
                abs(neighborhoodData(centerH-2, centerW-2) - neighborhoodData(centerH, centerW));

        In(2) = abs(neighborhoodData(centerH-1, centerW+1) - neighborhoodData(centerH+1, centerW-1)) + ...
                abs(neighborhoodData(centerH-2, centerW+2) - neighborhoodData(centerH, centerW));

        In(3) = abs(neighborhoodData(centerH+1, centerW+1) - neighborhoodData(centerH-1, centerW-1)) + ...
                abs(neighborhoodData(centerH+2, centerW+2) - neighborhoodData(centerH, centerW));

        In(4) = abs(neighborhoodData(centerH+1, centerW-1) - neighborhoodData(centerH-1, centerW+1)) + ...
                abs(neighborhoodData(centerH+2, centerW-2) - neighborhoodData(centerH, centerW));

        for i =1 :4
            sumIn = sumIn + (1/(1+In(i)));
        end
        for i =1 :4
            Wn(i) = (1/(1+In(i)))/sumIn;
        end
end   

    
