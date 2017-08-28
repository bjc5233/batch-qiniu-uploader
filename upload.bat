@echo off& call lib\loadE.bat qshell& setlocal enabledelayedexpansion
::说明
::    qshell命令是七牛官方命令行工具, 参考 https://developer.qiniu.com/kodo/tools/1302/qshell
::    首次登陆后输入公钥密钥后, 会记录在"C:\Users\Admin\.qshell\account.json", 此文件存在就不需要重新登录输入密钥
::    密钥地址[个人中心->密钥管理]：https://portal.qiniu.com/user/key
if not "%~1" EQU "" if not "%~2" EQU "" set bucket=%1& set file="%~2"

call :checkLogin
call :checkBucket
if defined file (
	call :upload !file!
) else (
	for /l %%x in () do (
		set /p file=拖入文件:
		call :upload !file!
	)
)
goto :EOF









:checkLogin
::判断是否需要已经登录
%qshell% account>nul && set loginStatus=1|| set loginStatus=0
if %loginStatus% EQU 0 (
	set /p accessKey=AccessKey:
	set /p secretKey=SecretKey:
)
goto :EOF



:checkBucket
if not defined bucket (
	set bucketsStr=& for /f "delims=" %%i in ('%qshell% buckets') do set bucketsStr=!bucketsStr!%%i 
	set /p bucket=选择存储空间Bucket[!bucketsStr!]:
)
set bucketValidFlag=0
for /f "delims=" %%i in ('%qshell% buckets') do if "!bucket!" EQU "%%i" set bucketValidFlag=1
if !bucketValidFlag! EQU 0 echo 指定的bucket不存在& timeout 4 >nul& exit
title 七牛文件上传[!bucket!]
::查询指定bucket对应的domains
for /f "delims=" %%i in ('%qshell% domains !bucket!') do set domain=%%i&& set domainStatus=1|| set domainStatus=0
if !domainStatus! EQU 0 echo 指定的bucket domains不存在& timeout 4 >nul& exit
goto :EOF



:upload
for %%i in (%1) do set fileName=%%~ni%%~xi& set localPath=%%~i
echo ---------------start upload---------------
%qshell% fput !bucket! "!fileName!" "!localPath!" && set uplodStatus=1|| set uplodStatus=0
echo ---------------end upload---------------
if !uplodStatus! EQU 1 (
	echo.
	echo.
	set webPath=!domain!/!fileName!
	echo   文件名:!fileName!
	echo 本地路径:!localPath!
	echo 外链路径:!webPath!
	echo !webPath!|clip
	echo 上传成功,外链路径已经保存到剪切板& pause>nul& cls& goto :EOF
) else (
	echo 上传失败& pause>nul& exit
)