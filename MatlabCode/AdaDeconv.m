function varargout = AdaDeconv(varargin)
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
                   'gui_OpeningFcn', @AdaDeconv_OpeningFcn, ...
                   'gui_OutputFcn',  @AdaDeconv_OutputFcn, ...
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


% --- Executes just before AdaDeconv is made visible.
function AdaDeconv_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AdaDeconv (see VARARGIN)

% Choose default command line output for AdaDeconv
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AdaDeconv wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AdaDeconv_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in InputButton.
function InputButton_Callback(hObject, eventdata, handles)
% hObject    handle to InputButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addpath('./Basic_Operation')
addpath('./DecorrFuncs')
addpath('./FISTA')
addpath('./GPSF')
addpath('./Regularization')
addpath('./RSE')
global filename;
global pathname;
global bit;
global g_stack;
global Nx;
global Nz;
global adder;
global adderz;
global gpu;
global XX;
global YY;
global ZZ;
global PSFCalMethod;
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
g_stack=double(readMTiffn([pathname,filename],bit));
[XX,YY,ZZ] = size(g_stack);
[d1,d2,d3] = size(g_stack);
I=g_stack(:,:,fix(d3/2));
axes(handles.axes1);
imshow(double(I),[]);
xz = squeeze(g_stack(fix(d1/2),:,:));
if d3<d1
xz = xz';
end
xz = imresize(xz,[fix(d1/6),d1]);
axes(handles.axes3);
imshow(double(xz),[]);


[d1,d2,d3] = size(g_stack);
if mod(d1,2)==0
    adder = 1;
else
    adder = 0;
end
if mod(d3,2)==0
    adderz = 1;
else
    adderz = 0;
end
% define some volume expansion constants
[XX,YY,ZZ] = size(g_stack);
xy_pad = 50;
z_pad = 2;
Nx = XX + 2*xy_pad + adder;
Nz = ZZ + 2*z_pad + adderz;
gpu = get(handles.GPU,'value');
end

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PSFCalMethod;
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
psfmode = get(handles.popupmenu1,'Value');
PSFCalMethod = psfmode;
if psfmode == 1
    set(handles.Mode1,'Visible','on');
    set(handles.Mode2,'Visible','off'); 
else
    set(handles.Mode1,'Visible','off');
    set(handles.Mode2,'Visible','on'); 
end

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CalPSFButton.
function CalPSFButton_Callback(hObject, eventdata, handles)
% hObject    handle to CalPSFButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_stack;
global psf;
global gpu;
global Nx;
global Nz;
global adderz;
global adder;
tic
%% Read setted parameters
wf_det = get(handles.PSF_WF,'value');
pps = 5;
Nr = 50;
Ng = 10;
r = linspace(0,1,Nr);

%% Pre-analysis of the stack
[~,~,d3] = size(g_stack);
g_stack = g_stack / max(g_stack(:));
if Nz<31
    g_stack_sample = g_stack;
else
    g_stack_sample = g_stack(:,:,fix(d3/2)-10:fix(d3/2)+9);
end

if Nx>256
    [g_stack_check,~] = findRepresentativeBlock(g_stack_sample,g_stack_sample,256);
end
weiper = GetWeiper(g_stack_check);

if mod(d3,2)==0
    shift=1;
else
    shift=0;
end

if gpu==1
    g_stack = gpuArray(g_stack);
end

% Show PSF estimation progress prompt
h_psf = waitbar(0, 'Estimating 3D-PSF automatically, please wait...');

[kcMax,lambda_optimal] = Mutlifiltering(g_stack_sample,weiper,1);
[anisotropicRatio1] = CalAni(g_stack_sample);
[anisotropicRatio2] = CalAni(g_stack);
anisotropicRatio = min([anisotropicRatio1,anisotropicRatio2]);
d_res = 2/kcMax;
sigmaxy = d_res/3.5;
sigmaz = sigmaxy * anisotropicRatio;
sigmaxy
sigmaz
if wf_det ==1
    psf = AutoPSF3D(Nx, fix(Nz/2) + adderz, shift, sigmaxy, sigmaz);
else   
    psf = CFPSF3D(sigmaxy, sigmaz, Nx, Nz);
end

toc
% Close PSF estimation prompt
delete(h_psf);

set(handles.LF3, 'String', num2str(2.7*sigmaxy));
set(handles.AF3, 'String', num2str(2.7*sigmaz));


% --- Executes on button press in PSF_WF.
function PSF_WF_Callback(hObject, eventdata, handles)
% hObject    handle to PSF_WF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PSF_WF


