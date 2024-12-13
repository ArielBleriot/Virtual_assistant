## Purpose
This is a desktop client GUI example app, built with tkinter.

## Project structure
```
tkinter-client/
│
├── app/
│   ├── __init__.py
│   ├── chat.py         # Main chat app file
│   ├── config.json     # set API URL and GPT thread ID here
│
├── .gitignore          # Add filenames you do not want to be added to your repository here
├── requirements.txt    # Dependencies
└── README.md           # The file you are reading right now :)
```

## Project setup
Use the setup .bat file from the scripts folder.

### Activate environment
Linux:  
```
source your_environment_name/bin/activate
```
Windows:  
```
your_environment_name\Scripts\activate
```

### .gitignore file
Add your environment folder, and "/app/__pycache__/" to the project .gitignore file. The contents of these folders should not be committed to your repository. These files are generated automatically.

### Start the app
```
python app/chat.py
```
or  
```
python3 app/chat.py
```
