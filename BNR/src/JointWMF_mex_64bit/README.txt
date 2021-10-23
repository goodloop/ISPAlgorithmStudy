Distribution Code Version 1.1 -- 06/07/2014 by Qi Zhang Copyright 2014, The Chinese University of Hong Kong.

This executable is created based on the method described in the following paper:
[1] "100+ Times Faster Weighted Median Filter", Qi Zhang, Li Xu, Jiaya Jia, IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 2014

The code and the algorithm are for non-comercial use only.




Folder "matlab_interface":

This folder provides a simplest interface for using 
joint-histogram wegihted median filter in MATLAB.

jointWMF.m: 
	the matlab function of calling joint-histogram weighted median filter

demo_jointWMF.m: 
	an example of using jointWMF function in MATLAB

mexJointWMF.mexw64: 
	an mex function invoked by jointWMF.m

*.dll: 
	the required DLL files for the mex function.



Folder "complete_mex":

It includes all files in Folder "matlab_interface" and 
also the code for compiling the mex file mexJointWMF.mexw64. 
To compile the mex file, several files are required: 
1.openCV include files and libs, 
2.our C++ code: jointWMF.h
3.C++ code for connection mex input and openCV interface: mexJointWMF.cpp. 
4.Matlab code for compilation configuration: compileMex.m (execute this script to get mexJointWMF.mexw64)

They are all included in this folder. 