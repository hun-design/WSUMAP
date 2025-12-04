# key.properties 파일 생성 스크립트

Write-Host "📝 key.properties 파일 생성" -ForegroundColor Yellow
Write-Host ""

$storePassword = Read-Host "키스토어 비밀번호 입력"
$keyPassword = Read-Host "키 비밀번호 입력 (같으면 엔터)"

if ([string]::IsNullOrWhiteSpace($keyPassword)) {
    $keyPassword = $storePassword
}

$properties = @"
storePassword=$storePassword
keyPassword=$keyPassword
keyAlias=wsumap
storeFile=wsumap-release-key.jks
"@

$properties | Out-File -FilePath "key.properties" -Encoding utf8

Write-Host ""
Write-Host "✅ key.properties 파일이 생성되었습니다!" -ForegroundColor Green
Write-Host "📁 파일 위치: $(Get-Location)\key.properties" -ForegroundColor Cyan

