@echo off

set KSP_FOLDER="C:\Steam\steamapps\common\Kerbal Space Program\Ships\Script"

echo "Deleting old scripts"
del /s /q %KSP_FOLDER%\*

echo "minifying src"
del /s /q scripts\lib\*
del /s /q scripts\missions\*

c:\msys64\usr\bin\env MSYSTEM=MINGW64 c:\msys64\usr\bin\bash -l -c "cd /d/dev/kos/ksp1; ./minify.sh"
echo "done"

echo "Copying scripts to ksp folder: %KSP_FOLDER%"
xcopy /y /i /e "scripts" %KSP_FOLDER%