% --- Executes on button press in PSF_CF.
function PSF_CF_Callback(hObject, eventdata, handles)
% hObject    handle to PSF_CF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PSF_CF


% --- Executes on button press in SelectButton.
function SelectButton_Callback(hObject, eventdata, handles)
% hObject    handle to SelectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global psf;
[filename,pathname]=uigetfile({'*.*'},"Select image");
if isequal(filename,0)||isequal(pathname,0)
   errordlg("No image selected","Error");
else
pat='.tif';
end
datatype=contains(filename,pat);
datatype=double(datatype);
if datatype~=1
       errordlg("Please select .tif images","Error");
end
bit=16;
psf=double(readMTiffn([pathname,filename],bit));

function lambda_Callback(hObject, eventdata, handles)
% hObject    handle to lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lambda as text
%        str2double(get(hObject,'String')) returns contents of lambda as a double


% --- Executes during object creation, after setting all properties.
function lambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Maxiter_Callback(hObject, eventdata, handles)
% hObject    handle to Maxiter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Maxiter as text
%        str2double(get(hObject,'String')) returns contents of Maxiter as a double


% --- Executes during object creation, after setting all properties.
function Maxiter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Maxiter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GPU.
function GPU_Callback(hObject, eventdata, handles)
% hObject    handle to GPU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gpu;
gpu = get(handles.GPU,'value');
% Hint: get(hObject,'Value') returns toggle state of GPU


% --- Executes on button press in Deconv.
function Deconv_Callback(hObject, eventdata, handles)
% hObject    handle to Deconv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global psf
global g_stack
global filename
global pathname
global f_stack
global adder
global adderz
global Nz
global gpu
global XX;
global YY;
global ZZ;
global PSFCalMethod;
tic
xy_pad = 50;
z_pad = 2;
lambda=get(handles.lambda,'str');
lambda=str2num(lambda);
lambda
Maxiter=get(handles.Maxiter,'str');
Maxiter=str2num(Maxiter);

[~,~,d3_check] = size(g_stack);
g_stack = g_stack/max(g_stack(:));
if d3_check<Nz
g_stack = padarray(g_stack, [xy_pad, xy_pad, z_pad], 'symmetric', 'both');
g_stack = padarray(g_stack, [adder, adder, adderz], 'symmetric', 'pre');
end

if gpu==1
    g_stack = gpuArray(single(g_stack));
    psf = gpuArray(single(psf));
end


[d1,d2,d3]=size(g_stack);
interval = 20;
if XX>257
[g_stack_check,~] = findRepresentativeBlock(g_stack,g_stack,257);
else
    g_stack_check = g_stack;
end
        if Nz<31
        weiper = GetWeiper2(g_stack_check,lambda);
        else
        weiper = GetWeiper2(g_stack_check(:,:,fix(d3/2)-10:fix(d3/2)+9),lambda);   
        end

f_stack = AdaFISTA3DSURE(g_stack,psf,[fix(d1/2),fix(d2/2),fix(d3/2)],Maxiter,lambda,interval,weiper,gpu);

if gpu==1
f_stack = gather(f_stack);
psf = gather(psf);
end
toc
f_stack_out = f_stack ((xy_pad+1):(xy_pad+XX), (xy_pad+1):(xy_pad+YY),(z_pad+1):(z_pad+ZZ));
f_stack_out = f_stack_out/max(f_stack_out(:))*65535;
psf_out = psf((xy_pad+1):(xy_pad+XX), (xy_pad+1):(xy_pad+YY),(z_pad+1):(z_pad+ZZ));
writeimg = [pathname,'Ada',num2str(lambda),'_',num2str(Maxiter),'_',num2str(PSFCalMethod),'-6.tif'];
writePSF = [pathname,'AdaPSF',num2str(lambda),'_',num2str(Maxiter),'_',num2str(PSFCalMethod),'-6.tif'];
PreDFile(writeimg);
PreDFile(writePSF);
writeMTiffnOriginal(uint16(f_stack_out),writeimg,16);
writeMTiffnOriginal(uint16(65535*psf_out/max(psf_out(:))),writePSF,16);

[d1,d2,d3] = size(f_stack_out);
I=f_stack_out(:,:,fix(d3/2));
axes(handles.axes2);
imshow(double(I),[]);
xz = squeeze(f_stack_out(fix(d1/2),:,:));
if d3<d1
xz = xz';
end
xz = imresize(xz,[fix(d1/6),d1]);
axes(handles.axes4);
imshow(double(xz),[]);
