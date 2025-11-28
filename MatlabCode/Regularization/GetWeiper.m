function [weiper] = GetWeiper(g_stack)
% Data pre-processed
fprintf('**Analyzing weiper**\n');
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

% 3D Framelet transform
L=2;
Fc=FrameletDec3D(gg_stack,L);
weiper=[];
% Soft-thresholding
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
    
                    T=Fc_sub2/0.02;
                    wei = thselect(T(:),'rigrsure');
                    if ii*jj*kk*i == 1
                        wei0 = wei;
                        weiper=[weiper,1];
                    else
                        weiper=[weiper,wei/wei0];
                    end
                    
            end
        end
    end
end
% weiper(2:end) = weiper(2:end) / max(weiper(2:end));
weiper(2:end) = weiper(2:end) / weiper(2);
weiper(1) = 1;
end