import 'package:equatable/equatable.dart';

enum JobStatus { active, upcoming, past }
enum JobsFilter { active, upcoming, past }
enum JobOutcome { success, failed } // geçmiş işler için sonuç

class EmployerRating extends Equatable {
  final int stars; // 1..5
  final String? comment;
  const EmployerRating({required this.stars, this.comment});

  @override
  List<Object?> get props => [stars, comment];
}

class Job extends Equatable {
  final String id;
  final String title;
  final String companyName;
  final DateTime startAt;
  final DateTime endAt;
  final JobStatus status;
  final bool isRated;
  final EmployerRating? myRating;
  final JobOutcome outcome;

  const Job({
    required this.id,
    required this.title,
    required this.companyName,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.isRated = false,
    this.myRating,
    this.outcome = JobOutcome.success, // default success
  });

  /// Sadece başarıyla tamamlanan işler değerlendirilebilir
  bool get canRate =>
      status == JobStatus.past &&
      outcome == JobOutcome.success &&
      !isRated;

  @override
  List<Object?> get props => [
        id,
        title,
        companyName,
        startAt,
        endAt,
        status,
        isRated,
        myRating,
        outcome,
      ];
}
