# Create/deploy self-signed certificate for code signing #


# Create self-signed certificates #

```
create_self_signed_cert.bat
```

Check/edit:

- `BIN_PATH`
- `PASS_TXT`
- `CERTS_STORE`
- `-m`: Number of months for the certificate validity period.
- `-e`: End of validity period. Format is mm/dd/yyyy. Defaults to 2039.

# Deploy certificates on a machine #

```
deploy_self_signed_cert.bat
```

Check/edit:

- `BIN_PATH`
- `PASS_TXT`

# Sign setup exe using the certificate #

```
SET SIGNTOOL_EXE="C:\Program Files (x86)\Windows Kits\10\bin\x64\signtool.exe"
CALL %SIGNTOOL_EXE% sign /f path-to\BN-cidesignkeycert.pfx /t http://timestamp.comodoca.com/authenticode /p 3JsG3hy8Qf310mja Output\xx_setup_xx.exe
```

To check the setup.exe, run:
```
CALL %SIGNTOOL_EXE% verify /v /pa Output\xx_setup_xx.exe
```

Ref: http://www.virtues.it/2015/08/howto-create-selfsigned-certificates-with-makecert