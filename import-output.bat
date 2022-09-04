@echo on

set KSP_FOLDER="C:\KSP\Kerbal Space Program - current\Ships\Script"

echo "Copying output folder from ksp folder: %KSP_FOLDER%"
xcopy /y /i /e %KSP_FOLDER%\output "output"