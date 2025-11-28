function gaussKernel3D = CFPSF3D(sigma_xy, sigma_z, Nx, Nz)
    validateattributes(Nx, {'numeric'}, {'scalar','integer','positive'});
    validateattributes(Nz, {'numeric'}, {'scalar','integer','positive'});
    validateattributes(sigma_xy, {'numeric'}, {'scalar','positive'});
    validateattributes(sigma_z, {'numeric'}, {'scalar','positive'});
    
    x = linspace(-(Nx-1)/2, (Nx-1)/2, Nx);
    y = x;  
    z = linspace(-(Nz-1)/2, (Nz-1)/2, Nz);

    [X,Y,Z] = ndgrid(x, y, z);

    gaussKernel3D = exp( -(X.^2)/(2*sigma_xy^2) ...
                        -(Y.^2)/(2*sigma_xy^2) ...
                        -(Z.^2)/(2*sigma_z^2) );
    
    gaussKernel3D = gaussKernel3D / sum(gaussKernel3D(:));
end