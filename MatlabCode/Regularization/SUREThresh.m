function trsh = SUREThresh(coefs)
% Single level SURE adaptive thresholding of wavelet coefficients from:
% 'Adapting to Unknown Smoothness via Wavelet Shrinkage', D. Donoho, I. Johnstone,
% Dec 1995
%
% Performs softmax thresholding of wavelet coefficients ('coefs') at this level. 
% Threshold is selected by minimization of SURE objective for threshold ('t') values in range:
% 0 < t < sqrt(2*log(d)) where 'd' is the number of coefficients at this level.
%
% Args:
%    coefs (float array): Single level wavelet coefficients.
%
% Returns:
%    float array: Softmax thresholded wavelet coefficients.

    d = length(coefs);
    t_max = sqrt(2 * log(d));
    t_min = 0;

    % Define the SURE function to minimize
    SURE = @(t) d - 2 * sum(abs(coefs) <= t) + sum(min(abs(coefs), t).^2);

    % Use fminbnd to find the optimal threshold
    options = optimset('Display','off');
    trsh = fminbnd(SURE, t_min, t_max, options);

%     % Soft thresholding function
%     soft_threshold = @(y) sign(y) * max(abs(y) - trsh, 0);
% 
%     % Apply the soft thresholding to each coefficient
%     thresholded_coefs = arrayfun(soft_threshold, coefs);
end