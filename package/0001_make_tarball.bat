@set PATH=C:\msys64\mingw64\bin;C:\msys64\usr\local\bin;C:\msys64\usr\bin;C:\msys64\bin;%PATH%
@set MSYSTEM=MINGW64

@set NAME1=lineseg-1.3

pause tarball ���쐬���܂��B

cd %~dp0
tar -cvzf %NAME1%.tar.gz %NAME1%

pause �������܂����B