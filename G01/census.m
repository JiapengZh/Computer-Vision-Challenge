 function [census_value]= census(left, right)
[r,c]=size(left);
left_B=left>left(round((r+1)/2),round((c+1)/2));
right_B=right>right(round((r+1)/2),round((c+1)/2));
% r=size(left,1);
% left_B=left>left(round((r-1)/2));
% right_B=right>right(round((r-1)/2));
left=left_B(:);
right=right_B(:);
number=xor(left,right);
census_value=numel(number(number==1));

end 