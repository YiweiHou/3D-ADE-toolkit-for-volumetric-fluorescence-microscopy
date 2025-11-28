function [f,fun_all]=AdaFISTA3DSURE(g,PSF,center,Maxiteration,lambda,interval,weiper,gpu)
% Assigning parameters according to pars and/or default values
        g = single(g);
        g = g/max(g(:));
        PSF = single(PSF);
        PSF = align_psf_size(g,PSF);
        PSF = PSF/sum(PSF(:));
        if gpu==1
            g = gpuArray(g);
            PSF = gpuArray(PSF);
        end
        [m,n,z]=size(g);
% PSF=padPSF3D(PSF,m,n,z);
        trans=@(X) 1/sqrt(m*n*z)*fftn(X);
        itrans=@(X) sqrt(m*n*z)*ifftn(X);
% computng the eigenvalues of the blurring matrix         
        Sbig=fftn(circshift(PSF,1-center));
        size(Sbig)
% computing the two dimensional transform of Bobs
        Btrans=trans(g);
%The Lipschitz constant of the gradient of ||A(X)-Bobs||^2
        L=2*max(max(max(abs(Sbig).^2)));
% initialization
        f_iter=g;
        size(f_iter)
        Y=f_iter;
        t_new=1;

        fun_all=[];
        funsave=sum(sum(sum(real(Sbig.*trans(f_iter)-Btrans).^2)));
        count=0;
        maxframe = 20;

% Initialize progress bar
h = waitbar(0, 'Initializing 3D-Ada deconvolution...');

for iter=1:Maxiteration

    % Update progress bar with status
    progress = iter / Maxiteration;
    if mod(iter, interval) == 0
        waitbar(progress, h, ['Iteration ', num2str(iter), ': Performing regularization (this may take time)...']);
    else
        waitbar(progress, h, ['Iteration ', num2str(iter), '/', num2str(Maxiteration), '...']);
    end

    fun=sum(sum(sum(real(Sbig.*trans(f_iter)-Btrans).^2)));
    fun_all=[fun_all,fun];
    f_old=f_iter;
    t_old=t_new;
    % Gradient step
    D=Sbig.*trans(Y)-Btrans;
    Y=Y-2/L*itrans(conj(Sbig).*D);
    Y=real(Y);  
    [~,~,d3]=size(Y); 
    % Control the noise in Y using 3D-Framelet
    if mod(iter,interval)==0
    [Y] = FrameSUREReg(Y,lambda,weiper,maxframe,gpu);
    end
    %updating t and Y
    f_iter=Y;
    t_new=(1+sqrt(1+4*t_old^2))/2;
    Y=f_iter+(t_old-1)/t_new*(f_iter-f_old);
end

% Close progress bar after completion
delete(h);

f_iter(f_iter<0)=0;
f=f_iter;
end

function new_psf = align_psf_size(g_stack, psf)
    g_size = size(g_stack);
    psf_size = size(psf);

    if isequal(g_size, psf_size)
        new_psf = psf;
        return;
    end

    center_p = ceil(psf_size ./ 2); 
    center_g = ceil(g_size ./ 2);    
    start_idx = center_g - (center_p - 1); 
    end_idx = center_g + (psf_size - center_p);  

    s1 = max(1, start_idx(1));
    e1 = min(g_size(1), end_idx(1));
    psf_s1 = s1 - start_idx(1) + 1;
    psf_e1 = e1 - start_idx(1) + 1;

    s2 = max(1, start_idx(2));
    e2 = min(g_size(2), end_idx(2));
    psf_s2 = s2 - start_idx(2) + 1;
    psf_e2 = e2 - start_idx(2) + 1;
    
    s3 = max(1, start_idx(3));
    e3 = min(g_size(3), end_idx(3));
    psf_s3 = s3 - start_idx(3) + 1;
    psf_e3 = e3 - start_idx(3) + 1;
    
    new_psf = zeros(g_size, class(psf)); 
    new_psf(s1:e1, s2:e2, s3:e3) = psf(psf_s1:psf_e1, psf_s2:psf_e2, psf_s3:psf_e3);
end