@echo off

set KSP_FOLDER="C:\KSP\Kerbal Space Program - current\Ships\Script"

echo "Deleting old scripts"
del /s /q %KSP_FOLDER%\*

echo "Copying scripts to ksp folder: %KSP_FOLDER%"
xcopy /y /i /e "scripts" %KSP_FOLDER%