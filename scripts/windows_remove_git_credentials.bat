@echo off
:: Remove saved Git credentials
echo Removing saved Git credentials...
git config --global --unset user.name
git config --global --unset user.email
git config --global --unset user.password

:: Unset GitHub credential variables
set GITHUB_USERNAME=
set GITHUB_EMAIL=
set GITHUB_PASSWORD=

echo Credentials removed.
pause