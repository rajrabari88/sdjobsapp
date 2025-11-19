class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type;
  final String logoText;
  final String experience;
  bool isSaved;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.logoText,
    this.experience = '2-5 yrs',
    this.isSaved = false,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary'] ?? '',
      type: json['type'] ?? '',
      experience: json['experience'] ?? '2-5 yrs',
      logoText: (json['company'] ?? 'J').substring(0, 1).toUpperCase(),
      isSaved: json['is_saved'] == 1 || json['is_saved'] == true,
    );
  }
}
