function gray_image = rgb_to_gray(input_image)
% Diese Funktion soll ein RGB-Bild in ein Graustufenbild umwandeln. Falls
% das Bild bereits in Graustufen vorliegt, soll es direkt zurueckgegeben werden.
if size(input_image,3)==1
gray_image=input_image;
else
input_image = double(input_image);
gray_image=uint8(0.299*input_image(:,:,1)+0.587*input_image(:,:,2)+0.114*input_image(:,:,3));
end
end