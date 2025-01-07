class FeedbackMessage{
  String id;
  DateTime sendTime;
  String senderId;
  String receiverId;
  String messageText;
  String imageUrl;

  FeedbackMessage({
    required this.id,
    required this.sendTime,
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    required this.imageUrl
  });

  factory FeedbackMessage.empty(){
    return FeedbackMessage(
        id: '',
        sendTime: DateTime.now(),
        senderId: '',
        receiverId: '',
        messageText: '',
        imageUrl: ''
    );
  }

}