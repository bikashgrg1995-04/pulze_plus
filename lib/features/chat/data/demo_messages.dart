import '../models/chat_message_model.dart';

const demoMessages = {
  '1': [
    ChatMessageModel(
      id: '1-1',
      message: 'Hi Bikash, are you still available to donate?',
      time: '10:41 AM',
      isMine: false,
    ),
    ChatMessageModel(
      id: '1-2',
      message: 'Yes, I am available.',
      time: '10:42 AM',
      isMine: true,
    ),
    ChatMessageModel(
      id: '1-3',
      message: 'That’s great. We have an urgent O+ request nearby.',
      time: '10:42 AM',
      isMine: false,
    ),
    ChatMessageModel(
      id: '1-4',
      message: 'Sure, I can help. Please share the details.',
      time: '10:43 AM',
      isMine: true,
    ),
    ChatMessageModel(
      id: '1-5',
      message: 'Thank you so much! ❤️',
      time: '10:44 AM',
      isMine: false,
    ),
  ],

  '2': [
    ChatMessageModel(
      id: '2-1',
      message: 'Hi Bikash!',
      time: '9:20 AM',
      isMine: false,
    ),
    ChatMessageModel(
      id: '2-2',
      message: 'Hello Anisha, how are you?',
      time: '9:22 AM',
      isMine: true,
    ),
    ChatMessageModel(
      id: '2-3',
      message: 'I’m good. Thank you for helping yesterday.',
      time: '9:23 AM',
      isMine: false,
    ),
    ChatMessageModel(
      id: '2-4',
      message: 'You’re welcome. Happy to help.',
      time: '9:25 AM',
      isMine: true,
    ),
  ],

  '3': [
    ChatMessageModel(
      id: '3-1',
      message: 'Hi Bikash, I can donate tomorrow.',
      time: 'Yesterday',
      isMine: false,
    ),
    ChatMessageModel(
      id: '3-2',
      message: 'That would be great.',
      time: 'Yesterday',
      isMine: true,
    ),
    ChatMessageModel(
      id: '3-3',
      message: 'Please let me know the location.',
      time: 'Yesterday',
      isMine: false,
    ),
  ],

  '4': [
    ChatMessageModel(
      id: '4-1',
      message: 'Hi Bikash, are you nearby?',
      time: '10:15 AM',
      isMine: false,
    ),
    ChatMessageModel(
      id: '4-2',
      message: 'Yes, I am nearby.',
      time: '10:17 AM',
      isMine: true,
    ),
    ChatMessageModel(
      id: '4-3',
      message: 'Please let me know when you arrive.',
      time: '10:18 AM',
      isMine: false,
    ),
  ],
};