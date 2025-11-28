function [] = PreDFile(filename)
if exist(filename, 'file') == 2
    delete(filename);
    fprintf('File "%s" has been deleted\n', filename);
else
    fprintf('File "%s" does not exist\n', filename);
end
end