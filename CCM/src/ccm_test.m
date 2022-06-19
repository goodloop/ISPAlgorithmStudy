function ccm_test
% Test program for applying Color Correction matrix.
% Output for display gamma = 2.2 -- sRGB and Adobe RGB color spaces.
% 1.48663 -0.192007 0.033443
% -0.612018 2.03673 -0.796356
% -0.367863 -0.580001 3.04927


close all;
uiwait(msgbox(['We recommend that you calculate the Color Correction Matrix (CCM),'...
'and copy it to the clipboard before running ccm_test.' ...
'After you click OK, two input dialog boxes will open.'  ...
'1. a narrow box for entering the encoding gamma and entering or pasting the CCM.' ...
'2. A box for browsing and opening the image file to be corrected by the CCM.'], ...
'ccm_test instructions'));

answer = inputdlg({'Enter encoding gamma (typically 0.5-1)'; 'Paste or enter the 3x3 CCM into this box'}, ...
'Enter gamma and CCM', [1 20; 3 20]);
gamma = str2num(answer{1}); %#ok
ccmnum = str2num(answer{2}); %#ok'
szcc = size(ccmnum);
if isempty(answer{1}) || gamma<.01 || gamma>10
disp('gamma is invalid or empty -- try again.'); return;
end
if isempty(answer{2}) || szcc(1)<3 || szcc(1)>4 || szcc(2)<3 || szcc(2)>4
disp('CCM is empty or badly-sized-- try again.'); return; 
end


[im,path] = uigetfile('*.*','Enter the image file to be corrected by the CCM'); % Find image file 
imagefile = fullfile(path,im);
if im==0 | isempty(path) | isempty(im), return; end %#ok

imageRGB = imread(imagefile); % Read the image file.
imtype = class(imageRGB); % Image type: typically uint8 or uint16.
imageRGB = double(imageRGB)/double(intmax(imtype)); % Normalize to maximum for image type.
figure; image(imageRGB);
title(['Original image: gamma = ' num2str(gamma)]); % Works without Image Processing Toolbox.

linearRGB = imageRGB.^(1/gamma); % Linearize the image (apply inverse of encoding gamma).

% Change to 2D to apply matrix; then change back.
[my, mx, mc] = size(linearRGB); % rows, columns, colors (3)
linearRGB = reshape(linearRGB,my*mx,mc); 
correctedRGB = linearRGB*ccmnum; 
correctedRGB = min(correctedRGB,1); correctedRGB = max(correctedRGB,0); % Place limits on output.
correctedRGB = correctedRGB.^(1/2.2); % Apply gamma for sRGB, Adobe RGB color space.
% Deal with saturated pixels. Not perfect, but this is what cameras do. Related to "purple fringing".
correctedRGB(linearRGB==1) = 1; % Don't change saturated pixels. (We don't know HOW saturated.)
correctedRGB = reshape(correctedRGB, my, mx, mc);

figure; image(correctedRGB); title('Corrected image');

tosave = questdlg('Do you want to save the corrected image?','Save the corrected image?', 'Yes','No','No');
if strcmpi(tosave,'Yes')
[path,imroot,ext] = fileparts(imagefile);
imsave = [imroot '-CCM-corr' ext];
sfile = fullfile(path,imsave);
[savef, savepath] = uiputfile(fullfile(path,'*.*'), ...
'Enter a file name to save the CCM-corrected results; empty otherwise', sfile);
savefile = fullfile(savepath,savef);
imwrite(correctedRGB, savefile);
disp(['Results written to ' savefile]);
end