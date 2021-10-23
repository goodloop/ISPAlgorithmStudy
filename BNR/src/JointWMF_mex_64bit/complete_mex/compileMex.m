
%mex -setup

include = '-I./include';
libPath = './lib';
lib1 = fullfile(libPath,'opencv_core242.lib');

mex('mexJointWMF.cpp',include,lib1);
