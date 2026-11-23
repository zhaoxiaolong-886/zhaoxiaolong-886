@echo off
chcp 65001 >nul 2>&1
title 去除桌面快捷方式小箭头
color 0A

echo ==================================================
echo   去除桌面快捷方式小箭头
echo ==================================================
echo.

REM ---------- 提权 ----------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [需要管理员权限，正在请求提权...]
    echo.
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    if errorlevel 1 (
        echo.
        echo [!] 提权失败。请右键本文件 -^> "以管理员身份运行"
        pause
        exit /b 1
    )
    exit /b 0
)

echo [1/3] 管理员权限已确认
echo.

REM ---------- 准备透明图标 ----------
set "ICO_DIR=%SystemRoot%\Icons"
set "ICO_FILE=%ICO_DIR%\blank_shortcut.ico"

if not exist "%ICO_DIR%" mkdir "%ICO_DIR%" >nul 2>&1

if exist "%~dp0blank.ico" (
    copy /y "%~dp0blank.ico" "%ICO_FILE%" >nul 2>&1
    echo [2/3] 已安装透明图标: %ICO_FILE%
) else (
    echo [2/3] [!] 未找到 blank.ico，改为用系统空白图标资源
    set "ICO_FILE=%SystemRoot%\System32\shell32.dll,-50"
)

REM ---------- 写注册表 ----------
echo.
echo [3/3] 写入注册表 HKLM\...\Explorer\Shell Icons\29 ...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$k='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons'; if(-not (Test-Path $k)){New-Item -Path $k -Force|Out-Null}; New-ItemProperty -Path $k -Name '29' -Value '%ICO_FILE%' -PropertyType String -Force|Out-Null; if((Get-ItemProperty $k).'29'){exit 0}else{exit 1}"

if errorlevel 1 (
    echo.
    echo [!] 写入注册表失败。请确认已用管理员身份运行。
    pause
    exit /b 1
)

echo       OK - Shell Icons\29 = %ICO_FILE%
echo.

REM ---------- 重启资源管理器 ----------
echo 正在重启资源管理器...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
start "" explorer.exe
timeout /t 3 /nobreak >nul

echo.
echo ==================================================
echo   完成！小箭头应已消失。
echo ==================================================
echo.
echo 若个别图标仍有箭头，重启一次电脑可刷新图标缓存。
echo.
echo [还原方法]
echo   1) 删除注册表项 HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons
echo   2) 删除文件 %ICO_FILE%
echo   3) 重启资源管理器
echo.
pause
