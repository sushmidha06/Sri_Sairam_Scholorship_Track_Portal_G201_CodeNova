
// ==================== models/scholarship.dart ====================
class Scholarship {
  final int id;
  final String name;
  final double amount;
  final DateTime deadline;
  final String category;
  final String eligibility;
  final String description;

  Scholarship({
    required this.id,
    required this.name,
    required this.amount,
    required this.deadline,
    required this.category,
    required this.eligibility,
    required this.description,
  });
}