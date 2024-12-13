## Purpose
This example app implements a web service and multiple client apps.

## Project structure
```
project_folder/
│
├── expo-client		# Mobile app example, it consumes the web service
├── scripts		    # scripts for installing Git, Python, creating environments, etc.
├── tkinter-client	# GUI app example, it consumes the web service
├── web-service		# FastAPI web service app with 2 methods
└── README.md
```

## Project setup
### Option 1: Locally on Windows
Download the setup file `windows_project_setup.bat` from /scripts/ folder, and put it in the directory where you want the GitHub repo to be cloned.  

Change the value of ORIGIN_REPO at the start of the file, to your own repository.  

Execute the script `windows_project_setup.bat`. You should run it in administrator mode.
To run it, double-click on the file, or navigate to the project folder in the terminal and run:
```
windows_project_setup.bat
```

### Option 2: Locally on Linux
Download the setup file  `linux_project_setup.sh` from /scripts/ folder, and put it in the directory where you want the GitHub repo to be cloned.  

Change the value of ORIGIN_REPO at the start of the file, to your own repository.  

Make the script executable
```
chmod +x linux_project_setup.sh
```

Execute the script:
```
./linux_project_setup.bat.sh
```

### Option 3: replit.com platform
Do not use the scripts from /scripts folder, they are intended to be run on Windows/Linux locally, and not Replit platform

`web-service` and `tkinter-client` can be easily set up in Replit, `expo-client` cannot.

1. Have a GitHub account
2. Have a replit.com account
3. Import code from this repository to your Replit account
Suggestion - fork this repository on GitHub, and clone your copy of it.
```
git clone https://github.com/REPOSITORY-USERNAME/REPOSITORY-NAME
```

~~5. Create an environment if needed~~
```
python -m venv your-new-env
```
~~6. Activate environment (create one if it does not exist)~~
Windows:
```
your-new-env\Scripts\activate
```
Linux
```
source your-new-env/bin/activate
```

7. Install dependencies
```
pip install -r requirements.txt
```
8. Start the project (refer to instructions from the sub-project readme file)\
expo-client/README.md
tkinter-client/README.md
web-service-client/README.md

9. Add your repository as a remote, and commit your changes there
Useful commands
```
git remote -v                                                                 # View existing remotes
git remote add origin https://github.com/USERNAME/REPOSITORY_NAME.git         # Add a new remote called 'origin'
git remote set-url origin https://github.com/USERNAME/REPOSITORY_NAME.git     # Change URL for remote called 'origin'
```

## Remove git credentials if you are on a public laptop
Run the correct file from the `scripts` folder.

## Notes

##  $${\color{red}Important! \space Sensitive \space information \space should \space not\space be \space committed \space to \space the \space GitHub \space repository \space }$$  

Usernames, passwords, SSH keys, API keys (OPEN_AI API key!) must not be committed to your repository, even if it is private.  
Such values could be stored in .env, .config, and other files. You would create these files on the server manually, your app would read sensitive parameters from these files.  
You could include an example .env file in your project, however, called .env_example, with dummy values such as:
```
openai_key = abc123
```
These files must be specified in your .gitignore file.

### One repository for the web service and multiple clients
In this repository, the web service and client apps are bundled together. In most cases, it is better to separate projects into separate repositories. Consider that for your future projects.  
Each of these projects uses a separate environment because a GUI app and a backend web service have different requirements/dependencies and this is how it (often) works in real-life scenarios.  

### Environment management
Sub-projects use `venv` for this purpose. [uv](https://github.com/astral-sh/uv), [Poetry](https://python-poetry.org/) and other alternatives are better, but these would have to be installed (another step during setup). Consider using an alternative for your personal projects in the future.

### GUI clients
You could use [https://github.com/ParthJadhav/Tkinter-Designer](https://github.com/ParthJadhav/Tkinter-Designer) to first design a very user-friendly UI in Figma, and then import and use it for your app.  
You could also use an entirely different framework for building your Desktop app, for example:
* PyQt / PySide (Python bindings for the Qt framework)
* Kivy
* PyGame (intended for game development)
* etc.
