@ECHO OFF

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

:: Use makecert.exe and pvk2pfx.exe (and signtool.exe) in Windows Kits 10
SET MKCERT_EXE=%BIN_PATH%\makecert.exe
SET PVK2PFX_EXE=%BIN_PATH%\pvk2pfx.exe

SET CERTS_STORE=example
SET ROOT_PVK_FILE=%CERTS_STORE%\CArootkey.pvk
SET ROOT_CER_FILE=%CERTS_STORE%\CArootcert.cer

SET CODE_PVK_FILE=%CERTS_STORE%\codesignkey.pvk
SET CODE_CER_FILE=%CERTS_STORE%\codesigncert.cer
SET CODE_PFX_FILE=%CERTS_STORE%\codesignkeycert.pfx

SET PASS_TXT=8FsG3hy8Qf310egd

:: Create root CA self-signed certificate (CER) and private key (PVK) files
:: that can be used on different systems
::
:: Purposes:
:: - All issuance policies
:: - All application policies
::
:: Options:
::    -r: Switch to mark the certificate as self-signed.
::    -pe: Switch to mark the generated private key as exportable.
::    -n: Certificate subject X500 name; starts with "CN=" (e.g. "CN=Test Certificate").
::    -a: Signature algorithm. Valid options are [md5|sha1|sha256|sha384|sha512]. Default to 'sha1'.
::    -sky: Subject key type. Valid options are [signature|exchange|[integer]].
::    -cy: Certificate type. Valid options are [end|authority].
::    -sv: Subject’s private key (PVK) file; will be created if not present.
::    -len: Generated Key Length (Bits). An example value is 2048.
::    -m: Number of months for the certificate validity period.
::
:: The following command will pop up a dialog for the password; enter value of PASS_TXT

CALL %MKCERT_EXE% -r -pe -n "CN=MyCert CA Root" -a sha256 -sky signature -cy authority -sv %ROOT_PVK_FILE% -len 2048 -m 60 %ROOT_CER_FILE%


:: Create codesign certificate with specified end date (using the self-signed Root CA certificate)
::
:: Purposes:
:: - Ensure software came from software publisher
:: - Protect software from alteration after publication
::
:: Options:
::    -e: End of validity period. Format is mm/dd/yyyy. Defaults to 2039.
::    -eku: Comma separated Enhanced Key Usage based on Microsoft’s Object IDs (OIDs).
::    -ic: Issuer's certificate file.
::    -iv: Issuer's PVK file
::    -sp: Subject's CryptoAPI provider's name
::    -sy: Subject's CryptoAPI provider's type
::
:: The following EKU and OID values for makecert.exe:
::     USE                                  EKU             OID
::     SSL/TLS Web Server Authentication    serverAuth      1.3.6.1.5.5.7.3.1
::     SSL/TLS Web Client Authentication    clientAuth      1.3.6.1.5.5.7.3.2
::     Code signing                         codeSigning     1.3.6.1.5.5.7.3.3
::     E-mail Protection (S/MIME)           emailProtection 1.3.6.1.5.5.7.3.4

CALL %MKCERT_EXE% -pe -n "CN=MyCert" -a sha256 -len 2048 -sky exchange -eku 1.3.6.1.5.5.7.3.3 -e 03/01/2020 -ic %ROOT_CER_FILE% -iv %ROOT_PVK_FILE% -sp "Microsoft RSA SChannel Cryptographic Provider" -sy 12 -sv %CODE_PVK_FILE% %CODE_CER_FILE%


:: Convert the certificate to PFX format that contains both the private key
:: (PVK) and the certificate file (CER).
::    /pvk: Private key (PVK) input file
::    /spc: Certificate (CER) input file
::    /pfx: PFX output file
::    /pi: PVK input file password
::    /po: PFX output file password. Same as /pi password if not provided.
::    /f: Switch to force the PFX file to be overwritten is it exists.

CALL %PVK2PFX_EXE% /pvk %CODE_PVK_FILE% /spc %CODE_CER_FILE% /pfx %CODE_PFX_FILE% /pi %PASS_TXT% /f


:: To check the certificate:
:: Double click %CERTS_STORE%\CArootcert.cer to check details
:: Double click %CERTS_STORE%\codesigncert.cer to check details