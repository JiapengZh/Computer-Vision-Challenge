function [D_l, D_r, R, T, c_max] = disparity_map(scene_path)

    calib_path=[scene_path,'/calib.txt'];
    tic;
    [cam0, cam1, doffs, baseline, width, height, ndisp] = read_calib(calib_path);
    Il = imread(fullfile(scene_path,'im0.png'));
    Ir = imread(fullfile(scene_path,'im1.png'));
%     Il = imgaussfilt(Il);
%     Ir = imgaussfilt(Ir);
    if numel(size(Il))==3
        Il = rgb_to_gray(Il);
        Ir = rgb_to_gray(Ir);
    end

max_disparity = ndisp;  % Max amount a pixel could have shifted
if size(Il,1)>1000
    image_choose=1;
elseif size(Il,1)<1000 & size(Il,1)>500
    image_choose=2;
else
    image_choose=3;
end

switch image_choose
    case 1
        gap=9;
        window=27; 
        rand_size = (window-1)/2;
        p_filter_size = 21;
        alpha=0.4;
        color_max = 255;
    case 2
        gap=5;
        window=21; 
        rand_size = (window-1)/2; 
        p_filter_size =9;
        alpha=0.4;
        color_max= 150;
    case 3
        gap=3;
        window=15; 
        rand_size = (window-1)/2; 
        p_filter_size = 3;
        alpha=0.4;
        color_max=20;
end
    


Il_pad = im2double(pad_image(Il,rand_size));
Ir_pad = im2double(pad_image(Ir,rand_size));
hwait=waitbar(0,'calculating the disparity of image'); %initialize the progress bar
D_l = ones(size(Il));
D_r = ones(size(Ir));
cost_l=ones(size(Ir));
cost_r=ones(size(Ir));
cost_matrix=ones(size(Il));
cost_matrix_r=ones(size(Il));
for r = 1:gap:size(Il,1)  
    %disp([num2str(r),'of',num2str(size(Il,1))]);
    str_dis=['calculating the disparity of image ',num2str(r/size(Il,1)*100),'%'];
    waitbar(r/(size(Il,1)),hwait,str_dis);
    for c = 1:gap:size(Il,2)
%         disp([num2str(c),'of',num2str(size(Il,2))]);
        disp_matrix = ['Inf', 1];      
        for n_disp = 0:(max_disparity-1)
            if (c-n_disp) < 1 
                break
            else
                
                sub_Il = Il_pad(r:r+2*rand_size, c:c+2*rand_size);
                sub_Ir = Ir_pad(r:r+2*rand_size, c-n_disp:c+2*rand_size-n_disp);
                SAD_part=SAD(sub_Il,sub_Ir);
                

                census_part=census(sub_Il,sub_Ir);
                cost_l=alpha*(1-exp(-SAD_part)) + (1-alpha)*(1-exp(-census_part/50));
                
                if cost_l<disp_matrix(1)
                    disp_matrix = [cost_l;n_disp+1]; 
                end

            end
        end
        if r+gap-1<size(Il,1) & c+gap-1<size(Il,2)
            D_l(r:r+gap-1,c:c+gap-1) = disp_matrix(2);
            cost_matrix(r:r+gap-1,c:c+gap-1)=cost_l;
        else
            D_l(r,c) = disp_matrix(2);
            cost_matrix(r,c)=cost_l;
        end
        
         disp_matrix_r = ['Inf', 1];      
         
        for n_disp = 0:(max_disparity-1)
            if (c+n_disp+2*rand_size) >size(Il_pad,2)
                break
            else
                
                sub_Il = Il_pad(r:r+2*rand_size, c+n_disp:c+2*rand_size+n_disp);  
                sub_Ir = Ir_pad(r:r+2*rand_size, c:c+2*rand_size);
                SAD_part=SAD(sub_Il,sub_Ir);

                
                census_part=census(sub_Il,sub_Ir);
                cost_r=alpha*(1-exp(-SAD_part)) + (1-alpha)*(1-exp(-census_part/50));
                %cost_r=alpha*SAD_part+(1-alpha)*gradient_part;%+0.3*census_part;
                
                if cost_r<disp_matrix_r(1)
                    disp_matrix_r = [cost_r;n_disp+1]; 
                end

            end
        end
        if r+gap-1<size(Il,1) & c+gap-1<size(Il,2)
            D_r(r:r+gap-1,c:c+gap-1) = disp_matrix_r(2);
            cost_matrix_r(r:r+gap-1,c:c+gap-1)=cost_r;
        else
            D_r(r,c) = disp_matrix_r(2);
            cost_matrix_r(r,c)=cost_r;
        end
        
        
    end
