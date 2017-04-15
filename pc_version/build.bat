
del "build\System Zoetrope (Win64 version)\*.*" /F /S /Q
del "build\System Zoetrope (Win64 version)" /F /Q
rmdir "build\System Zoetrope (Win64 version)" /S /Q

c:\Python34\Python.exe setup.py build
cd build
rename "exe.win-amd64-3.4" "System Zoetrope (Win64 version)"
pause