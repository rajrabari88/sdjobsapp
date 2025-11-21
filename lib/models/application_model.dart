class ApplicationModel {
  final int id;
  final int jobId;
  final String title;
  final String company;
  final String status; // applied / pending / reviewed / rejected
  final String createdAt;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.title,
    required this.company,
    required this.status,
    required this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: int.parse(json['id'].toString()),
      jobId: int.parse(json['job_id'].toString()),
      title: json['title'] ?? 'No Title',
      company: json['company'] ?? 'Unknown',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
    );
  }
}
