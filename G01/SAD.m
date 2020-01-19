function [SAD_value]= SAD(left, right)
    
    SAD_value=sum(sum(abs(left-right)));
end