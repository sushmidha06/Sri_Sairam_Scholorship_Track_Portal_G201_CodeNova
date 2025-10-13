

// ==================== data/scholarship_data.dart ====================
import 'package:scholarship/feature/Main_user/Main_page/Search_Page/models/scholarship.dart';

class ScholarshipData {
  static List<Scholarship> getScholarships() {
    return [
      Scholarship(
        id: 1,
        name: 'Merit Excellence Scholarship',
        amount: 5000,
        deadline: DateTime(2025, 12, 31),
        category: 'Merit-based',
        eligibility: 'GPA 3.5+',
        description: 'Annual scholarship for outstanding academic performance',
      ),
      Scholarship(
        id: 2,
        name: 'STEM Innovation Award',
        amount: 7500,
        deadline: DateTime(2025, 11, 15),
        category: 'STEM',
        eligibility: 'Science/Tech majors',
        description: 'Supporting future innovators in STEM fields',
      ),
      Scholarship(
        id: 3,
        name: 'Community Service Grant',
        amount: 3000,
        deadline: DateTime(2026, 1, 20),
        category: 'Service',
        eligibility: '100+ volunteer hours',
        description: 'Recognizing dedication to community service',
      ),
      Scholarship(
        id: 4,
        name: 'Arts & Humanities Scholarship',
        amount: 4500,
        deadline: DateTime(2025, 10, 30),
        category: 'Arts',
        eligibility: 'Arts/Humanities majors',
        description: 'Supporting creative and cultural studies',
      ),
      Scholarship(
        id: 5,
        name: 'First Generation Success Award',
        amount: 6000,
        deadline: DateTime(2025, 12, 15),
        category: 'Need-based',
        eligibility: 'First-gen college students',
        description: 'Empowering first-generation college students',
      ),
    ];
  }
}