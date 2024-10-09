import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final bool isRead;

  Message({required this.senderId, required this.receiverId, required this.message, required this.timestamp, this.isRead = false});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      message: map['message'],
      timestamp: map['timestamp'],
      isRead: map['isRead'] ?? false,
    );
  }
}
