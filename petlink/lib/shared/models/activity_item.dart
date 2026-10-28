class ActivityItem {
  final String id;
  final String? reportId;
  final String type;
  final String title;
  final String? body;
  final String status;
  final String reportType;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const ActivityItem({
    required this.id,
    this.reportId,
    required this.type,
    required this.title,
    this.body,
    required this.status,
    required this.reportType,
    this.isRead = true,
    this.readAt,
    required this.createdAt,
  });

  String get targetReportId =>
      (reportId != null && reportId!.isNotEmpty) ? reportId! : id;

  bool get isNotification => type != 'report';

  ActivityItem copyWith({
    String? id,
    String? reportId,
    String? type,
    String? title,
    String? body,
    String? status,
    String? reportType,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return ActivityItem(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      reportType: reportType ?? this.reportType,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    final readAtStr = json['readAt'] as String?;
    final readAt = readAtStr != null ? DateTime.tryParse(readAtStr) : null;
    final isReadExplicit = json['isRead'] as bool?;

    return ActivityItem(
      id: json['id'] as String? ?? '',
      reportId: json['reportId'] as String?,
      type: json['type'] as String? ?? 'report',
      title: json['title'] as String? ?? 'Actividad',
      body: json['body'] as String?,
      status: json['status'] as String? ?? 'active',
      reportType: json['reportType'] as String? ?? 'lost',
      isRead: isReadExplicit ?? (readAt != null || (json['type'] as String? ?? 'report') == 'report'),
      readAt: readAt,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
