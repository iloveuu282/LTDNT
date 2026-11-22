param([string]$DeviceId)
$ErrorActionPreference = 'Stop'
$appPath = Join-Path $PSScriptRoot 'survey_app'
$sdkPath = Join-Path $env:LOCALAPPDATA 'Android\sdk'
$localProperties = Join-Path $appPath 'android\local.properties'
if (Test-Path -LiteralPath $localProperties) {
    $sdkLine = Get-Content -LiteralPath $localProperties | Where-Object { $_ -like 'sdk.dir=*' } | Select-Object -First 1
    if ($sdkLine) { $sdkPath = $sdkLine.Substring(8).Replace('\\', '\').Replace('\:', ':') }
}
$adbPath = Join-Path $sdkPath 'platform-tools\adb.exe'
if (-not (Test-Path -LiteralPath $adbPath)) { throw "Không tìm thấy adb: $adbPath" }
if (-not $DeviceId) {
    $connected = @(& $adbPath devices | Where-Object { $_ -match '^\S+\s+device$' })
    if ($connected.Count -ne 1) {
        & $adbPath devices
        throw 'Cần đúng một điện thoại được cấp quyền, hoặc truyền -DeviceId.'
    }
    $DeviceId = ($connected[0] -split '\s+')[0]
}
try {
    Invoke-RestMethod 'http://127.0.0.1:5080/api/health' -TimeoutSec 5 | Out-Null
} catch {
    throw "API chưa chạy. Mở terminal khác và chạy: powershell -ExecutionPolicy Bypass -File `"$PSScriptRoot\SurveyApi\run-local.ps1`""
}
& $adbPath -s $DeviceId reverse tcp:5080 tcp:5080
if ($LASTEXITCODE -ne 0) { throw 'Không thiết lập được kết nối API qua USB.' }
$env:GRADLE_USER_HOME = Join-Path $appPath '.gradle-local'
Push-Location $appPath
try {
    flutter run -d $DeviceId --dart-define=API_URL=http://127.0.0.1:5080
    if ($LASTEXITCODE -ne 0) { throw 'Flutter chạy thất bại. Xem lỗi phía trên.' }
} finally { Pop-Location }
