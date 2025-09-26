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

  /// copyWith eklendi ✅
  Job copyWith({
    String? id,
    String? title,
    String? companyName,
    DateTime? startAt,
    DateTime? endAt,
    JobStatus? status,
    bool? isRated,
    EmployerRating? myRating,
    JobOutcome? outcome,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      status: status ?? this.status,
      isRated: isRated ?? this.isRated,
      myRating: myRating ?? this.myRating,
      outcome: outcome ?? this.outcome,
    );
  }

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
