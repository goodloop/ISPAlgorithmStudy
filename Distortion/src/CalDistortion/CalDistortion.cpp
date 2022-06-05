/**
@ 1、读取读片
@ 2、显示图片，延迟卡死
@ 3、一直进行鼠标操作，进行绘图，显示图片
*/
#include<opencv2/core/core.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<stdio.h>
#include <string>
#include <iostream>
using namespace cv;
using namespace std;

Mat img;
Mat dst;

void on_mouse(int event, int x, int y, int flags, void* ustc)
{
    static Point pre_pt;
    static Point cur_pt;
    char temp_1[20];
    // 如果要在图片的任意位置作为起始点，这两步就不需要了
    //pre_pt=Point(-1,-1);
    //cur_pt=Point(-1,-1);
    
    if ((event == CV_EVENT_LBUTTONDOWN) && (flags))
    {
        dst.copyTo(img);
        pre_pt = Point(x, y);
        //sprintf(temp_1,"x:%d,y:%d",x,y);
        //xiaolei=Rect(x1,y1,0,0);
        //putText(img,temp_1,Point(x,y),FONT_HERSHEY_SIMPLEX,0.5,Scalar(255,255,255));
        circle(img, pre_pt, 15, cvScalar(255, 0, 0), CV_FILLED, CV_AA, 0);
        imshow("1", img);
        cout << pre_pt << endl;
    }
    
    else if (event == EVENT_MOUSEMOVE && (flags & EVENT_FLAG_LBUTTON))
    {
        dst.copyTo(img);
        cur_pt = Point(x, y);
        //sprintf(temp_1, "x:%d,y:%d", x, y);
        //xiaolei=Rect(x1,y1,0,0);
        //putText(img, temp_1, Point(x, y), FONT_HERSHEY_SIMPLEX, 0.5, Scalar(0, 255, 255));
        circle(img, pre_pt, 15, cvScalar(255, 0, 0), CV_FILLED, CV_AA, 0);
        line(img, pre_pt, cur_pt, cvScalar(0, 255, 0), 8, CV_AA, 0);
        imshow("1", img);
    }
    else if (event == CV_EVENT_LBUTTONUP)
    {
        dst.copyTo(img);
        cur_pt = Point(x, y);
        //sprintf(temp_1, "x:%d,y:%d", x, y);
        //xiaolei=Rect(x1,y1,0,0);
        //putText(img, temp_1, Point(x, y), FONT_HERSHEY_SIMPLEX, 0.4, Scalar(0, 255, 255));
        circle(img, pre_pt, 15, cvScalar(255, 0, 0), CV_FILLED, CV_AA, 0);
        circle(img, cur_pt, 15, cvScalar(255, 0, 0), CV_FILLED, CV_AA, 0);
        line(img, pre_pt, cur_pt, cvScalar(0, 255, 0), 8, CV_AA, 0);
        imshow("1", img);
    }
    
}

int main()
{    
    img = imread("117-oldBoard-13M.png");
    img.copyTo(dst);
    namedWindow("1", WINDOW_FREERATIO);
    setMouseCallback("1", on_mouse, 0);
    imshow("1", img);
    waitKey(0);
    return 0;
}