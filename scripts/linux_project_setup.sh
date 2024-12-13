#!/bin/bash

# Define variables for easy configuration
# virtual environment names
WEB_SERVICE_VENV_NAME="web-service-env"
TKINTER_CLIENT_VENV_NAME="tkinter-client-env"
PROJECT_NAME="ai-chat-app"
# source repository
GITHUB_REPO="https://github.com/ingus-t/ai-chat-app.git"
# your own repository
ORIGIN_REPO="git@github.com:ingus-t/my-new-ai-chat-app.git"

# Get the current timestamp in a format suitable for file names: YYYY-MM-DD_HH-MM-SS
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# Set the log file name
LOG_FILE="logs/setup_log_$timestamp.txt"

# Create a logs folder if it doesn't exist
echo -e "=========\e[34m\n Step 0: Checking logs folder...\e[0m"
mkdir -p logs

# Redirect all output (stdout and stderr) to the log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Step 1: Check if Git is installed
echo -e "=========\e[34m\nStep 1: Checking if Git is installed...\e[0m"
if ! git --version &>/dev/null
then
    echo "\e[31m Git is not installed."
    echo "Please run this script again after installing Git.\e[0m"
    exit 1
else
    node_version=$(git --version)
    echo "git version: $node_version"
fi

# Step 2: Check if Python is installed
echo -e "=========\e[34m\nStep 2: Checking if Python is installed...\e[0m"
if ! python3 --version &>/dev/null
then
    echo "Python is not installed."
    echo "Please run this script again after installing Python.\e[0m"
    exit 1
else
    echo "Python is installed as 'python3'."
    node_version=$(python3 --version)
    echo "python3 version: $node_version"
    PYTHON_CMD="python3"
fi

echo "Using Python command: $PYTHON_CMD"

# Step 3: Check if Node.js is installed
echo -e "=========\e[34m\nStep 3: Checking if Node.js is installed...\e[0m"
if ! command -v node &> /dev/null
then
    echo "\e[31m Node.js is not installed."
    echo "Please install Node.js and run this script again.\e[0m"
    exit 1
else
    node_version=$(node --version)
    echo "Node.js version: $node_version"
fi

# Step 4: Check if npm is installed
echo -e "=========\e[34m\nStep 4: Checking if npm is installed...\e[0m"
if ! command -v npm &> /dev/null
then
    echo "\e[31m npm is not installed."
    echo "Please install npm and run this script again.\e[0m"
    exit 1
else
    npm_version=$(npm --version)
    echo "npm version: $npm_version"
fi

# Step 5: Clone the repository
echo -e "=========\e[34m\nStep 5: Cloning the GitHub repository...\e[0m"
if ! git clone "$GITHUB_REPO"; then
    echo "Failed to clone the repository. Check your internet connection or the repository URL."
    exit 1
fi
cd "$PROJECT_NAME" || exit

# Step 6: Set student's GitHub repository as origin
echo -e "=========\e[34m\nStep 6: Setting your own repository as the origin...\e[0m"

# git remote add origin "$ORIGIN_REPO"
# git remote -v

# Check if the last command was successful
if [ $? -ne 0 ]; then
    # If there was an error, display the error message in red
    echo -e "\e[31mError: Failed to add remote origin. Please check the repository URL.\e[0m"
else
    # If successful, show the remote details
    git remote -v
fi


# Step 7: GitHub global credential configuration
# Ask user if they want to save GitHub credentials globally
echo -e "=========\e[34m\nStep 7: GitHub credentials\e[0m"
read -p "Do you want to save your GitHub credentials globally? (y/n): " SAVE_GLOBAL

if [[ "$SAVE_GLOBAL" == "y" ]]; then
    echo "Please enter your GitHub details."

    # Prompt for GitHub credentials
    read -p "Enter your GitHub username: " GITHUB_USERNAME
    read -p "Enter your GitHub email: " GITHUB_EMAIL

    # Save GitHub username and email globally
    git config --global user.name "$GITHUB_USERNAME"
    git config --global user.email "$GITHUB_EMAIL"

    echo "GitHub credentials have been configured globally."
else
    echo "Skipping global GitHub credentials setup. Ensure you have configured authentication via SSH or other methods."
fi

# Step 8: Create the virtual environments
echo -e "=========\e[34m\nStep 8: Creating virtual environments...\e[0m"

create_venv() {
    local venv_name=$1
    if [[ ! -d "$venv_name" ]]; then
        echo "Creating virtual environment: $venv_name"
        $PYTHON_CMD -m venv "$venv_name"
    else
        echo "Virtual environment $venv_name already exists. Not overwriting...\e[0m"
    fi
}

cd web-service
create_venv "$WEB_SERVICE_VENV_NAME"
cd ..

cd tkinter-client
create_venv "$TKINTER_CLIENT_VENV_NAME"
cd ..

# Step 9: Install sub-project dependencies
echo -e "=========\e[34m\nStep 9: Installing sub-project dependencies...\e[0m"

install_dependencies() {
    local venv_name=$1
    source "$venv_name/bin/activate"
    pip install -r requirements.txt
    deactivate
}

cd web-service
echo -e "=========\e[34m\n Step 9.1 Installing dependencies for $WEB_SERVICE_VENV_NAME...\e[0m"
install_dependencies "$WEB_SERVICE_VENV_NAME"
cd ..

cd tkinter-client
echo -e "=========\e[34m\n Step 9.2 Installing dependencies for $TKINTER_CLIENT_VENV_NAME...\e[0m"
install_dependencies "$TKINTER_CLIENT_VENV_NAME"
cd ..

cd expo-client
echo -e "=========\e[34m\n Step 9.3 Installing dependencies for Expo client...\e[0m"
npm install
cd ..

# Unset GitHub credential variables
echo -e "=========\e[34m\n Unsetting GitHub credential vars...\e[0m"
unset GITHUB_USERNAME
unset GITHUB_EMAIL
unset GITHUB_PASSWORD

echo "Setup complete! Review the log file at $LOG_FILE"
