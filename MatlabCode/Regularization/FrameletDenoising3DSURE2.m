function [f_stack] = FrameletDenoising3DSURE2(g_stack,lambda1,weiper,gpu)
% Data pre-processed
g_stack=single(g_stack);
% g_stack=g_stack/max(max(max(g_stack)));
[d1,d2,d3]=size(g_stack);

% Optimizing the first and the last one
[mm,nn,z]=size(g_stack);
gg_stack=zeros(mm,nn,z+2);
gg_stack=single(gg_stack);
gg_stack(:,:,2:end-1)=g_stack;
gg_stack(:,:,1)=g_stack(:,:,1);
gg_stack(:,:,end)=g_stack(:,:,end);

% GPU accleartion
if gpu==1
    gg_stack=gpuArray(gg_stack);
end

% 3D Framelet transform
L=2;
Fc=FrameletDec3D(gg_stack,L);

% Soft-thresholding
count=1;
[Fcm,Fcn]=size(Fc);
for i=1:Fcn
    Fc_sub1=Fc{1,i};
    [Fc_sub1x,Fc_sub1y,Fc_sub1z]=size(Fc_sub1);
    total=Fc_sub1x*Fc_sub1y*Fc_sub1z*Fcn;
    for ii=1:Fc_sub1x
        for jj=1:Fc_sub1y
            for kk=1:Fc_sub1z
                Fc_sub2=Fc_sub1{ii,jj,kk};
                [Fc_sub2x,Fc_sub2y,Fc_sub2z]=size(Fc_sub2);
                    T=Fc_sub2;
                    D=abs(T)-lambda1*weiper(count);
                    T=sign(T).*((D>0).*D);
                    Fc_sub2=T;
                Fc_sub1{ii,jj,kk}=Fc_sub2;
            end
        end
    end
    Fc{1,i}=Fc_sub1;
end

% Inverse 3D Framelet transform
Rec=FrameletRec3D(Fc,L);

% Regather the original stack
gg_stack=Rec;
g_stack=gg_stack(:,:,2:end-1);
[m,n,z]=size(g_stack);

% Return original gray value
g_stack=single(g_stack);
f_stack=g_stack;
end
