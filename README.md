# UEFI OS template

A W.I.P. template project for UEFI OS development.

## Table of contents:
- **[Overview of the template's structure](#overview-of-the-templates-structure)**
- **[How to use](#how-to-use)**
    - **[Downloading the template](#downloading-the-template)**
    - **[Using Vagrant](#using-vagrant)**
    - **[Setting up the build environment](#setting-up-the-build-environment)**
    - **[Building and running the project](#building-and-running-the-project)**
- **[How the build system works](#how-the-build-system-works)**
    - **[Tuning the main Makefile](#tuning-the-main-makefile)**
- **[Know issues](#know-issues)**
- **[Credits](#credits)**


---


## Overview of the template's structure
```
<project_name>      // Project root directory
├── files           // Files to be copied to the root of the OS's image (there's a README inside)
├── gnu-efi         // Development package for creating UEFI applications (do not touch)
├── LICENSE         // Project's license (you're free to do whatever with it)
├── Makefile        // Project's main Makefile (use only this one)
├── ovmf-bins       // UEFI BIOS images (needed for QEMU)
├── README.md       // Project's README (modify it to your heart's content)
├── src             // Your OS's source code folder
│   ├── bootloader  //    - Bootloader source code and Makefile
│   ├── kernel      //    - Kernel source code and Makefile
│   └── libc        //    - C library source code
├── tools           // Scripts to set up the development environment (see below for more info)
└── Vagrantfile     // File needed by Vagrant to set up the VM (you can delete this if you don't plan on using it)
```


---


## How to use


### Downloading the template
If you're using GitHub you can just create a new repository using this one as a template by clicking on the green button that says **'Use this template'**, located in the top right of the repository page.  
Otherwise, open your git client and clone this repository. If you're using a terminal you can just type:  
```
git clone --recurse-submodules https://github.com/SkrapeProjects/uefi-os-template.git <project_name>
```  
This will clone the repository in a directory named `<project_name>` located in the same directory you ran the command.


### Using Vagrant
This template provides a Vagrant Ubuntu 20.04 LTS VM to use, in order to make the build environment consistent across all computers. The VM will automatically set up X11 forwarding to the host (check note under this paragraph), so if you have an XServer running on your host you should be able to run GUI applications (such as QEMU) from the virtual machine.  
If you're a Windows user you'll need to install an XServer (such as [VcXsrv](https://sourceforge.net/projects/vcxsrv/) and [GWSL](https://opticos.github.io/gwsl/)) and disable the following features:
- Virtual Machine Platform
- Windows Hypervisor Platform
- Hyper-V (if available)  

**Note:** As of right now X11 forwarding works only on Windows and Linux hosts.  
  
Before you get started make sure you have virtualization enabled.    
Head over to the [Vagrant](https://www.vagrantup.com/) website and download the appropriate version for your system.  

**Note:** all the following commands are to be run in your terminal emulator or Windows console inside the project root directory or one of its subdirectories.  

To start the VM type `vagrant up`.  
The initial startup will take a while, since it will upgrade the system and download all the required dependencies for building the project.  
Once the VM is up and running type `vagrant ssh` to login.  
You can also SSH manually into the machine; the address is `127.0.0.1:2222` or `localhost:2222`. The default username and password are both `vagrant`.  
Your project directory will be mounted at `/workspace` and you should be dropped inside this directory automatically at login.  

**Note:** if you're using Linux as your host and want to use X11 forwarding, you'll need to run the following command to ssh into the VM:  
```
vagrant ssh -- -X
```

Once you're done working inside the VM you can type `logout` or `exit` to return to your host's terminal/console.  
Finally, type `vagrant halt` to shut down the VM.  
**Tip:** If you just need to restart your VM you can use `vagrant reload`.

In the unlikely event your VM breaks type `vagrant destroy` to reset the VM.  

**Note:** the next time you type `vagrant up` it will do all the initial set up once again, so don't worry if it takes a while.


### Setting up the build environment
I provided scripts, stored in the `tools` directory, to automate some tasks. They're made for Ubuntu (they also work under Ubuntu WSL).  
Here's a list of all the scripts, brief explanation of what they do and the order they should be run in:
1) `download_deps.sh` Downloads the required dependencies for building the project. Must be run as root. **Not needed if using Vagrant**.
2) `setup_crosscompiler.sh` Downloads and compiles BinUtils and GCC for `x86_64-elf` cross compilation and installs them in `tools/x86_64-elf-cross`. May take a while to execute.
3) `get_latest_ovmf_bins.sh` Downloads and extracts (in the `ovmf-bins` folder) the latest precompiled OVMF firmware from https://www.kraxel.org/repos.


### Building and running the project
**Note:** all the following commands are to be run in the root directory of the project.  

To build the project for the first time run `make all`, to build `gnu-efi` and the image.  
After that a normal `make` will build only the bootloader and the kernel and update the image with the new files.
The Makefile offers 2 clean options:
- `make clean` Cleans all built objects, libraries, ELFs and EFI files in the build directory.
- `make clean-all` Does what clean does but also cleans the `gnu-efi` project and completely removes the build directory. After running this command it's necessary to re-run `make all`.
To run and debug the project you can use `make run` and `make debug` respectively.

#### In a more easy to read way
From the root directory of your project, the following `make` targets are available:
- `make all` Builds everything. Required after `make clean-all` and when building the project for the first time.
- `make` Defaults to `make partial`. Only builds the bootloader and the kernel and updates the already existing image.
- `make clean` Removes all built targets that end with *.o, *.elf, *.so, *.efi and *.efi.debug
- `make clean-all` Clean `gnu-efi` project and completely deletes the build directory.
- `make run` Runs OS in QEMU
- `make debug` Runs OS in QEMU with GDB attached


---


## How the build system works

When running `make all` in the root directory:

1) Create an empty image.
2) Create `startup.nsh` script.
3) Build `gnu-efi` submodule.
4) Build the bootloader in `BUILD_DIR/bootloader`.
5) Build the kernel and C library in `BUILD_DIR/kernel` and `BUILD_DIR/libc` respectively.
6) Format the image as FAT32.
7) Copy the bootloader's EFI executable in the image's /EFI/BOOT folder.
8) Copy the `startup.nsh` script in the image's root.
9) Copy the kernel's elf file in the image's root.
10) Copy all files and folders recursively from `files/` to the OS image's root.

