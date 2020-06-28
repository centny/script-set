$ErrorActionPreference = "Stop"
cmd /c build-tess-arch.bat x86 "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvars32.bat"
cmd /c build-tess-arch.bat x64 "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvars64.bat"
Write-Output all done
Pause
