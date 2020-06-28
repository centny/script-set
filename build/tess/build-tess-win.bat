@echo off
set work=%cd%
set config=%2
set install_dir=%HOME%\deps\windows\%1\%config%
set source_dir=%HOME%\deps_src
set CL=/MP
echo running by install dir:%install_dir%
echo running by source dir:%source_dir%

REM rmdir /S /Q %source_dir%\zlib\build
REM rmdir /S /Q %source_dir%\libjpeg\build
REM rmdir /S /Q %source_dir%\libpng\build
REM rmdir /S /Q %source_dir%\libwebp\build
REM rmdir /S /Q %source_dir%\libtiff\build_
REM rmdir /S /Q %source_dir%\openjpeg\build
rmdir /S /Q %source_dir%\leptonica\build
rmdir /S /Q %source_dir%\tesseract\build

REM cd %source_dir%\zlib
REM mkdir build
REM cd build
REM cmake .. -G Ninja -DCMAKE_BUILD_TYPE=%config% -DCMAKE_INSTALL_PREFIX:PATH=%install_dir% -DBUILD_SHARED_LIBS=OFF
REM if %errorlevel% neq 0 exit /b %errorlevel%
REM cmake --build . --config %config% --target install
REM if %errorlevel% neq 0 exit /b %errorlevel%
REM cd ../../

REM cd %source_dir%\libjpeg
REM mkdir build
REM cd build
REM cmake .. -G Ninja -DCMAKE_BUILD_TYPE=%config% -DCMAKE_INSTALL_PREFIX:PATH=%install_dir% -DENABLE_SHARED=FALSE
REM if %errorlevel% neq 0 exit /b %errorlevel%
REM cmake --build . --config %config% --target install
REM if %errorlevel% neq 0 exit /b %errorlevel%
REM cd ../../

REM cd %source_dir%\libpng
REM mkdir build
REM cd build
REM cmake .. -G Ninja -DCMAKE_BUILD_TYPE=%config% -DCMAKE_INSTALL_PREFIX:PATH=%install_dir% -DPNG_SHARED=OFF
REM if %errorlevel% neq 0 exit /b %errorlevel%
REM cmake --build . --config %config% --target install
REM if %errorlevel% neq 0 exit /b %errorlevel%
REM cd ../../

REM cd %source_dir%\libwebp
REM mkdir build
REM cd build
REM cmake .. -G Ninja -DCMAKE_BUILD_TYPE=%config% -DCMAKE_INSTALL_PREFIX:PATH=%install_dir% -DBUILD_SHARED_LIBS=OFF
REM if %errorlevel% neq 0 exit /b %errorlevel%
REM cmake --build . --config %config% --target install
REM if %errorlevel% neq 0 exit /b %errorlevel%
REM cd ../../

REM cd %source_dir%\libtiff
REM mkdir build_
REM cd build_
REM cmake .. -G Ninja -DCMAKE_BUILD_TYPE=%config% -Dwebp:BOOL=OFF -Djbig:BOOL=OFF -Djpeg:BOOL=OFF -Djpeg12:BOOL=OFF -DCMAKE_INSTALL_PREFIX:PATH=%install_dir% -DBUILD_SHARED_LIBS=OFF
REM if %errorlevel% neq 0 exit /b %errorlevel%
REM cmake --build . --config %config% --target install
REM if %errorlevel% neq 0 exit /b %errorlevel%
REM cd ../../

REM cd %source_dir%\openjpeg
REM mkdir build
REM cd build
REM cmake .. -G Ninja -DCMAKE_BUILD_TYPE=%config% -DCMAKE_INSTALL_PREFIX:PATH=%install_dir% -DBUILD_SHARED_LIBS=OFF
REM if %errorlevel% neq 0 exit /b %errorlevel%
REM cmake --build . --config %config% --target install
REM if %errorlevel% neq 0 exit /b %errorlevel%
REM cd ../../

