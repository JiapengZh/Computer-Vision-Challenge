function [cam0, cam1, doffs, baseline, width, height, ndisp] = read_calib(calib_path)
    % This function returns the calibration information
    % cam0: camera matrices for the rectified views, in the form [f 0 cx; 0 f cy; 0 0 1]
    % cam1: camera matrices for the rectified views, in the form [f 0 cx; 0 f cy; 0 0 1]
    % doffs: x-difference of principal points, doffs = cx1 - cx0
    % baseline: camera baseline in mm
    % width: image width
    % height: image height
    % ndisp: a conservative bound on the number of disparity levels;
    %        the stereo algorithm MAY utilize this bound and search from d = 0 .. ndisp-1
    fid = fopen(calib_path, 'r');
    
    while true
        tline = fgetl(fid);
        
        if tline==-1
            break
        end
        
        s = tline + ";";
        eval(s);
    end
    
    fclose(fid);
       
end