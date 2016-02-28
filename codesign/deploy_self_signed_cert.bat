@ECHO OFF

:: This script requires "Run as Administrator" cmd.

:: Possible bin path
:: Windows SDK
::     10:  C:\Program Files (x86)\Windows Kits\10\bin\x64
::     8.1: C:\Program Files (x86)\Windows Kits\8.1\bin\x64
::     8:   C:\Program Files (x86)\Windows Kits\8.0\bin\x64
::     7:   C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\bin
:: Visual Studio
::     2015: C:\Program Files (x86)\Windows Kits\10\bin\x64
::     2013: C:\Program Files (x86)\Windows Kits\8.1\bin\x64
::     2010: C:\Program Files\Microsoft SDKs\Windows\v7.0A\bin\
::     2008: C:\Program Files\Microsoft SDKs\Windows\v6.0A\bin\
SET BIN_PATH="C:\Program Files (x86)\Windows Kits\10\bin\x64"

SET CERTMGR_EXE=%BIN_PATH%\certmgr.exe

SET CERTS_STORE=example
SET ROOT_CER_FILE=%CERTS_STORE%\CArootcert.cer
SET CODE_CER_FILE=%CERTS_STORE%\codesigncert.cer


:: Deploy a certificate by using CertMgr.exe at a command prompt
::
::    add MyCert.cer
::        specifies that the certificate found in the file MyCert.cer is to be
::        added to a certificate store.
::    -s
::        Specifies that the store is the computer certificate store.
::    -r localMachine
::        Specifies that the computer certificate store is found under the
::        registry location HKEY_LOCAL_MACHINE.
::    trustedpublisher
::        Specifies that the certificate is to be placed in the Trusted
::        Publishers certificate store.

CALL %CERTMGR_EXE% -add %ROOT_CER_FILE% -s -r localMachine trustedpublisher

CALL %CERTMGR_EXE% -add %CODE_CER_FILE% -s -r localMachine trustedpublisher

:: If the certificate is self-signed, and cannot be traced back to a
:: certificate that is in your Trusted Root Certification Authorities,
:: then you must place a copy of your certificate in that store as well.
::
::    root
::        specifies that the certificate is to be placed in the Trusted
::        Root Certification Authorities certificate store.

CALL %CERTMGR_EXE% -add %ROOT_CER_FILE% -s -r localMachine root

:: To check the certificates:
:: 1. double click %CERTS_STORE%\CArootcert.cer
::    open certmgr.exe to see if it is in both
::    "Trusted Root Certification Authorities" and "Trusted Publishers"
:: 2. double click %CERTS_STORE%\codesigncert.cer
::    open certmgr.exe to see if it is in "Trusted Publishers"