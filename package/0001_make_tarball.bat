@set PATH=C:\msys64\mingw64\bin;C:\msys64\usr\local\bin;C:\msys64\usr\bin;C:\msys64\bin;%PATH%
@set MSYSTEM=MINGW64

@set NAME1=lineseg-1.3

pause tarball を作成します。

cd %~dp0
tar -cvzf %NAME1%.tgz %NAME1%

pause 完了しました。