end
delete(hwait);

 D_l=uint8(D_l);
% subplot(2,2,1);
% imshow(D_l);colormap(gca,jet);colorbar;
% title('left disparity before filter');
% caxis([0 color_max]);
% 
% 
 D_r=uint8(D_r);
% subplot(2,2,2);
% imshow(D_r);colormap(gca,jet);colorbar;
% title('right disparity before filter');
% caxis([0 color_max]);
% 
% D_l=imnoise(D_l,'salt & pepper',0.08); 
% D_r=imnoise(D_r,'salt & pepper',0.08); 
pad_l=uint8(zeros(size(D_l)+2*(p_filter_size-1)));

for x=1:size(D_l,1)
   for y=1:size(D_l,2)
       pad_l(x+p_filter_size-1,y+p_filter_size-1)=D_l(x,y);
   end
end 

hwait_1=waitbar(0,'post processing of left image');
 for i= 1:size(pad_l,1)-2*(p_filter_size-1)
     str_l=['post processing of left image ',num2str(i/(size(pad_l,1)-2*(p_filter_size-1))*100),'%'];
     waitbar(i/(size(pad_l,1)-2*(p_filter_size-1)),hwait_1,str_l);
    for j=1:size(pad_l,2)-2*(p_filter_size-1)
        kernel=uint8(ones((p_filter_size)^2,1));
        t=1;
        for x=1:p_filter_size
          for y=1:p_filter_size
                kernel(t)=pad_l(i+x-1,j+y-1);
                t=t+1;
          end
        end
        filt=sort(kernel);
        D_l(i,j)=filt(ceil(((p_filter_size)^2)/2));
    end
 end
 
pad_r=uint8(zeros(size(D_r)+2*(p_filter_size-1)));
delete(hwait_1);

for x=1:size(D_r,1)
    for y=1:size(D_r,2)
        pad_r(x+p_filter_size-1,y+p_filter_size-1)=D_r(x,y);
    end
end 
hwait_2=waitbar(0,'post processing of right image');
 for i= 1:size(pad_r,1)-2*(p_filter_size-1)
     str_r=['post processing of right image ',num2str(i/(size(pad_r,1)-2*(p_filter_size-1))*100),'%'];
     waitbar(i/(size(pad_r,1)-2*(p_filter_size-1)),hwait_2,str_r);
     %disp(['post processing left image ',num2str(i),' of ',num2str(size(pad_r,1)-2*(p_filter_size-1))]);
    for j=1:size(pad_r,2)-2*(p_filter_size-1)
        kernel=uint8(ones((p_filter_size)^2,1));
        t=1;
        for x=1:p_filter_size
          for y=1:p_filter_size
                kernel(t)=pad_r(i+x-1,j+y-1);
                t=t+1;
          end
        end
        filt=sort(kernel);
        D_r(i,j)=filt(ceil(((p_filter_size)^2)/2));
    end
 end
delete(hwait_2);


% 


%colormapeditor;

  [sortedValues,~] = sort(cost_matrix(:),'ascend'); 
    top_hundert_value = sortedValues(100);
    [row, col] = find(cost_matrix <= top_hundert_value);
    sz = size(row);
    value_in_D = zeros(sz);
    col_new = zeros(sz);
    correspondence = zeros([4 sz]);
    for i = 1 : size(row)
            value_in_D(i) = D_l(row(i),col(i));
            col_new(i) = col(i) - value_in_D(i);

            correspondence(1,i) = row(i);
            correspondence(2,i) = col(i);
            correspondence(3,i) = row(i);
            correspondence(4,i) = col_new(i);
    end
    Korrespondenzen_robust = F_ransac(correspondence, 'tolerance', 0.04);
    E = achtpunktalgorithmus(Korrespondenzen_robust, cam0, cam1);
    [T1, R1, T2, R2, ~, ~]=TR_aus_E(E);
    [T, R] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen_robust, cam0, cam1);
c_max=color_max;
T=single(T);
R=single(R);
% subplot(1,2,1);
% imshow(D_l), colormap('jet'), colorbar;
% title(['left disparity after filter']);
% caxis([0 color_max]);
% 
% subplot(1,2,2);
% imshow(D_r), colormap('jet'), colorbar;
% title(['right disparity after filter']);
% caxis([0 color_max]);


end


 