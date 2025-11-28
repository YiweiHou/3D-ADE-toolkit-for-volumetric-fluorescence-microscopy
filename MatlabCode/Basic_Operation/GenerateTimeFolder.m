function [filename] = GenerateTimeFolder(filename)
aa=clock;
for i=1:5
    filename=[filename,num2str(aa(i)),'_'];
end
end

