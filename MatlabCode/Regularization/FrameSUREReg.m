function [f0_stack] = FrameSUREReg(f0_stack,lambda,weiper,maxframe,gpu)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[d1,d2,d3]=size(f0_stack);
sub_n=ceil(d3/maxframe);

if d3>maxframe+10+6
   for iter=1:sub_n
     if iter~=sub_n&&iter~=1
         f_stack_single=f0_stack(:,:,1+(iter-1)*maxframe-2:iter*maxframe+2);    
     elseif iter==sub_n
         f_stack_single=f0_stack(:,:,1+(iter-1)*maxframe-2:end);     
     else
         f_stack_single=f0_stack(:,:,1:maxframe+2);     
     end

    [f_stack_single] = FrameletDenoising3DSURE2(f_stack_single,lambda,weiper,gpu);
       
    if iter==1
    f0_stack(:,:,1:maxframe)=f_stack_single(:,:,1:maxframe);
    elseif iter==sub_n
    f0_stack(:,:,1+(iter-1)*maxframe:end)=f_stack_single(:,:,3:end);
    else
    f0_stack(:,:,1+(iter-1)*maxframe:iter*maxframe)=f_stack_single(:,:,3:end-2);
    end
   end
else
    [f0_stack] = FrameletDenoising3DSURE2(f0_stack,lambda,weiper,gpu);
end
end