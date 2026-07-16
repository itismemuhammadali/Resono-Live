# Script to set up Java 21 for Firebase Emulator
# Download and install Java 21 LTS

Write-Host "Java 21 Installation Guide" -ForegroundColor Green
Write-Host ""
Write-Host "1. Download Java 21 LTS from:"
Write-Host "   https://www.oracle.com/java/technologies/downloads/#java21"
Write-Host ""
Write-Host "2. Choose 'Windows x64 Installer' and install it"
Write-Host ""
Write-Host "3. After installation, set JAVA_HOME environment variable:"
Write-Host "   setx JAVA_HOME 'C:\Program Files\Java\jdk-21'"
Write-Host ""
Write-Host "4. Restart PowerShell and run:"
Write-Host "   firebase emulators:start"
Write-Host ""
Write-Host "Alternative: Use Chocolatey (if installed):"
Write-Host "   choco install jdk21"
