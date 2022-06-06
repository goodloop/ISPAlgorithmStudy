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
int COUNT = 1;

void on_mouse(int event, int x, int y, int flags, void* ustc)
{
    static Point pre_pt;
    static Point cur_pt;
    char temp_1[20];
    static int A1, A2, B, delta;
    double distortion;
    // 如果要在图片的任意位置作为起始点，这两步就不需要了
    //pre_pt=Point(-1,-1);
    //cur_pt=Point(-1,-1);
    if (COUNT <= 3)
    {
        if ((event == CV_EVENT_LBUTTONDOWN) && (flags))
        {
            dst.copyTo(img);
            pre_pt = Point(x, y);
            circle(img, pre_pt, 15, cvScalar(255, 0, 0), CV_FILLED, CV_AA, 0);
            imshow("calDistortion", img);
            cout << "=============LINE-" << COUNT << "=================" << endl;
            cout << "P1:" << pre_pt << endl;
        }
        else if (event == EVENT_MOUSEMOVE && (flags & EVENT_FLAG_LBUTTON))
        {
            dst.copyTo(img);
            cur_pt = Point(x, y);
            circle(img, pre_pt, 15, cvScalar(255, 0, 0), CV_FILLED, CV_AA, 0);
            line(img, pre_pt, cur_pt, cvScalar(0, 255, 0), 8, CV_AA, 0);
            imshow("calDistortion", img);
        }
        else if (event == CV_EVENT_LBUTTONUP)
        {
            dst.copyTo(img);
            cur_pt = Point(x, y);
            circle(img, pre_pt, 15, cvScalar(255, 0, 0), CV_FILLED, CV_AA, 0);
            circle(img, cur_pt, 15, cvScalar(255, 0, 0), CV_FILLED, CV_AA, 0);
            line(img, pre_pt, cur_pt, cvScalar(0, 255, 0), 8, CV_AA, 0);
            cout << "P2:" << cur_pt << endl;
            switch (COUNT)
            {
            case 1:
                A1 = cur_pt.y - pre_pt.y;
                cout << "A1:" << A1 << endl;
                break;
            case 2:
                B = cur_pt.y - pre_pt.y;
                cout << "B:" << B << endl;
                break;
            case 3:
                A2 = cur_pt.y - pre_pt.y;
                cout << "A2:" << A2 << endl;
                break;
            default:
                break;
            }
            
            imshow("calDistortion", img);
            img.copyTo(dst);
            COUNT++;
        }
    }
    else
    {
        if (COUNT == 4)
        {
            cout << "====================================" << endl;
            cout << "            线条选择OK！！！         " << endl;
            cout << "====================================" << endl;
            COUNT++;
            delta = (double)(A1 + A2)/2 - B;
            cout << "delta H: " << delta << endl;
            distortion = (double)delta / (double)B;
            cout << "畸变结果：" << distortion << "%" << endl;
        }
        else
        {
            COUNT++;
            return;
        }
    }
}


int main(int argc, char* argv[])
{
    cout << "加载测试图片：" << argv[1] << endl;
    cout << "请选择测试线条:" << endl;
    img = imread(argv[1]);
    img.copyTo(dst);
    namedWindow("calDistortion", WINDOW_FREERATIO);
    setMouseCallback("calDistortion", on_mouse, 0);
    imshow("calDistortion", img);
    waitKey(0);
    return 0;
}
