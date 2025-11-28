function varargout = SQUIRREL3D(varargin)
% Authority: Yiwei Hou, Peng Xi
% College of fzuture technology, Peking University
% For any questions, please contact: houyiwei@stu.pku.edu.cn; xipeng@pku.edu.cn
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
%(at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SQUIRREL3D_OpeningFcn, ...
                   'gui_OutputFcn',  @SQUIRREL3D_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SQUIRREL3D is made visible.
function SQUIRREL3D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SQUIRREL3D (see VARARGIN)

% Choose default command line output for SQUIRREL3D
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SQUIRREL3D wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SQUIRREL3D_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addpath('./Basic_Operation')
addpath('./DecorrFuncs')
addpath('./FISTA')
addpath('./GPSF')
addpath('./Regularization')
addpath('./RSE')
global ID_stack;
global XX0;
global YY0;
global ZZ0;

[filename,pathname]=uigetfile({'*.*'},"Select image");
if isequal(filename,0)||isequal(pathname,0)
   errordlg("No image selected","Error");
else
pat='.tif';
datatype=contains(filename,pat);
datatype=double(datatype);
if datatype~=1
       errordlg("Please select .tif images","Error");
end
bit=16;
ID_stack=double(readMTiffn([pathname,filename],bit));
[XX,YY,ZZ] = size(ID_stack);
XX0 = XX;
YY0 = YY;
ZZ0 = ZZ;

[d1,d2,d3] = size(ID_stack);
I=ID_stack(:,:,fix(d3/2));
axes(handles.axes1);
imshow(double(I),[]);
xz = squeeze(ID_stack(fix(d1/2),:,:));
if d3<d1
xz = xz';
end
xz = imresize(xz,[fix(d1/6),d1]);
axes(handles.axes3);
imshow(double(xz),[]);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global IS_stack;
global pathname;
global filename;
[filename,pathname]=uigetfile({'*.*'},"Select image");
if isequal(filename,0)||isequal(pathname,0)
   errordlg("No image selected","Error");
else
pat='.tif';
datatype=contains(filename,pat);
datatype=double(datatype);
if datatype~=1
       errordlg("Please select .tif images","Error");
end
bit=16;
IS_stack=double(readMTiffn([pathname,filename],bit));
[XX,YY,ZZ] = size(IS_stack);
[d1,d2,d3] = size(IS_stack);
I=IS_stack(:,:,fix(d3/2));
axes(handles.axes2);
imshow(double(I),[]);
xz = squeeze(IS_stack(fix(d1/2),:,:));
if d3<d1
xz = xz';
end
xz = imresize(xz,[fix(d1/6),d1]);
axes(handles.axes4);
imshow(double(xz),[]);
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ID_stack;
global IS_stack;
global pathname;
global filename;
global XX0;
global YY0;
global ZZ0;
tic
GPU = get(handles.GPU,'value');

head_dir = pathname;
IS_name = filename;

ID_stack = single(ID_stack);
IS_stack = single(IS_stack);

ID_stack = ID_stack/max(ID_stack(:));
IS_stack = IS_stack/max(IS_stack(:));

% Checking size of IS_stack ID_stack
if ~isequal(size(IS_stack), size(ID_stack))
    IS_stack_resized = imresize3(IS_stack, size(ID_stack), 'Method', 'linear');
    IS_stack = IS_stack_resized;
end

[XX,YY,ZZ] = size(ID_stack);
xy_pad = 50; % lateral volume extension
z_pad = 2; % axial volume extension
Nx = XX + 2*xy_pad;
Nz = ZZ + 2*z_pad;

if mod(XX,2)==0
    adder = 1;
else
    adder = 0;
end
if mod(ZZ,2)==0
    adderz = 1;
else
    adderz = 0;
end

if XX==XX0
ID_stack = padarray(ID_stack, [xy_pad, xy_pad, z_pad], 'symmetric', 'both');
IS_stack = padarray(IS_stack, [xy_pad, xy_pad, z_pad], 'symmetric', 'both');
ID_stack = padarray(ID_stack, [adder, adder, adderz], 'symmetric', 'pre');
IS_stack = padarray(IS_stack, [adder, adder, adderz], 'symmetric', 'pre');
end

Point_det = get(handles.point_det,'value');

[d1,d2,d3] = size(ID_stack);
blockSize = 129;
if d1>blockSize&&d2>blockSize
[ID_stack_ref, IS_stack_ref] = findRepresentativeBlock(ID_stack,IS_stack,129);
else
    ID_stack_ref = ID_stack;
    IS_stack_ref = IS_stack;
end

[d1,d2,d3] = size(ID_stack_ref);
x = -d1/2:d1/2-1;
y = -d2/2:d2/2-1;
z = -d3/2:d3/2-1;
[X,Y,Z] = meshgrid(x,y,z);
shift = 1;

%% Stage 1: Searching the RSF shape parameters
if GPU==1
ID_stack_ref = gpuArray(ID_stack_ref);
IS_stack_ref = gpuArray(IS_stack_ref);
end

if Point_det == 0
objfunc = @(params) 1 - Cuscorr( ID_stack_ref, fftshift( ifftn( fftn(IS_stack_ref) .* fftn( RSF3D(d1, d3, shift, params(1), params(2), GPU) ) )  ));
else
objfunc = @(params) 1 - Cuscorr( ID_stack_ref, fftshift( ifftn( fftn(IS_stack_ref) .* fftn( GRSF3D(d1, d3, params(1), params(2), GPU ) ) )  ));
end

% Genetic algorithm settings
nvars = 2; 
options = optimoptions('ga', 'PopulationSize', 50, 'MaxGenerations', 20,'MaxStallGenerations', 20, 'Display', 'iter');

if Point_det == 1
LB = [-2,-5]; 
UB = [2, 5];   
else 
LB = [0, 0];  
UB = [5, 10];   
end

% Run the genetic algorithm
[x, fval] = ga(objfunc, nvars, [], [], [], [], LB, UB, [], options);

% Display the results
disp(['Best solution: ', num2str(x)]);
disp(['Fitness value: ', num2str(fval)]);
RSF_para1 = x(1);
RSF_para2 = x(2);
[d1_full,d2_full,d3_full] = size(ID_stack_ref);
% Generating the resolution scaled SR image using optimized parameters

if Point_det == 0
RSF = RSF3D(d1_full,d3_full,shift,RSF_para1,RSF_para2,GPU);
else
RSF = GRSF3D(d1_full,d3_full,RSF_para1,RSF_para2,GPU);
end

[d1_full,d2_full,d3_full] = size(ID_stack);
% Generating the resolution scaled SR image using optimized parameters
if Point_det == 0
RSF_full = RSF3D(d1_full,d3_full,shift,RSF_para1,RSF_para2, GPU);
else
RSF_full = GRSF3D(d1_full,d3_full,RSF_para1,RSF_para2, GPU);
end

IRS_stack =  fftshift(ifftn(fftn(IS_stack) .* fftn(RSF_full)));
ID_stack_check = ID_stack ((xy_pad+1 + adder):(xy_pad+XX0), (xy_pad+1 + adder):(xy_pad+YY0),(z_pad+1 + adderz):(z_pad+ZZ0));
IRS_stack_check = IRS_stack ((xy_pad+1 + adder):(xy_pad+XX0), (xy_pad+1 + adder):(xy_pad+YY0),(z_pad+1 + adderz):(z_pad+ZZ0));

ID_stack_check = real(gather(ID_stack_check));
IRS_stack_check = real(gather(IRS_stack_check));
RSF_full = real(gather(RSF_full));

IRS_stack_check = rescaler(IRS_stack_check,ID_stack_check);
cf = corrcoef(IRS_stack_check, ID_stack_check);
cf = cf(1,2);
mae = mean(mean(mean(abs(ID_stack_check-IRS_stack_check))));

    

[XX,YY,ZZ] = size(ID_stack_check);
set(handles.RSE, 'String', num2str(mae));
set(handles.RSP, 'String', num2str(cf));
if XX<=1024
blockSize = fix(XX/4);
else
    blockSize = fix(XX/5);
end
% Segmented 3D-RSP map
numBlocksX = ceil(XX / blockSize);
numBlocksY = ceil(YY / blockSize);
cf_bank3D = zeros(numBlocksX,numBlocksY);
    for i = 1:numBlocksX
        for j = 1:numBlocksY
            startX = (i-1) * blockSize + 1;
            endX = min(i * blockSize, XX);
            startY = (j-1) * blockSize + 1;
            endY = min(j * blockSize, YY);

            A_block = ID_stack_check(startX:endX, startY:endY, :);
            B_block = IRS_stack_check(startX:endX, startY:endY, :);
            
            A_vec = A_block(:);
            B_vec = B_block(:);

            c = corrcoef(A_vec, B_vec);
            cf = c(1, 2);
            cf_bank3D(i,j) = cf;

        end
    end
cf_bank3D(isnan(cf_bank3D)) = 0;
cf_map = imresize(cf_bank3D,[64,64],'nearest');
figure; h= pcolor(flip(cf_map));set(h, 'EdgeColor', 'none'); axis off; caxis([0.5 1]); colorbar;  title("Blocked 3D-RSP map");
cf_map = imresize(cf_map,[XX,YY],'nearest');
errormap = abs(IRS_stack_check-ID_stack_check)*65535; %*norm_error;
toc
PreDFile([head_dir,IS_name,'Resolution-scaled_Stack.tif']);
PreDFile([head_dir,IS_name,'RSF.tif']);
PreDFile([head_dir,IS_name,'errormap.tif']);
PreDFile([head_dir,IS_name,'segmentedCmap.tif']);
PreDFile([head_dir,IS_name,'rgb_stack.tif']);


writeMTiffnOriginal(uint16(65535*IRS_stack_check),[head_dir,IS_name,'Resolution-scaled_Stack.tif'],16);
writeMTiffnOriginal(uint16(65535*RSF/max(RSF(:))),[head_dir,IS_name,'RSF.tif'],16);
writeMTiffnOriginal(uint16(errormap),[head_dir,IS_name,'errormap.tif'],16);



cf_map = imresize(cf_map,[128,128],'nearest');
num_slices = size(cf_map, 3);
rgb_stack = zeros([size(cf_map,1), size(cf_map,2), 3, num_slices], 'uint8');

cmap = parula(256);
idx_0_5 = 128;  
for k = 1:num_slices  
    current_slice = cf_map(:,:,k);  
    indexed_img = zeros(size(current_slice), 'uint8');  
    indexed_img(current_slice < 0.5) = 1;    
    mask = current_slice >= 0.5;  
    scaled_slice = (current_slice(mask) - 0.5) / 0.5;  
    idx_values = round(scaled_slice * 255) + 1; 
    idx_values = max(min(idx_values, 256), 1);  
    indexed_img(mask) = uint8(idx_values);  
    rgb_image = ind2rgb(indexed_img, cmap);  
    rgb_stack(:,:,:,k) = im2uint8(rgb_image);  
end  

imwrite(rgb_stack(:,:,:,1), [head_dir,IS_name,'Blocked3DRSPMap.tif']);
for k = 2:num_slices
    imwrite(rgb_stack(:,:,:,k), [head_dir,IS_name,'rgb_stack.tif'], 'WriteMode', 'append');
end


% --- Executes on button press in wf_det.
function wf_det_Callback(hObject, eventdata, handles)
% hObject    handle to wf_det (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wf_det
wf_det = get(handles.wf_det,'value');
if wf_det == 1
    set(handles.point_det,'value',0);
else
    set(handles.point_det,'value',1);
end

% --- Executes on button press in point_det.
function point_det_Callback(hObject, eventdata, handles)
% hObject    handle to point_det (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of point_det
point_det = get(handles.point_det,'value');
if point_det == 1
    set(handles.wf_det,'value',0);
else
    set(handles.wf_det,'value',1);
end


% --- Executes on button press in GPU.
function GPU_Callback(hObject, eventdata, handles)
% hObject    handle to GPU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GPU



function Iter_Callback(hObject, eventdata, handles)
% hObject    handle to Iter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Iter as text
%        str2double(get(hObject,'String')) returns contents of Iter as a double


% --- Executes during object creation, after setting all properties.
function Iter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Iter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
