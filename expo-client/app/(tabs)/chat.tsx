import React, { useState, useEffect } from 'react';
import { View, TextInput, Button, FlatList, Text, StyleSheet } from 'react-native';
import axios from 'axios'; // or use fetch
import config from '../../config.json'; // Adjust path if needed

const ChatScreen = () => {
  const [message, setMessage] = useState('');
  const [threadId, setThreadId] = useState('123456'); // Use the actual thread ID in a real scenario
  const [chatHistory, setChatHistory] = useState([]);
  const apiUrl = config.API_URL; // Read from config file

  // Function to fetch conversation history
  const fetchConversationHistory = async () => {
    try {
      const response = await axios.get(`${apiUrl}/conversation-history/?thread_id=${threadId}`);

      setChatHistory(response.data.conversation_history);
    } catch (error) {
      console.error('Error fetching conversation history:', error);
    }
  };

  // Fetch conversation history when the component mounts
  useEffect(() => {
    fetchConversationHistory();
  }, []);

  // Function to handle sending a message
  const sendMessage = async () => {
    if (message.trim() === '') return; // Don't send empty messages

    try {
      // Send the message to the API
      const response = await axios.post(`${apiUrl}/send-message/?thread_id=${threadId}&message=${message}`);

      // Add both the user message and assistant response to the chat history
      setChatHistory(prevHistory => [
        ...prevHistory,
        { sender: 'user', content: message },
        { sender: 'assistant', content: response.data.response }
      ]);

      // Clear the message input after sending
      setMessage('');
    } catch (error) {
      console.error('Error sending message:', error);
    }
  };

  // Render a single chat message
  const renderMessageItem = ({ item }) => (
    <View style={[styles.messageContainer, item.sender === 'user' ? styles.userMessage : styles.assistantMessage]}>
      <Text>{item.content}</Text>
    </View>
  );

  return (
    <View style={styles.container}>
      {/* Chat history */}
      <FlatList
        data={chatHistory}
        renderItem={renderMessageItem}
        keyExtractor={(item, index) => index.toString()}
        style={styles.chatHistory}
      />

      {/* Message input */}
      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          value={message}
          onChangeText={setMessage}
          placeholder="Type your message..."
        />
        <Button title="Send" onPress={sendMessage} />
      </View>
    </View>
  );
};

// Styles for the chat screen
const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 10
  },
  chatHistory: {
    flex: 1,
    marginBottom: 10
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center'
  },
  input: {
    flex: 1,
    borderColor: '#ccc',
    borderWidth: 1,
    padding: 10,
    borderRadius: 5,
    marginRight: 10
  },
  messageContainer: {
    padding: 10,
    borderRadius: 5,
    marginVertical: 5
  },
  userMessage: {
    backgroundColor: '#dcf8c6',
    alignSelf: 'flex-end'
  },
  assistantMessage: {
    backgroundColor: '#f1f1f1',
    alignSelf: 'flex-start'
  }
});

export default ChatScreen;
