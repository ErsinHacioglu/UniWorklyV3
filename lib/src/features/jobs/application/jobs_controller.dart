// lib/src/features/jobs/application/jobs_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/jobs_repository.dart';
import '../domain/job_models.dart';
import '../domain/job_progress.dart'; // 👈 yeni: check-in/out ilerleme modeli

final jobsRepositoryProvider =
    Provider<JobsRepository>((ref) => MockJobsRepository());

class JobsState {
  final AsyncValue<List<Job>> jobs;
  final String search;
  final JobsFilter? filter; // null => hepsi görünür

  /// jobId -> JobProgress
  final Map<String, JobProgress> progressByJobId; // 👈 yeni alan

  const JobsState({
    required this.jobs,
    required this.search,
    required this.filter,
    this.progressByJobId = const {},
  });

  JobsState copyWith({
    AsyncValue<List<Job>>? jobs,
    String? search,
    JobsFilter? filter,
    bool clearFilter = false,
    Map<String, JobProgress>? progressByJobId,
  }) {
    return JobsState(
      jobs: jobs ?? this.jobs,
      search: search ?? this.search,
      filter: clearFilter ? null : (filter ?? this.filter),
      progressByJobId: progressByJobId ?? this.progressByJobId,
    );
  }
}

final jobsControllerProvider =
    StateNotifierProvider<JobsController, JobsState>((ref) {
  final repo = ref.watch(jobsRepositoryProvider);
  return JobsController(repo)..load();
});

class JobsController extends StateNotifier<JobsState> {
  final JobsRepository _repo;
  JobsController(this._repo)
      : super(const JobsState(
          jobs: AsyncValue.loading(),
          search: '',
          filter: null,
          progressByJobId: {},
        ));

  // -------------------- Data yükleme / rate --------------------

  Future<void> load() async {
    state = state.copyWith(jobs: const AsyncValue.loading());
    try {
      final items = await _repo.fetchMyJobs();
      state = state.copyWith(jobs: AsyncValue.data(items));
    } catch (e, st) {
      state = state.copyWith(jobs: AsyncValue.error(e, st));
    }
  }

  Future<void> rate(String jobId, int stars, {String? comment}) async {
    await _repo.rateEmployer(jobId: jobId, stars: stars, comment: comment);
    await load();
  }

  // -------------------- Arama/Filtre --------------------

  void setSearch(String q) => state = state.copyWith(search: q);

  void setFilter(JobsFilter? f) {
    if (f == state.filter) {
      state = state.copyWith(clearFilter: true); // aynıysa temizle
    } else {
      state = state.copyWith(filter: f);
    }
  }

  String _q() => state.search.trim().toLowerCase();

  Iterable<Job> _applySearch(Iterable<Job> it) {
    final s = _q();
    if (s.isEmpty) return it;
    return it.where((j) =>
        j.title.toLowerCase().contains(s) ||
        j.companyName.toLowerCase().contains(s));
  }

  Job? activeJob() {
    final list = state.jobs.value ?? [];
    final it = _applySearch(list.where((j) => j.status == JobStatus.active));
    final sorted = [...it]..sort((a, b) => a.startAt.compareTo(b.startAt));
    return sorted.isEmpty ? null : sorted.first;
  }

  List<Job> upcomingJobs() {
    final list = state.jobs.value ?? [];
    final it = _applySearch(list.where((j) => j.status == JobStatus.upcoming));
    final sorted = [...it]..sort((a, b) => a.startAt.compareTo(b.startAt));
    return sorted;
  }

  List<Job> pastJobs() {
    final list = state.jobs.value ?? [];
    final it = _applySearch(list.where((j) => j.status == JobStatus.past));
    final sorted = [...it]..sort((a, b) => b.endAt.compareTo(a.endAt)); // yakın -> uzak
    return sorted;
  }

  /// UI listesi: filter yoksa aktif(1) + upcoming + past ardışık
  List<Job> unifiedList() {
    final a = activeJob();
    final up = upcomingJobs();
    final pa = pastJobs();
    return [
      ...(a != null ? [a] : const []),
      ...up,
      ...pa,
    ];
  }

  // -------------------- Check-in / Check-out --------------------

  JobProgress _progressFor(String jobId) =>
      state.progressByJobId[jobId] ?? const JobProgress();

  bool isCheckedIn(String jobId) => _progressFor(jobId).isCheckedIn;
  bool isCompleted(String jobId) => _progressFor(jobId).isCompleted;

  /// Şimdilik 15 dk kuralı pasif 🚫
  bool canCheckInNow(Job j) {
    // final now = DateTime.now();
    // final openAt = j.startAt.subtract(const Duration(minutes: 15));
    // return now.isAfter(openAt) && now.isBefore(j.endAt);
    return true;
  }

  /// Mock doğrulama – şimdilik "1234" kabul.
  Future<bool> _verifyCheckCode(String jobId, String code) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return code.trim() == '1234';
  }

  /// Mock konum.
  Future<(double? lat, double? lng)> _getLocationSafe() async {
    try {
      return (41.015137, 28.979530); // İstanbul
    } catch (_) {
      return (null, null);
    }
  }

  Future<void> checkIn(Job job, {required String code}) async {
    // if (!canCheckInNow(job)) {
    //   throw StateError('Check-in, iş başlamadan 15 dk kala aktif olur.');
    // }
    final ok = await _verifyCheckCode(job.id, code);
    if (!ok) throw StateError('Kod/QR doğrulanamadı.');

    final (lat, lng) = await _getLocationSafe();
    final updated = Map<String, JobProgress>.from(state.progressByJobId);
    updated[job.id] = _progressFor(job.id).copyWith(
      checkInAt: DateTime.now(),
      checkInLat: lat,
      checkInLng: lng,
    );
    state = state.copyWith(progressByJobId: updated);
  }

  Future<void> checkOut(Job job, {required String code}) async {
    final ok = await _verifyCheckCode(job.id, code);
    if (!ok) throw StateError('Kod/QR doğrulanamadı.');

    final (lat, lng) = await _getLocationSafe();
    final updated = Map<String, JobProgress>.from(state.progressByJobId);
    updated[job.id] = _progressFor(job.id).copyWith(
      checkOutAt: DateTime.now(),
      checkOutLat: lat,
      checkOutLng: lng,
    );
    state = state.copyWith(progressByJobId: updated);

    // İş bitti -> geçmişe taşı
    final current = [...(state.jobs.value ?? [])];
    final idx = current.indexWhere((e) => e.id == job.id);
    if (idx != -1) {
      final updatedJob = current[idx].copyWith(
        status: JobStatus.past,
        outcome: JobOutcome.success,
      );
      current[idx] = updatedJob;
      state = state.copyWith(jobs: AsyncValue.data(current.cast<Job>()));
    }
  }
}
