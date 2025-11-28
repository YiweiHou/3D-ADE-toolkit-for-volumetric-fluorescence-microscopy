function psf = RSF3D(Nx,Nz,shift,sigma_xy,sigma_z, GPU)
% calculate Gaussian-Lorentzian PSF
z = (-fix((Nz-1)/2):ceil((Nz-1)/2));  % z distance, in um
xi = z;
L = Nx;

x = (-fix((L-1)/2)):1:(fix((L-1)/2));

[xx,yy] = meshgrid(x, x);
rho = sqrt(xx.^2 + yy.^2);
psf = zeros(Nx,Nx,length(z));
Cxy = 4*log(2)/(2.355^2*sigma_xy^2);
Cz = 4/(2.355^2*sigma_z^2);
psf = zeros(Nx,Nx,length(z));
for i = 1:length(z)
psf(:,:,i) = 1/(1+Cz*xi(i).^2).*exp(-Cxy*rho.^2./(1+Cz*xi(i).^2));
%psf(:,:,i) = psf(:,:,i)./sum(psf(:,:,i),'all');
end
psf = psf./sum(psf(:));
psf = single(psf);
if GPU==1
psf = gpuArray(psf);
end
end
