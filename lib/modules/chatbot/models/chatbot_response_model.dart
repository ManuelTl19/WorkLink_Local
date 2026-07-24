class ChatbotResponseModel {
  final String provider;
  final String model;
  final String mode;
  final int? userId;
  final String reply;

  const ChatbotResponseModel({
    required this.provider,
    required this.model,
    required this.mode,
    required this.reply,
    this.userId,
  });

  factory ChatbotResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return ChatbotResponseModel(
      provider: _stringValue(data['provider'] ?? json['provider']),
      model: _stringValue(data['model'] ?? json['model']),
      mode: _stringValue(data['mode'] ?? json['mode']),
      userId: _intNullable(
        data['user_id'] ?? data['userId'] ?? json['user_id'] ?? json['userId'],
      ),
      reply: _stringValue(
        data['reply'] ??
            data['message'] ??
            data['content'] ??
            json['reply'] ??
            json['message'],
      ),
    );
  }

  static String _stringValue(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static int? _intNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
