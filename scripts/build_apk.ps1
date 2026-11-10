param([string]$Flutter = 'C:\Users\SENAI\develop\flutter\bin\flutter.bat')
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path -Parent $PSScriptRoot)
& $Flutter pub get --offline
if ($LASTEXITCODE -ne 0) { throw 'Falha ao resolver dependencias do cache.' }
& $Flutter analyze --no-pub
if ($LASTEXITCODE -ne 0) { throw 'Falha na analise.' }
& $Flutter test --no-pub
if ($LASTEXITCODE -ne 0) { throw 'Falha nos testes.' }
# Nao usar --no-pub neste build: o Flutter precisa regenerar o registrador release.
& $Flutter build apk --release
if ($LASTEXITCODE -ne 0) { throw 'Falha ao compilar APK.' }
Copy-Item -LiteralPath 'build\app\outputs\flutter-apk\app-release.apk' -Destination '08_Modulo_A1_XX.apk' -Force
Write-Output 'APK pronto: 08_Modulo_A1_XX.apk'

