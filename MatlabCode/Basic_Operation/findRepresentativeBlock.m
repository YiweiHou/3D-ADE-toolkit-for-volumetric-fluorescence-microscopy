function [representativeBlock,representativeBlock_au] = findRepresentativeBlock(stack,stack_au,blockSize)
    [m, n, z] = size(stack);

    if m < blockSize || n < blockSize
        error('The size must be at least 128×128');
    end

    validRows = floor(m / blockSize) * blockSize;
    validCols = floor(n / blockSize) * blockSize;

    maxAvg = -Inf;
    representativeBlock = [];

    for i = 1:blockSize:validRows
        for j = 1:blockSize:validCols
            if (i + blockSize - 1 <= m) && (j + blockSize - 1 <= n)
                currentBlock = stack(i:i+blockSize-1, j:j+blockSize-1, :);
                currentBlock_au = stack_au(i:i+blockSize-1, j:j+blockSize-1, :);
                blockAvg = mean(currentBlock(:));
                if blockAvg > maxAvg
                    maxAvg = blockAvg;
                    representativeBlock = currentBlock;
                    representativeBlock_au = currentBlock_au;
                end
            end
        end
    end
    if isempty(representativeBlock)
        error('Fail to find effective block');
    end
end