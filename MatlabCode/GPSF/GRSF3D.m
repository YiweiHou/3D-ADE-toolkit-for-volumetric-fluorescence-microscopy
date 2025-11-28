function gaussKernel3D = GRSF3D(Nx, Nz, sigma_xy, sigma_z, GPU)

    x = linspace(-(Nx-1)/2, (Nx-1)/2, Nx);
    y = x; 
    z = linspace(-(Nz-1)/2, (Nz-1)/2, Nz);
    
    [X,Y,Z] = ndgrid(x, y, z);

    gaussKernel3D = exp( -(X.^2)/(2*sigma_xy^2) ...
                        -(Y.^2)/(2*sigma_xy^2) ...
                        -(Z.^2)/(2*sigma_z^2) );

    gaussKernel3D = gaussKernel3D / sum(gaussKernel3D(:));
    gaussKernel3D = single(gaussKernel3D);
    if GPU==1
        gaussKernel3D = gpuArray(gaussKernel3D);
    end
end