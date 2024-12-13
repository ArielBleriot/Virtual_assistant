@echo off

:: Define variables for easy configuration
set WEB_SERVICE_VENV_NAME=web-service-env
set TKINTER_CLIENT_VENV_NAME=tkinter-client-env
set PROJECT_NAME=ai-chat-app
set GITHUB_REPO=https://github.com/ingus-t/ai-chat-app.git

:: change this to match your own repository on GitHub
set ORIGIN_REPO=git@github.com:your-username/your-repository.git

:: Get the current timestamp in a format suitable for file names: YYYY-MM-DD_HH-MM-SS
for /f "tokens=1-4 delims=/-. " %%A in ('echo %date% %time%') do (
    for /f "tokens=1-4 delims= " %%A in ('wmic os get localdatetime ^| find "."') do set datetime=%%A
    set timestamp=%datetime:~0,8%_%datetime:~8,6%
)

:: Set the log file name
set LOG_FILE=logs\setup_log_%timestamp%.txt

:: Redirect all output (stdout and stderr) to the log file
(

    :: Steps 0: Create a logs folder if it doesn't exist
    echo =========\nSteps 0: checking logs folder\n=========
    if not exist logs (
        mkdir logs
        echo created a logs folder
    ) else (
        echo logs folder already exists
    )

    :: Steps 1: Check if Git is installed
    echo =========\nSteps 1: Checking if Git is installed\n=========
    git --version >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo Git is not installed.
        echo Please install Git and run this script again.
        pause
        exit /b 1
    ) else (
        echo Git is installed.
    )

    :: Steps 2: Check if Python is installed
    echo =========\nSteps 2: Checking if Python is installed\n=========
    python --version >nul 2>&1

    python -c "import sys; assert sys.version_info.major >= 3"
    if ERRORLEVEL 1 (
        echo Python 3.x is required. Please install Python 3.x and run this script again.
        exit /b
    )

    if %ERRORLEVEL% neq 0 (
        echo "python" command not found, checking for "python3"\n=========
        python3 --version >nul 2>&1
        if %ERRORLEVEL% neq 0 (
            echo Python is not installed.
            echo Please install Python and run this script again.
            pause
            exit /b 1
        ) else (
            echo Python is installed as "python3".
            set PYTHON_CMD=python3
        )
    ) else (
        echo Python is installed as "python".
        echo Please verify that python v3.x is on your system. It is possible that "python" refers to Python 2.x.
        set PYTHON_CMD=python
    )

    echo Using Python command: %PYTHON_CMD%

    :: Steps 3 Check if Node is installed
    echo =========\nSteps 3: Checking if Node.js is installed\n=========
    node --version >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        echo Node.js is not installed. 
        echo Please install Node.js and run this script again.
        pause
        exit /b 1
    ) ELSE (
        FOR /f "delims=" %%i IN ('node --version') DO SET node_version=%%i
        echo Node.js version: %node_version%
    )

    :: Steps 4 Check if npm is installed
    echo =========\nSteps 4: Checking if npm is installed\n=========
    npm --version >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        echo npm is not installed.
        echo Please install npm and run this script again.
        pause
        exit /b 1
    ) ELSE (
        FOR /f "delims=" %%i IN ('npm --version') DO SET npm_version=%%i
        echo npm version: %npm_version%
    )

    :: Steps 5: Clone the source repository
    echo =========\nSteps 5: Cloning the GitHub repository\n=========
    git clone %GITHUB_REPO%
    cd %PROJECT_NAME%

    if ERRORLEVEL 1 (
        echo Failed to clone the repository. Check your internet connection or the repository URL.
        exit /b 1
    )

    :: Steps 6: Set student's GitHub repository as origin
    echo =========\nSteps 6: Setting your own repository as the origin\n=========
    git remote add origin %ORIGIN_REPO%
    git remote -v

    :: Steps 7: GitHub global credential configuration
    :: Ask user if they want to save GitHub credentials globally
    echo =========\nSteps 7: GitHub credentials
    echo Do you want to save your GitHub credentials globally? (y/n)
    echo You should only do this on your personal computer, or make sure to delete these credentials when you are done.
    set /p SAVE_GLOBAL=Enter y for Yes or n for No: 

    if /i "%SAVE_GLOBAL%"=="y" (
        echo Please enter your GitHub details.

        :: Prompt for GitHub credentials
        set /p GITHUB_USERNAME=Enter your GitHub username: 
        set /p GITHUB_EMAIL=Enter your GitHub email: 
        set /p GITHUB_PASSWORD=Enter your GitHub password: 

        :: Save GitHub username, email, and password globally
        git config --global user.name "%GITHUB_USERNAME%"
        git config --global user.email "%GITHUB_EMAIL%"
        git config --global user.password "%GITHUB_PASSWORD%"

        echo GitHub credentials have been configured globally.
    ) else (
        echo Skipping global GitHub credentials setup. Ensure you have configured authentication via SSH or other methods. You must be able to commit to your own repository.
    )

    :: Unset GitHub credential variables
    set GITHUB_USERNAME=
    set GITHUB_EMAIL=
    set GITHUB_PASSWORD=

    :: Steps 8: Create the virtual environments
    echo =========\nSteps 8: Creating virtual environments\n=========
    echo   for web-service, it is called: %WEB_SERVICE_VENV_NAME%
    cd web-service
    if not exist %WEB_SERVICE_VENV_NAME% (
        %PYTHON_CMD% -m venv %WEB_SERVICE_VENV_NAME%
    ) else (
        echo Virtual environment %WEB_SERVICE_VENV_NAME% already exists. Not overwriting\n=========
    )
    cd ..

    echo for tkinter-client, it is called: %TKINTER_CLIENT_VENV_NAME%
    cd tkinter-client
    if not exist %TKINTER_CLIENT_VENV_NAME% (
        %PYTHON_CMD% -m venv %TKINTER_CLIENT_VENV_NAME%
    ) else (
        echo Virtual environment %TKINTER_CLIENT_VENV_NAME% already exists. Not overwriting\n=========
    )
    cd ..

    :: For expo apps, dependencies are installed by node in a local environment by default

    :: Steps 9: Install sub-project dependencies
    echo =========\nSteps 9: Installing sub-project dependencies\n=========

    echo   for web-service
    cd web-service
    call %WEB_SERVICE_VENV_NAME%\Scripts\activate
    pip install -r requirements.txt
    cd ..

    echo   for tkinter-client
    cd tkinter-client
    call %TKINTER_CLIENT_VENV_NAME%\Scripts\activate
    pip install -r requirements.txt
    cd ..

    echo   for expo-client
    cd expo-client
    npm install
    cd ..

    :: Pause for review
    pause
) >> %LOG_FILE% 2>&1