%% Computer Vision Challenge 2019

% Group number:
group_number = 'G01';

% Group members:

members = {'Jiapeng Zheng', 'Zongyue Li', 'Xingcheng Zhou'};

% Email-Address (from Moodle!):

mail = {'ge25rip@tum.de','ge49hoj@tum.de','ge25nab@tum.de'};

%% Start timer here
tic;


%% Disparity Map
% Specify path to scene folder  img0 img1 and calib
global path;
scene_path = path;
[D_l, D_r, R, T] = disparity_map(scene_path);
% imshow(D);colormap(gca,jet);colorbar;
%% Validation
% Specify path to ground truth disparity map
 gt_path = fullfile('disp0.pfm');
%
% Load the ground truth
 G = pfmread(gt_path);
% 
% Estimate the quality of the calculated disparity map

 p = verify_dmap(D_l, G);

%% Stop timer here
elapsed_time=toc;

%% Print Results
% R, T, p, elapsed_time
 disp('T is');
 disp(T);
 disp('R is');
 disp(R);
 disp(['psnr is', num2str(p)]); 
 disp(['elapsed time is ', num2str(elapsed_time)]);
 
%% Display Disparity
subplot(1,2,1);
imshow(D_l), colormap('jet'), colorbar;
title(['left disparity after filter']);
caxis([0 c_max]);

subplot(1,2,2);
imshow(D_r), colormap('jet'), colorbar;
title(['right disparity after filter']);
caxis([0 c_max]);
