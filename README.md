# Build and Swap Binaries

### 1) Install XC32 v4.35

[Download link for xc32 v4.35 installer for Windows](https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/xc32-v4.35-full-install-windows-x64-installer.exe)

### 2) Install WSL2 and Docker

Dowmload the Docker Desktop installer and install it. Make sure to enable WSL2 support.

[Download the installer from here and follow the instructions](https://docs.docker.com/desktop/features/wsl/)

**Start a WSL terminal and run:**

```bash
  docker --version
```

To verify that Docker is installed correctly.

### 3) Get the files and build


  ```bash
  git clone https://github.com/nikisalli/Free_XC32_PRO_Compiler.git

  cd Free_XC32_PRO_Compiler

  chmod +x ./scripts/run-in-docker.sh

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
  $xc="C:\Program Files\Microchip\xc32\v4.35\bin"  # Change this path if you installed XC32 somewhere else
  Rename-Item "$xc\bin" "$xc\bin_backup" -Force
  Copy-Item -Path "C:\Windows\Temp\bin" -Destination "$xc\bin" -Recurse -Force
  ```

### 5) Enjoy

**You can now open MPLAB X and select the XC32 v4.35 compiler for your project and use all the paid features for free!**
