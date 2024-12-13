from fastapi import FastAPI
from pydantic import BaseModel
import json
import openai
import random
import os
import time
import sqlite3
import sys
import os

openai.api_key = "123"

app = FastAPI()

# Model for a single message
class Message(BaseModel):
    role: str
    content: str
    api_key: str

def wait_for_run_to_finish(thread_id, run):
    timer = 0
    while True:
        runs = openai.beta.threads.runs.list(thread_id=thread_id)
        active_runs = [run for run in runs.data if run.status not in ["completed", "failed"]]
        if not active_runs:
            break
        time.sleep(5)
        timer += 1
        if timer == 2:
            openai.beta.threads.runs.cancel(thread_id=thread_id, run_id=run.id)
            break

def initialize_database(cursor):
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER,
        city TEXT
    )
    ''')

def add_record(cursor):
    cursor.execute('''
    INSERT INTO users (name, age, city)
    VALUES ('Joel', 35, 'New York')
    ''')
    response = fetch_record(cursor)
    return response

def fetch_record(cursor):
    cursor.execute('SELECT * FROM users')
    response = cursor.fetchall()
    return response

def modify_record(cursor):
    cursor.execute('''
    UPDATE users
    SET name = 'Joe Doe'
    WHERE name = 'Joel'
    ''')
    response = fetch_record(cursor)
    return response

def remove_record(cursor):
    cursor.execute('''
    DELETE FROM users
    WHERE name = 'Joel'
    ''')
    response = "Successfully deleted"
    return response
    
tools = [
    {
        "type": "function",
        "function": {
            "name": "add_record",
            "description": "Adds a record into the database",
            "parameters": {
                "type": "object",
                "properties": {},
                "required": []
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "fetch_record",
            "description": "Fetch a record from the database",
            "parameters": {
                "type": "object",
                "properties": {},
                "required": []
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "modify_record",
            "description": "Updates a record in the database",
            "parameters": {
                "type": "object",
                "properties": {},
                "required": []
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "remove_record",
            "description": "Deletes a record in the database",
            "parameters": {
                "type": "object",
                "properties": {},
                "required": []
            }
        }
    }
]

# Receive a dummy message and return a test response from the virtual assistant
@app.post("/send-message/")
async def process_message_and_respond(thread_id: str, message: str):
    
    assistant = openai.beta.assistants.create(
        name="Custom Tool Assistant",
        instructions="You are an assistant with access to custom tools.",
        model="gpt-4o-mini",
        tools=tools
    )
    thread = openai.beta.threads.create()
    message = openai.beta.threads.messages.create(
        thread_id=thread.id,
        role="user",
        content=message
    )
    
    run = openai.beta.threads.runs.create(
        thread_id=thread.id,
        assistant_id=assistant.id
    )

    attempt = 1
    while run.status != "completed":
        print(f"Run status: {run.status}, attempt: {attempt}")
        run = openai.beta.threads.runs.retrieve(thread_id=thread.id, run_id=run.id)

        if run.status == "requires_action":
            break

        if run.status == "failed":
            if hasattr(run, 'last_error') and run.last_error is not None:
                error_message = run.last_error.message
            else:
                error_message = "No error message found..."

            print(f"Run {run.id} failed! Status: {run.status}\n  thread_id: {run.thread_id}\n  assistant_id: {run.assistant_id}\n  error_message: {error_message}")
            print(str(run))

        attempt += 1
        time.sleep(5)

    if run.status == "requires_action":
        print("Run requires action, assistant wants to use a tool")

    conn = sqlite3.connect('user_data.db')
    cursor = conn.cursor()
    initialize_database(cursor)

    if run.required_action:
        tool_outputs = []
        for tool_call in run.required_action.submit_tool_outputs.tool_calls:
            if tool_call.function.name == "fetch_record":
                print("  fetch_record called")
                output = fetch_record(cursor)
            elif tool_call.function.name == "remove_record":
                print("  remove_record called")
                output = remove_record(cursor)
                conn.commit()
            elif tool_call.function.name == "add_record":
                print("  add_record called")
                output = add_record(cursor)
                conn.commit()
            elif tool_call.function.name == "modify_record":
                print("  modify_record called")
                output = modify_record(cursor)
                conn.commit()
            else:
                print("Unknown function call")
            print(f"  Generated output: {output}")

            tool_outputs.append({
                "tool_call_id": tool_call.id,
                "output": str(output)
            })

        openai.beta.threads.runs.submit_tool_outputs(
            thread_id=thread.id,
            run_id=run.id,
            tool_outputs=tool_outputs
        )

    conn.close()

    if run.status == "requires_action":
        run = openai.beta.threads.runs.retrieve(thread_id=thread.id, run_id=run.id)
        attempt = 1
        while run.status not in ["completed", "failed"]:
            print(f"Run status: {run.status}, attempt: {attempt}")
            time.sleep(2)
            run = openai.beta.threads.runs.retrieve(thread_id=thread.id, run_id=run.id)
            attempt += 1

    if run.status == "completed":
        messages = openai.beta.threads.messages.list(thread_id=thread.id)
        final_answer = messages.data[0].content[0].text.value
    elif run.status == "failed":
        if hasattr(run, 'last_error') and run.last_error is not None:
            error_message = run.last_error.message
        else:
            error_message = "No error message found..."

        print(f"Run {run.id} failed! Status: {run.status}\n  thread_id: {run.thread_id}\n  assistant_id: {run.assistant_id}\n  error_message: {error_message}")
        print(str(run))
    else:
        print(f"Unexpected run status: {run.status}")

    return {
        "thread_id": thread.id,
        "response": final_answer,
        "message_received": message
    }


# Retrieve a conversation history based on the thread ID, 5 messages from the user, 5 from the assistant
@app.get("/conversation-history/")
async def conversation_history(thread_id: str):
    """
    Retrieve the conversation history for a specific thread.

    Args:
        thread_id (str): The ID of the conversation thread.

    Returns:
        dict: A dictionary containing the thread ID and a list of conversation messages, including both user and assistant messages.
    """

    # Fill the message history with dummy messages
    user_messages = [f"User message {i} in thread {thread_id}" for i in range(1, 6)]
    assistant_messages = [f"Assistant message {i} in thread {thread_id}" for i in range(1, 6)]
    conversation_history = []
    for i in range(5):
        conversation_history.append({"sender": "user", "content": user_messages[i]})
        conversation_history.append({"sender": "assistant", "content": assistant_messages[i]})

    return {
        "thread_id": thread_id,
        "conversation_history": conversation_history
    }

