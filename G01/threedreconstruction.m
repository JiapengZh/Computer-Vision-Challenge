function[image, A] = threedreconstruction(cam0,baseline,doffs,disparity,scene_path)

image = imread(fullfile(scene_path,'im0.png'));
width = size(image,2);
height = size(image,1);

f = cam0(1,1);
[X,Y] = meshgrid(1:width,1:height);
distancemap = baseline*f./(double(disparity)+doffs);

A(:,:,1) = X;
A(:,:,2) = Y;
A(:,:,3) = distancemap;
% 
% figure;
% ptCloud = pointCloud(A,'Color',double(image)/255);
% pcshow(ptCloud,'VerticalAxis','y','VerticalAxisDir','down');

end