cd %source_dir%/leptonica
mkdir build
cd build
echo %config%
if "%config%"=="Debug" cmake .. -G Ninja -DCMAKE_BUILD_TYPE=%config% -DSW_BUILD=0 -DCMAKE_INSTALL_PREFIX:PATH=%install_dir%  -DBUILD_SHARED_LIBS=OFF -DPNG_LIBRARIES=%install_dir%"\lib\libpng16_staticd.lib"
if %errorlevel% neq 0 exit /b %errorlevel%
if "%config%"=="Release" cmake .. -G Ninja -DCMAKE_BUILD_TYPE=%config% -DSW_BUILD=0 -DCMAKE_INSTALL_PREFIX:PATH=%install_dir%  -DBUILD_SHARED_LIBS=OFF -DPNG_LIBRARIES=%install_dir%"\lib\libpng16_static.lib"
if %errorlevel% neq 0 exit /b %errorlevel%
cmake --build . --config %config% --target install
if %errorlevel% neq 0 exit /b %errorlevel%
cd ../../

cd %source_dir%/tesseract
mkdir build
cd build
cmake .. -G Ninja -DCMAKE_BUILD_TYPE=%config% -DSTATIC=1 -DHAVE_TIFFIO_H=0 -DSW_BUILD=0 -DBUILD_TRAINING_TOOLS=OFF -DCPPAN_BUILD=OFF -DCMAKE_INSTALL_PREFIX=%install_dir% -DCMAKE_PREFIX_PATH=%install_dir% -DCMAKE_MODULE_LINKER_FLAGS=-whole-archive -DBUILD_SHARED_LIBS=OFF
if %errorlevel% neq 0 exit /b %errorlevel%
cmake --build . --config %config% --target install
if %errorlevel% neq 0 exit /b %errorlevel%
cd ../../

if exist %source_dir%\libjpeg\build\CMakeFiles\jpeg-static.dir\jpeg-static.pdb echo f | xcopy /f /y /d  %source_dir%\libjpeg\build\CMakeFiles\jpeg-static.dir\jpeg-static.pdb %install_dir%\lib\
if exist %source_dir%\leptonica\build\src\CMakeFiles\leptonica.dir\leptonica.pdb echo f | xcopy /f /y /d %source_dir%\leptonica\build\src\CMakeFiles\leptonica.dir\leptonica.pdb %install_dir%\lib\leptonica-1.80.0d.pdb
if exist %source_dir%\libpng\build\CMakeFiles\png_static.dir\png_static.pdb echo f | xcopy /f /y /d %source_dir%\libpng\build\CMakeFiles\png_static.dir\png_static.pdb %install_dir%\lib\libpng16_staticd.pdb
if exist %source_dir%\openjpeg\build\src\lib\openjp2\CMakeFiles\openjp2.dir\openjp2.pdb echo f | xcopy /f /y /d %source_dir%\openjpeg\build\src\lib\openjp2\CMakeFiles\openjp2.dir\openjp2.pdb %install_dir%\lib\
if exist %source_dir%\tesseract\build\bin\tesseract.pdb echo f | xcopy /f /y /d %source_dir%\tesseract\build\bin\tesseract.pdb %install_dir%\lib\tesseract41d.pdb
if exist %source_dir%\libtiff\build_\libtiff\CMakeFiles\tiff.dir\tiff.pdb echo f | xcopy /f /y /d %source_dir%\libtiff\build_\libtiff\CMakeFiles\tiff.dir\tiff.pdb %install_dir%\lib\tiffd.pdb
if exist %source_dir%\libtiff\build_\libtiff\CMakeFiles\tiffxx.dir\tiffxx.pdb echo f | xcopy /f /y /d %source_dir%\libtiff\build_\libtiff\CMakeFiles\tiffxx.dir\tiffxx.pdb %install_dir%\lib\tiffxxd.pdb
if exist %source_dir%\libjpeg\build\CMakeFiles\turbojpeg-static.dir\turbojpeg-static.pdb echo f | xcopy /f /y /d %source_dir%\libjpeg\build\CMakeFiles\turbojpeg-static.dir\turbojpeg-static.pdb %install_dir%\lib\
if exist %source_dir%\zlib\build\zlibd.pdb echo f | xcopy /f /y /d %source_dir%\zlib\build\zlibd.pdb %install_dir%\lib\
if exist %source_dir%\zlib\build\CMakeFiles\zlibstatic.dir\zlibstatic.pdb echo f | xcopy /f /y /d %source_dir%\zlib\build\CMakeFiles\zlibstatic.dir\zlibstatic.pdb %install_dir%\lib\zlibstaticd.pdb

