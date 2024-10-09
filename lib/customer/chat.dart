import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _firestore.collection('chat').add({
        'text': _messageController.text,
        'senderId': _currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear(); // Clear input after sending
    }
  }

  Stream<QuerySnapshot> _getMessages() {
    return _firestore
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Show latest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == _currentUser?.uid;

                    return ListTile(
                      title: Text(
                        message['text'],
                        style: TextStyle(
                          color: isMe ? Colors.blue : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        isMe ? 'You' : 'Customer',
                        style: TextStyle(
                          color: isMe ? Colors.blue : Colors.black54,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
