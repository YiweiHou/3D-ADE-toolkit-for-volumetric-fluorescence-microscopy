function [anisotropicRatio] = CalAni(g_stack)
        g_stack_xz = squeeze(mean(double(gather(g_stack)), 2));

        Fspectrum = abs(fftshift(fft2(g_stack_xz)));
        stack = abs(Fspectrum);
        stack = stack/max(stack(:));

        gauss2d = @(p, x, y) p(1) * exp(-( (x - p(2)).^2 / (2 * p(3)^2) + (y - p(4)).^2 / (2 * p(5)^2) )) + p(6);

        [xData, yData] = meshgrid(1:size(stack, 2), 1:size(stack, 1));
        
        initialGuess = [max(stack(:)), size(stack, 2)/2, 20, size(stack, 1)/2, 20, min(stack(:))];

        options = optimset('Display', 'off');
        fittedParams = lsqcurvefit(@(p, xy) gauss2d(p, xy(:,1), xy(:,2)), ...
                                  initialGuess, ...
                                  [xData(:), yData(:)], ...
                                  stack(:), ...
                                  [], [], options);
        
        anisotropicRatio = abs(fittedParams(5))/abs(fittedParams(3));
end