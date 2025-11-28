function raw_data = readMTiffn(raw_file,n)
  info = imfinfo(raw_file);
  frames = numel(info);
  if n==8
  raw_data = zeros(info(1).Height, info(1).Width, frames, 'uint8');
  for k = 1:frames
      raw_data(:,:,k) = im2uint8(imread(raw_file, k));
  end
  elseif n==16
  raw_data = zeros(info(1).Height, info(1).Width, frames, 'uint16');
  for k = 1:frames
      raw_data(:,:,k) = im2uint16(imread(raw_file, k));
  end      
  else
        raw_data = zeros(info(1).Height, info(1).Width, frames, 'uint32');
  for k = 1:frames
      raw_data(:,:,k) = im2uint32(imread(raw_file, k));
  end  
end

