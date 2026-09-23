import '../models/chat_model.dart';

const demoChats = [
  ChatModel(
    id: '1',
    name: 'Suman Rai',
    lastMessage: 'Are you still available to donate?',
    time: '2m',
    unreadCount: 2,
    isOnline: true,
  ),
  ChatModel(
    id: '2',
    name: 'Anisha Thapa',
    lastMessage: 'Thank you for helping!',
    time: '1h',
    isOnline: true,
  ),
  ChatModel(
    id: '3',
    name: 'Rajesh K.',
    lastMessage: 'I can donate tomorrow.',
    time: 'Yesterday',
  ),
  ChatModel(
    id: '4',
    name: 'Priya Sharma',
    lastMessage: 'Please let me know when you arrive.',
    time: 'Mon',
    unreadCount: 1,
  ),
];