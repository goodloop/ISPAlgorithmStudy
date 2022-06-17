%% --------------------------------
%% author:Fred
%% date: 20220615
%% fuction: 
%% note:
%% --------------------------------
clc;
close all;
clear;

path = 'images/STD_color_chart.bmp';

global mouseBtnDownFlag
global curPos
global prePos
global img
global ROI_img_cell
global ROI_cell
ROI_cell = zeros(24, 4);
% use reshape(permute(ROI_mean_value, [2,1,3]), [24,3]) transform 4*6*3 to 24*3
global ROI_mean_value
ROI_mean_value = zeros(4, 6, 3);
ROI_img_cell = cell([4, 6]);
mouseBtnDownFlag = 0;

img = imread(path);
figure();
set(gcf,'WindowButtonDownFcn',@ButttonDownFcn,'WindowButtonUpFcn',@ButttonUpFcn, 'WindowButtonMotionFcn', @MouseMoveFcn);
imshow(img);

%% btn down
function ButttonDownFcn(src,event)
    global mouseBtnDownFlag
    global prePos
    mouseBtnDownFlag = 1;
    prePos = get(gca,'CurrentPoint');
    x = prePos(1,1);
    y = prePos(1,2);
    fprintf('Down x=%f,y=%f\n',x,y);
end

%% btn up
function ButttonUpFcn(src,event)
    global mouseBtnDownFlag
    global prePos
    global curPos
    mouseBtnDownFlag = 0;
    curPos = get(gca,'CurrentPoint');
    x = curPos(1,1);
    y = curPos(1,2);
    fprintf('Up x=%f,y=%f\n',x,y);
    rectangle('Position',[prePos(1,1),prePos(1,2),curPos(1,1) - prePos(1,1),curPos(1,2) - prePos(1,2)],'LineWidth',2,'EdgeColor','r');
    drawROI();
    calMeanVOfROI();
end

%% mouse move
function MouseMoveFcn(src,event)
    global mouseBtnDownFlag
    global curPos
    global prePos
    global img
    % btn down and mouse move
    if mouseBtnDownFlag
        curPos = get(gca,'CurrentPoint');
%         x = curPos(1,1);
%         y = curPos(1,2);
%         fprintf('Move x=%f,y=%f\n',x,y);
        % refresh the window
        imshow(img);
        rectangle('Position',[prePos(1,1),prePos(1,2),curPos(1,1) - prePos(1,1),curPos(1,2) - prePos(1,2)],'LineWidth',2,'EdgeColor','r');
    end
end

%% draw ROI
function drawROI()
    global curPos
    global prePos
    global img
    global ROI_img_cell
    global ROI_cell
    x = curPos(1,1) - prePos(1, 1);
    y = curPos(1,2) - prePos(1, 2);
    deltaX = x / 6;
    w = deltaX * 0.6;
    deltaY = y / 4;
    h = deltaY * 0.6;
    for i = 1: 4
        for j = 1: 6
            rectROI = [prePos(1,1) + deltaX /2 + deltaX * (j -1) - w / 2,...
                                  prePos(1,2) + deltaY /2 + deltaY * (i -1) - h / 2,...
                                  w,...
                                  h];
            ROI_cell((i-1)*6+j, :) = rectROI;
            rectangle('Position',rectROI, 'LineWidth',2,'EdgeColor','r');
            roi = imcrop(img,rectROI); 
            ROI_img_cell(i, j) = {roi};
        end
    end
    save('roi.mat', 'ROI_cell');
end

%% calculate the mean value of the three channels of ROI
function calMeanVOfROI()
    global ROI_img_cell
    global ROI_mean_value
    for i = 1: 4
        for j = 1: 6
            roiMat = cell2mat(ROI_img_cell(i, j));
            ROI_mean_value(i, j , :) = mean(roiMat, [1 2]);
        end
    end
    save('targetRGB.mat', 'ROI_mean_value');
end


























