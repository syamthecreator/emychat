class EmyMessage {
  const EmyMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.sources = const [],
    this.isError = false,
  });

  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime createdAt;
  final List<String> sources;
  final bool isError;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory EmyMessage.fromJson(Map<String, dynamic> json) {
    final rawSources = json['sources'];
    final sources = rawSources is List
        ? rawSources.map((e) => e.toString()).toList()
        : <String>[];

    return EmyMessage(
      id: (json['id'] ?? DateTime.now().microsecondsSinceEpoch.toString())
          .toString(),
      role: (json['role'] ?? 'assistant').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      sources: sources,
    );
  }
}

class EmyDocument {
  const EmyDocument({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.status,
    required this.chunkCount,
    required this.createdAt,
    this.errorMessage,
  });

  final String id;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final String status;
  final int chunkCount;
  final DateTime createdAt;
  final String? errorMessage;

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory EmyDocument.fromJson(Map<String, dynamic> json) {
    return EmyDocument(
      id: (json['id'] ?? '').toString(),
      fileName: (json['fileName'] ?? 'Document').toString(),
      mimeType: (json['mimeType'] ?? '').toString(),
      fileSize: (json['fileSize'] is num)
          ? (json['fileSize'] as num).toInt()
          : 0,
      status: (json['status'] ?? 'READY').toString(),
      chunkCount: (json['chunkCount'] is num)
          ? (json['chunkCount'] as num).toInt()
          : 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      errorMessage: json['errorMessage']?.toString(),
    );
  }
}
