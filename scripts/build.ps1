# Build script for Random Names Web Application (Windows PowerShell)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Building Random Names Web Application" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Check if Maven is installed
try {
    $mvnVersion = mvn -version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Maven not found"
    }
} catch {
    Write-Host "Error: Maven is not installed" -ForegroundColor Red
    exit 1
}

# Check if Java is installed
try {
    $javaVersion = java -version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Java not found"
    }
} catch {
    Write-Host "Error: Java is not installed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Maven version:" -ForegroundColor Green
mvn -version

Write-Host ""
Write-Host "Java version:" -ForegroundColor Green
java -version

Write-Host ""
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
mvn clean

Write-Host ""
Write-Host "Building application..." -ForegroundColor Yellow
mvn package

$warFile = "target\pickstream.war"
if (Test-Path $warFile) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host "WAR file location: $warFile" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Get-Item $warFile | Format-Table Name, Length, LastWriteTime
} else {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host "Build failed - WAR file not found" -ForegroundColor Red
    Write-Host "=========================================" -ForegroundColor Red
    exit 1
}
