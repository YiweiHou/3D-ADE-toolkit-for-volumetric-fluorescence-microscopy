function [wd] = SolveFWHM(Input)
[m,index]=max(abs(Input));
[mi,~] = min(abs(Input));
Input=(Input-mi)/(m-mi);
n=length(Input);
x=1:n;
y=Input;
x=x';
y1=y';
x_new=linspace(min(x),max(x),1000);
tmp=abs(y1);
y_new=interp1(x,tmp,x_new,'spline');
x=x_new;
y1=y_new;
y=y1;
% [fitresult, gof] = createFit(x, y1);
% x=linspace(min(x),max(x),5000);
% a1=fitresult.a1;
% b1=fitresult.b1;
% c1=fitresult.c1;
% a2=fitresult.a2;
% b2=fitresult.b2;
% c2=fitresult.c2;
% y =  a1*exp(-((x-b1)/c1).^2) + a2*exp(-((x-b2)/c2).^2);
rate=0.5;
[ac,index] = max(abs(y));
k1 = index;
k2 = index;
[temp,nt] = size(x);
for i = 1:nt
    if y(k1)>ac*rate
        if k1>1
        k1 = k1 - 1;
        end
    end
    if y(k2)>ac*rate
        if k2<nt
        k2 = k2 + 1;
        end
    end
end
wd = x(k2) - x(k1);
end

