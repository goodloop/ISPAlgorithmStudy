function Wn = DW_Wn(neighborhoodData, directionNum)
% DW_Wn.m    get rawData from HiRawImage
%   Input:
%       neighborhoodData    the data of neighborhood range
%       directionNum        the num of direction
%   Output:
%       Wn                  The weignt of each direction
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2022-01-23
% Note: 
In = zeros(directionNum, 1);
Wn = zeros(directionNum, 1);
[h, w] = size(neighborhoodData);
centerH = round(h/2);
centerW = round(w/2);
switch directionNum
    case 12
        In(1) = abs(neighborhoodData(centerH, centerW-1) - neighborhoodData(centerH, centerW+1)) + ...
                abs(neighborhoodData(centerH, centerW-2) - neighborhoodData(centerH, centerW));
    
        In(2) = abs(neighborhoodData(centerH-1, centerW) - neighborhoodData(centerH+1, centerW)) + ...
                abs(neighborhoodData(centerH-2, centerW) - neighborhoodData(centerH, centerW));

        In(3) = abs(neighborhoodData(centerH, centerW+1) - neighborhoodData(centerH, centerW-1)) + ...
                abs(neighborhoodData(centerH, centerW+2) - neighborhoodData(centerH, centerW));

        In(4) = abs(neighborhoodData(centerH+1, centerW) - neighborhoodData(centerH-1, centerW)) + ...
                abs(neighborhoodData(centerH+2, centerW) - neighborhoodData(centerH, centerW));    

        In(5) = 0.5*(abs(neighborhoodData(centerH-1, centerW-2) - neighborhoodData(centerH+1, centerW+2)) + ...
                     abs(neighborhoodData(centerH-2, centerW-4) - neighborhoodData(centerH, centerW)));

        In(6) = 0.5*(abs(neighborhoodData(centerH-2, centerW-1) - neighborhoodData(centerH+2, centerW+1)) + ...
                     abs(neighborhoodData(centerH-4, centerW-2) - neighborhoodData(centerH, centerW)));

        In(7) = 0.5*(abs(neighborhoodData(centerH-2, centerW+1) - neighborhoodData(centerH+2, centerW-1)) + ...
                     abs(neighborhoodData(centerH-4, centerW+2) - neighborhoodData(centerH, centerW)));

        In(8) = 0.5*(abs(neighborhoodData(centerH-1, centerW+2) - neighborhoodData(centerH+1, centerW-2)) + ...
                     abs(neighborhoodData(centerH-2, centerW+4) - neighborhoodData(centerH, centerW)));

        In(9) = 0.5*(abs(neighborhoodData(centerH+1, centerW+2) - neighborhoodData(centerH-1, centerW-2)) + ...
                     abs(neighborhoodData(centerH+2, centerW+4) - neighborhoodData(centerH, centerW))); 

        In(10) = 0.5*(abs(neighborhoodData(centerH+2, centerW+1) - neighborhoodData(centerH-2, centerW-1)) + ...
                      abs(neighborhoodData(centerH+4, centerW+2) - neighborhoodData(centerH, centerW)));

        In(11) = 0.5*(abs(neighborhoodData(centerH+2, centerW-1) - neighborhoodData(centerH-2, centerW+1)) + ...
                      abs(neighborhoodData(centerH+4, centerW-2) - neighborhoodData(centerH, centerW)));

        In(12) = 0.5*(abs(neighborhoodData(centerH+1, centerW-2) - neighborhoodData(centerH-1, centerW+2)) + ...
                      abs(neighborhoodData(centerH+2, centerW-4) - neighborhoodData(centerH, centerW)));  
        sumIn = 0;
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
        sumIn = 0;
        for i =1 :4
            sumIn = sumIn + (1/(1+In(i)));
        end
        for i =1 :4
            Wn(i) = (1/(1+In(i)))/sumIn;
        end
end    