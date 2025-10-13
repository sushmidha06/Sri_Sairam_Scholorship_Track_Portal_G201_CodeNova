class Scholarship {
  final String title;
  final String eligibility;
  final DateTime deadline;
  final String tag; // New, Closing Soon, Popular

  Scholarship({
    required this.title,
    required this.eligibility,
    required this.deadline,
    this.tag = '',
  });
}
