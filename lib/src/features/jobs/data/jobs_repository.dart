// lib/src/features/jobs/data/jobs_repository.dart
import '../domain/job_models.dart';

abstract class JobsRepository {
  Future<List<Job>> fetchMyJobs();
  Future<void> rateEmployer({required String jobId, required int stars, String? comment});
}

class MockJobsRepository implements JobsRepository {
  List<Job> _items = [
    Job(
      id: '1',
      title: 'Etkinlik Karşılama Görevlisi',
      companyName: 'EventX',
      startAt: DateTime(2025, 9, 24, 19, 29),
      endAt:   DateTime(2025, 9, 24, 23, 29),
      status: JobStatus.active,
    ),
    Job(
      id: '2',
      title: 'Depo Sayım',
      companyName: 'LogiCo',
      startAt: DateTime(2025, 9, 26, 20, 29),
      endAt:   DateTime(2025, 9, 27, 2, 29),
      status: JobStatus.upcoming,
    ),
    Job(
      id: '3',
      title: 'Kafe Servis',
      companyName: 'Cafe Nox',
      startAt: DateTime(2025, 9, 20, 18, 00),
      endAt:   DateTime(2025, 9, 20, 23, 30),
      status: JobStatus.past,
      outcome: JobOutcome.success,
      isRated: true,
      myRating: EmployerRating(stars: 4),
    ),
    Job(
      id: '4',
      title: 'Stand Görevlisi',
      companyName: 'PromoLab',
      startAt: DateTime(2025, 9, 12, 14, 04),
      endAt:   DateTime(2025, 9, 12, 20, 04),
      status: JobStatus.past,
      outcome: JobOutcome.failed,
      isRated: false,
    ),
  ];

  @override
  Future<List<Job>> fetchMyJobs() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _items;
  }

  @override
  Future<void> rateEmployer({required String jobId, required int stars, String? comment}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _items = _items.map((j) {
      if (j.id == jobId) {
        return Job(
          id: j.id,
          title: j.title,
          companyName: j.companyName,
          startAt: j.startAt,
          endAt: j.endAt,
          status: j.status,
          outcome: j.outcome,
          isRated: true,
          myRating: EmployerRating(stars: stars, comment: comment),
        );
      }
      return j;
    }).toList();
  }
}
