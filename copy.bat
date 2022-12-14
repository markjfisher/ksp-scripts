@echo off

set KSP_FOLDER="C:\Steam\steamapps\common\Kerbal Space Program\Ships\Script"
set MINIFY=1

echo "Deleting old scripts"
del /s /q %KSP_FOLDER%\*
rmdir /s /q %KSP_FOLDER%
mkdir %KSP_FOLDER%

if not exist scripts\lib      mkdir scripts\lib
if not exist scripts\missions mkdir scripts\missions

del /s /q scripts\lib\*
del /s /q scripts\missions\*

if "%MINIFY%"=="1" (
  echo "minifying src"
  c:\msys64\usr\bin\env MSYSTEM=MINGW64 c:\msys64\usr\bin\bash -l -c "cd /d/dev/kos/ksp1; ./minify.sh"
) else (
  echo "straight copying src"
  xcopy /y /i /e "scripts\lib_src\*" "scripts\lib\"
  xcopy /y /i /e "scripts\missions_src\*" "scripts\missions\"
)

echo "done"

echo "Copying scripts to ksp folder: %KSP_FOLDER%"
xcopy /y /i /e "scripts" %KSP_FOLDER%