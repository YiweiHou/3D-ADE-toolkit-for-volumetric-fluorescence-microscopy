function rescaled = rescaler(restored, gt)  
    % Affine rescaling to minimize the MSE to the GT  
    covMatrix = cov([restored(:), gt(:)]);  
    a = covMatrix(1, 2) / covMatrix(1, 1);  
    b = mean(gt(:)) - a * mean(restored(:));  
    rescaled = a * restored + b;  
end