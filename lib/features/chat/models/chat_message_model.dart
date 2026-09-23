class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.message,
    required this.time,
    required this.isMine,
  });

  final String id;
  final String message;
  final String time;
  final bool isMine;
}