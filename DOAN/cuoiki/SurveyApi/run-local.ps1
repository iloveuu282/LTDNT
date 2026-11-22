$ErrorActionPreference = 'Stop'
# Dùng cùng cấu hình và khóa local bền vững như lệnh dotnet run hằng ngày.
Push-Location $PSScriptRoot
try {
    dotnet run
    if ($LASTEXITCODE -ne 0) { throw 'API chạy thất bại. Xem lỗi phía trên.' }
} finally { Pop-Location }
