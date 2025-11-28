function psf = AutoPSF3D(Nx, Nz, shift, sigma_xy, sigma_z)
shift = 0;
Nx
z = (-Nz:Nz);  % z distance, in um
xi = z;
L = Nx;
x = (-(L-1)/2):1:((L+1)/2 - 1);
[xx,yy] = meshgrid(x, x);
rho = sqrt(xx.^2 + yy.^2);
Cxy = 4*log(2)/(2.355^2*sigma_xy^2);
Cz = 4/(2.355^2*sigma_z^2);
psf = zeros(Nx,Nx,length(z));
for i = 1:length(z)
psf(:,:,i) = 1/(1+Cz*xi(i).^2).*exp(-Cxy*rho.^2./(1+Cz*xi(i).^2));
%psf(:,:,i) = psf(:,:,i)./sum(psf(:,:,i),'all');
end
psf = psf./sum(psf,'all');
end
