# 3D-ADE-toolkit

Supplementary software and source code for the manuscript "A data-adaptive deconvolution and evaluation toolkit for three-dimensional fluorescence microscopy".

The software supports running with MATLAB (.m), ImageJ (.jar) and executive file (.exe), while the latter two ways need the install of a MATLAB Runtime matching 2022b version.

It is composed of a data-adaptive 3D-deconvolution software (Ada3D) and a 3D-SR uncertainty evaluation software (SQUIRREL3D). 

Ada3D can be used to deconvolve diffraction-limited or super-resolution 3D fluorescence image stacks without the need to manually calibrate the 3D-PSF.

SQUIRREL3D can be used to evaluate the fidelity of the deconvolution results, and can also be used to evaluate the quality of 3D physical super-resolution and credibility of 3D deep-learning super-resolution, under the premise that a low-resolution reference is given.

<p align="center">
<img src="./Image/1.png" width="100%">
</p>

## 💻 System requirements

It only requires a standard computer.

We tested our software in Windows 10&11 environments.

# 💿️ Installation guide

The package does not need additional installation steps. 

For biology or microscopy users: To run the .jar and .exe files, the MATLAB software is not necessary but one should download and install the MATLAB runtime version 2022b from: https://ww2.mathworks.cn/products/compiler/matlab-runtime.html (official link, free), or in: https://doi.org/10.6084/m9.figshare.30730169.v1 (we pre-uploaded).After the installation, the ADE3D software can be readily used.

For developers: To run the .m GUI, users need to install MATLAB at any version (this code is written based on MATLAB 2022b, different MATLAB version may have different function rules that influence the functioning). Open the .m file, then click run to activate the software.

# ✨ Demo
Some test data and parameters are attached with the project for demonstration: https://doi.org/10.6084/m9.figshare.30730169.v1

# 🎯 Instructions for use
A detailed UserManual is attached with the project. For any questions in usage, please contact: houyiwei@stu.pku.edu.cn

# ⚡Running speed
Under the MATLAB testing environment, to perform Ada3D deconvolution on a 1024×1024×40 3D-stack, for 40 iterations, it takes ~3 minutes for pure CPU computation (Intel i7-12700, 2.10 GHz), and takes only ~1 minute with GPU acceleration (Nvidia RTX 4080). To evaluate the quality of a 1024×1024×40 3D-stack with a low-resolution reference with the same size, it takes ~20 seconds for pure CPU computation (Intel i7-12700, 2.10 GHz), and takes only ~6 seconds with GPU acceleration (Nvidia RTX 4080).
