function [corvalue] = Cuscorr(stack1,stack2)
tmp = corrcoef(stack1(:),stack2(:));
corvalue = tmp(1,2);
end