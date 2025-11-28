function [] = writeMTiffo(f_stack,filename,n)
stackfilename = filename;
[~,~,z]=size(f_stack);
% m=max(max(max(f_stack)));
% mi=min(min(min(f_stack)));
for k = 1:z
    X=f_stack(:,:,k);
    X=double(X);
    m=max(max(X));
    mi=min(min(X));
    if n==8

    imwrite(uint8(X), stackfilename, 'WriteMode','append') % 写入stack图像
    elseif n==16

    imwrite(uint16(X), stackfilename, 'WriteMode','append') % 写入stack图像
    else

    imwrite(uint32(X), stackfilename, 'WriteMode','append') % 写入stack图像
    end
end

