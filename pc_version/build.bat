del build\*.* /s /f /q
rmdir build\*.* /s /f /q
rmdir build\ /s /q

mkdir build
c:\Python34\Python.exe setup.py build

cd build
rename exe.win-amd64-3.4 SystemZoetrope(Win64)
cd "SystemZoetrope(Win64)"

del bullet_physic_plugin.dll
del openvr_api.dll
del openvr_plugin.dll
del xmp_audio_plugin.dll

cd..
"C:\Program Files\7-Zip\7z.exe" a SystemZoetrope(Win64).zip
pause