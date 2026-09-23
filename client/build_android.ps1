# Script tự động build Android APK trên máy cục bộ (Windows)
$flutterBin = "C:\Users\nhanp\flutter\bin\flutter.bat"
$projectDir = $PSScriptRoot

Set-Location $projectDir

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  BẮT ĐẦU BUILD ANDROID APK (RELEASE)   " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[1/3] Cài đặt dependencies..." -ForegroundColor Yellow
& $flutterBin pub get

Write-Host "`n[2/3] Biên dịch file APK Release..." -ForegroundColor Yellow
& $flutterBin build apk --release

if ($LASTEXITCODE -eq 0) {
    $apkPath = "$projectDir\build\app\outputs\flutter-apk\app-release.apk"
    Write-Host "`n[3/3] THÀNH CÔNG!" -ForegroundColor Green
    Write-Host "File cài đặt Android APK được lưu tại:" -ForegroundColor Green
    Write-Host $apkPath -ForegroundColor White
    
    # Mở thư mục chứa file APK
    explorer.exe /select,$apkPath
} else {
    Write-Host "`n[LỖI] Không thể build cục bộ do máy chưa cài Android SDK / Java." -ForegroundColor Red
    Write-Host "Khuyên dùng: Đẩy code lên GitHub để Cloud tự động build file APK hoàn toàn miễn phí!" -ForegroundColor Yellow
}
