function im_out= pad_image(im, size)

im_out=[repmat(im(:,1),1,size),im,repmat(im(:,end),1,size)];
im_out=[repmat(im_out(1,:),size,1);im_out;repmat(im_out(end,:),size,1)];

end