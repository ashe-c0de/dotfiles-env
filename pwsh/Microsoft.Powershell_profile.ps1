# notepad $PROFILE
# ls 系列
function ll {
    Get-ChildItem | Select-Object Name, Length, LastWriteTime
}

function la {
    Get-ChildItem -Force
}

# 目录跳转
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

# 文件操作
Set-Alias cat Get-Content
Set-Alias mv Move-Item

function mkdir($name) {
    New-Item -ItemType Directory $name | Out-Null
}

function rm($path) {
    Remove-Item -Recurse -Force $path
}