**Note:** the `startup.nsh` script contains the search path for the EFI file. The script looks through all the drives detected up to `FS7` and checks for the EFI executable in `FSX:\EFI\BOOT\`. If the executable is found the script will execute it, otherwise the script will just quit.


### Tuning the main Makefile
**Note:** all modifications are to be made in the main Makefile (see [overview](#overview-of-the-templates-structure)).  
Available parameters:
- `OS_NAME`: name of the image
- `BUILD_DIR`: path of the build directory
- `SOURCE_DIR`: path of the source directory containing the kernel, bootloader and libc source directories
- `DATA_DIR`: path of the directory containing the files that are to be copied inside the OS image
- `OVMF_BINARIES_DIR`: path of the directory containing the UEFI BIOS images
- `GNU_EFI_DIR`: path of the directory to the GNU-EFI development package.
- `EFI_TARGET`: has to be the name of your bootloader's main source file (default is `loader.efi` so the bootloader's main file is `loader.c`)
- `ELF_TARGET`: name of your compiled kernel ELF file
- `EMU`: emulator's executable
- `DBG`: debugger's executable
- `CC`: C compiler's executable (does not apply to bootloader)
- `AC`: assembly compiler's executable (does not apply to bootloader)
- `LD`: linker's executable (does not apply to bootloader)
- `LDS`: path to the linker script to use (does not apply to bootloader)
- `EMU_BASE_FLAGS`: emulator flags to be applied when testing the OS
- `EMU_DBG_FLAGS`: emulator flags to be applied when debugging the OS
- `DBG_FLAGS`: debugger's flags
- `CFLAGS`: C compiler's flags (does not apply to bootloader)
- `ACFLAGS`: assembly compiler's flags (does not apply to bootloader)
- `LDFLAGS`: linker's flags (does not apply to bootloader)


---


## Know issues

#### Makefile can't find target/file/folder.
Ensure that the path to the project folder and any of the files in it **do not contain spaces**.

#### x86_64-elf-gcc/ld: command not found
Check if the folder `tools/x86_64-elf-cross` exists in the project folder. If it doesn't, run `tools/setup_crosscompiler.sh` to build the default cross-compiler. If you already have set up a cross-compiler you want to use, ensure it's in the global path and is set in the main Makefile (more info [here](#tuning-the-main-makefile)).

#### Cannot use any/some of the SystemTable's functions (system hangs)
Try using `uefi_call_wrapper` to call those functions. The syntax is:
```
EFI_STATUS Status = uefi_call_wrapper(function, number_of_paramters, ...);
```
where `...` are the function's parameters.
An example:
```
EFI_STATUS Status = SystemTable->BootServices->AllocatePool(EfiLoaderData, sizeof(UINTN), (void **) &Buffer);
```
becomes
```
EFI_STATUS Status = uefi_call_wrapper(BS->AllocatePool, 3, EfiLoaderData, sizeof(UINTN), (void **) &Buffer);
```

#### ld: cannot find ...
If the compilation fails with one of the following errors
```
ld: cannot find ../gnuefi/crt0-efi-x86_64.o: No such file or directory
ld: cannot find -lgnuefi
```
ensure you're not using a `-j` argument when running `make all`.

#### Linking fails even though everything should work
If the linking fails with undefined references, try running `make clean-all && make all`. Sometimes make "gets out of sync" or doesn't actually recompile files. The command above forces make to recompile everything. If this doesn't work, then it's probably either your code or your linker script. **Also check issue below**.

#### Object files are not getting deleted
Before [this](https://github.com/SkrapeProjects/uefi-os-template/commit/02d4534ed208cadba4fdfca1bb2f85a356261a14) commit, there was an error in the main Makefile that prevented all the *.o files from being deleted. Try updating the main Makefile and see if that fixes it.

#### GDB can't find debugging symbols
Before [this](https://github.com/SkrapeProjects/uefi-os-template/commit/02d4534ed208cadba4fdfca1bb2f85a356261a14) commit, there was a missing compiler flag in the main Makefile that prevented the inclusion of debugging symbols in the executable. To fix this either update the main Makefile or add the `-g` flag to the `CFLAGS` variable (check [this](#tuning-the-main-makefile) out).

---


## Credits
> **MadMark**: original creator.  
> GitHub: [@SkrapeProjects](https://github.com/SkrapeProjects)
