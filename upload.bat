@echo off& call lib\loadE.bat qshell& setlocal enabledelayedexpansion
::˵��
::    qshell��������ţ�ٷ������й���, �ο� https://developer.qiniu.com/kodo/tools/1302/qshell
::    �״ε�½�����빫Կ��Կ��, ���¼��"C:\Users\Admin\.qshell\account.json", ���ļ����ھͲ���Ҫ���µ�¼������Կ
::    ��Կ��ַ[��������->��Կ����]��https://portal.qiniu.com/user/key
if not "%~1" EQU "" if not "%~2" EQU "" set bucket=%1& set file="%~2"

call :checkLogin
call :checkBucket
if defined file (
	call :upload !file!
) else (
	for /l %%x in () do (
		set /p file=�����ļ�:
		call :upload !file!
	)
)
goto :EOF









:checkLogin
::�ж��Ƿ���Ҫ�Ѿ���¼
%qshell% account>nul && set loginStatus=1|| set loginStatus=0
if %loginStatus% EQU 0 (
	set /p accessKey=AccessKey:
	set /p secretKey=SecretKey:
)
goto :EOF



:checkBucket
if not defined bucket (
	set bucketsStr=& for /f "delims=" %%i in ('%qshell% buckets') do set bucketsStr=!bucketsStr!%%i 
	set /p bucket=ѡ��洢�ռ�Bucket[!bucketsStr!]:
)
set bucketValidFlag=0
for /f "delims=" %%i in ('%qshell% buckets') do if "!bucket!" EQU "%%i" set bucketValidFlag=1
if !bucketValidFlag! EQU 0 echo ָ����bucket������& timeout 4 >nul& exit
title ��ţ�ļ��ϴ�[!bucket!]
::��ѯָ��bucket��Ӧ��domains
for /f "delims=" %%i in ('%qshell% domains !bucket!') do set domain=%%i&& set domainStatus=1|| set domainStatus=0
if !domainStatus! EQU 0 echo ָ����bucket domains������& timeout 4 >nul& exit
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
	echo   �ļ���:!fileName!
	echo ����·��:!localPath!
	echo ����·��:!webPath!
	echo !webPath!|clip
	echo �ϴ��ɹ�,����·���Ѿ����浽���а�& pause>nul& cls& goto :EOF
) else (
	echo �ϴ�ʧ��& pause>nul& exit
)