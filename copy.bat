@echo off

set KSP_FOLDER="C:\Steam\steamapps\common\Kerbal Space Program\Ships\Script"

echo "Deleting old scripts"
del /s /q %KSP_FOLDER%\*

echo "Copying scripts to ksp folder: %KSP_FOLDER%"
xcopy /y /i /e "scripts" %KSP_FOLDER%