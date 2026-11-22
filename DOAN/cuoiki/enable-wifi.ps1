# Chạy một lần bằng PowerShell Run as administrator.
# Chỉ cho thiết bị cùng mạng nội bộ truy cập API, không thay đổi chính sách chung.
$ErrorActionPreference='Stop'
$ruleName='BusinessSurvey-API-WiFi-5080'
if (!(Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name $ruleName -DisplayName 'BusinessSurvey API WiFi 5080' `
        -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5080 `
        -RemoteAddress LocalSubnet -Profile Any | Out-Null
}
Write-Output 'API port 5080 is allowed for devices on the local subnet.'
