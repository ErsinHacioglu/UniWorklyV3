import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/jobs_repository.dart';
import '../domain/job_models.dart';

final jobsRepositoryProvider = Provider<JobsRepository>((ref) => MockJobsRepository());

class JobsState {
  final AsyncValue<List<Job>> jobs;
  final String search;
  final JobsFilter? filter; // null => hepsi görünür

  const JobsState({
    required this.jobs,
    required this.search,
    required this.filter,
  });

  JobsState copyWith({
    AsyncValue<List<Job>>? jobs,
    String? search,
    JobsFilter? filter,
    bool clearFilter = false,
  }) {
    return JobsState(
      jobs: jobs ?? this.jobs,
      search: search ?? this.search,
      filter: clearFilter ? null : (filter ?? this.filter),
    );
  }
}

final jobsControllerProvider = StateNotifierProvider<JobsController, JobsState>((ref) {
  final repo = ref.watch(jobsRepositoryProvider);
  return JobsController(repo)..load();
});

class JobsController extends StateNotifier<JobsState> {
  final JobsRepository _repo;
  JobsController(this._repo)
      : super(const JobsState(jobs: AsyncValue.loading(), search: '', filter: null));

  Future<void> load() async {
    state = state.copyWith(jobs: const AsyncValue.loading());
    try {
      final items = await _repo.fetchMyJobs();
      state = state.copyWith(jobs: AsyncValue.data(items));
    } catch (e, st) {
      state = state.copyWith(jobs: AsyncValue.error(e, st));
    }
  }

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
      ... (a != null ? [a] : const []),
      ...up,
      ...pa,
    ];
  }

  Future<void> rate(String jobId, int stars, {String? comment}) async {
    await _repo.rateEmployer(jobId: jobId, stars: stars, comment: comment);
    await load();
  }
}
