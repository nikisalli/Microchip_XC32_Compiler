# Build and Swap Binaries

### 1) Install WSL2 and Docker

Follow the instructions to set up WSL2 and Docker Desktop.

[Instructions link to install Docker Desktop](https://docs.docker.com/desktop/features/wsl/)

### 2) Install XC32 v4.35

[Download link for xc32 v4.35 installer for Windows](https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/xc32-v4.35-full-install-windows-x64-installer.exe)

### 3) Get the files and build

**In WSL terminal run:**

  ```bash
  git clone https://github.com/nikisalli/Microchip_XC32_Compiler.git

  cd Microchip_XC32_Compiler

  ./scripts/run-in-docker.sh

  cp -r out/bin /mnt/c/Windows/Temp/
  ```

**Note:** it will take a while to download and build everything.

**Result:** Windows executables are in `out/bin`.

---

### 4) install (on Windows)

**Close** MPLAB X. Open **PowerShell as Administrator**.

Run the following commands to swap the binaries with the newly built ones.

  ```powershell
  $xc="C:\Program Files\Microchip\xc32\v4.35"  # Change this path if you installed XC32 somewhere else
  Rename-Item "$xc\bin" "$xc\bin_backup" -Force
  Copy-Item -Path "C:\Windows\Temp\bin" -Destination "$xc\bin" -Recurse -Force
  ```

### 5) Enjoy

**You can now open MPLAB X and select the XC32 v4.35 compiler for your project and use all the paid features for free!**