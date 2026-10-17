class ActivityItem {
  final String id;
  final String type;
  final String title;
  final String? body;
  final String status;
  final String reportType;
  final DateTime createdAt;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    required this.status,
    required this.reportType,
    required this.createdAt,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) => ActivityItem(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? 'report',
        title: json['title'] as String? ?? 'Actividad',
        body: json['body'] as String?,
        status: json['status'] as String? ?? 'active',
        reportType: json['reportType'] as String? ?? 'lost',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
