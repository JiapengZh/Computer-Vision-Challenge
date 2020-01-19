function p = verify_dmap(D, G)
% This function calculates the PSNR of a given disparity map and the ground
% truth. The value range of both is normalized to [M,N,D] = size(I);
Diff = double(D)-double(G);
MSE = sum(Diff(:).^2)/numel(D);
p=10*log10(255^2/MSE);
end

