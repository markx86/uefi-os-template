# UEFI OS template

A W.I.P. template project for UEFI OS development.

---

## How to use


### Downloading the template
If you're using Github you can just create a new repository using this one as a template by clicking on the green button that says **'Use this template'**, located in the top right of the repository page.  
Otherwise open your git client and clone this repository. If you're using a terminal you can just type:  
```git clone --recurse-submodules https://github.com/SkrapeProjects/uefi-os-template.git <project_name>```  
This will clone the repository in a directory named `<project_name>` located in the same directory you ran the command.


### Using Vagrant
This template provides a Vagrant Ubuntu 20.04 LTS VM to use, in order to make the build environment consistant across all computers. The VM will automatically setup X11 redirection to the host, so if you have an XServer running on your host you should be able to run GUI applications (such as QEMU) from the virtual machine.  

**Note:** as of right now this only works on Windows with [VcXsrv](https://sourceforge.net/projects/vcxsrv/) or [GWSL](https://opticos.github.io/gwsl/).  
  
Before you get started make sure you have virtualization enabled.    
Head over to the [Vagrant](https://www.vagrantup.com/) website and download the appropriate version for your system.  

**Note:** all the following commands are to be run in your terminal emulator or Windows console inside the project root directory or one of it's subdirectories.  

To start the VM type `vagrant up`.  
The initial startup will take a while, since it will upgrade the system and download all of the required dependecies needed for building the project.  
Once the VM is up and running type `vagrant ssh` to login.  

**Note:** you can also SSH manually into the machine; the address is `127.0.0.1:2222` or `localhost:2222`. The default username and password are both `vagrant`.  
Your project directory will be mounted at `/workspace` and you should be dropped inside this directory automatically at login.

Once you're done working inside the VM you can type `logout` or `exit` to return to your host's terminal/console.  
Finally type `vagrant halt` to shutdown the VM.  
**Tip:** If you just need to restart your VM you can use `vagrant reload`.

In the unlikely event your VM breaks type `vagrant destroy` to reset the VM.  
**Note:** the next time you type `vagrant up` it will do all the initial setup once again, so don't worry if it takes a while.


### Setting up the build environment
I provided scripts, stored in the `tools` directory, to automate some tasks. They're made for Ubuntu (they also work under Ubuntu WSL).  
Here's a list of the, a brief explanation of what they do and the order they should be run in:
1) `download_deps.sh` Downloads the required dependencies for building the project. Must be run as root. **Not needed if using Vagrant**.
2) `setup_toolchain.sh` Downloads and compiles binutils and gcc for `x86_64-elf` crosscompilation and installs them in `tools/x86_64-elf-cross`. May take a while to execute.
3) `get_latest_ovmf_bins.sh` Downloads and extracts (in the `ovmf-bins` folder) the lastest precompiled OVMF firmware from https://www.kraxel.org/repos.


### Building and running the project
**Note:** all the following commands are to be run in the root directory of the project.  

To build the project for the first time run `make all`, to build `gnu-efi` and the image.  
After that a normal `make` will build only the bootloader and the kernel and update the image with the new files.
The Makefile offers 2 clean options:
- `make clean` Cleans all built objects, libraries, elfs and efi files in the build directory.
- `make clean-all` Does what clean does but also cleans the `gnu-efi` project and completely removes the build directory. After running this command it's necessary to re-run `make all`.

#### TL;DR
From the root directory of your project, the following `make` targets are available:
- `make all` Builds everything. Required after `make clean-all` and when building the project for the first time.
- `make` Defaults to `make partial`. Only builds the bootloader and the kernel and updates the already existing image.
- `make clean` Removes all built targets that end with *.o, *.elf, *.so, *.efi and *.efi.debug
- `make clean-all` Clean `gnu-efi` project and completely deletes the build directory.


### Tuning the Makefiles
// TODO //

---

## How the build system works

When running `make all`:

1) Create an empty image.
2) Create `startup.nsh` script.
3) Build `gnu-efi` submodule.
4) Build the bootloader in `BUILD_DIR/bootloader`.
5) Build the kernel and libc in `BUILD_DIR/kernel` and `BUILD_DIR/libc` respectively.
6) Format the image as FAT32.
7) Copy the bootloader's efi executable in the image's /EFI/BOOT folder.
8) Copy the `startup.nsh` script in the image's root.
9) Copy the kernel's elf file in the image's root.
10) Copy all files and folders recursively from `files/` to the image's root.

**Note:** the `startup.nsh` script contains the search path for the efi file. The script looks through all the drives detected up to `FS7` and checks for the efi executable. If the executable is found the script will execute it, otherwise the script will just quit.

---

## Credits
> **MadMark**: original creator.  
> Github: [@SkrapeProjects](https://github.com/SkrapeProjects)
