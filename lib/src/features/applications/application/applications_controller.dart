import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/applications_repository.dart';
import '../domain/application_models.dart';

final applicationsRepositoryProvider =
    Provider<ApplicationsRepository>((_) => MockApplicationsRepository());

class ApplicationsState {
  final AsyncValue<List<Application>> apps;
  final ApplicationStatus? filter; // null => tümü
  final String search;
  const ApplicationsState({required this.apps, this.filter, this.search = ''});

  ApplicationsState copyWith({
    AsyncValue<List<Application>>? apps,
    ApplicationStatus? filter,
    bool clearFilter = false,
    String? search,
  }) =>
      ApplicationsState(
        apps: apps ?? this.apps,
        filter: clearFilter ? null : (filter ?? this.filter),
        search: search ?? this.search,
      );
}

final applicationsControllerProvider =
    StateNotifierProvider<ApplicationsController, ApplicationsState>((ref) {
  final repo = ref.watch(applicationsRepositoryProvider);
  return ApplicationsController(repo)..load();
});

class ApplicationsController extends StateNotifier<ApplicationsState> {
  final ApplicationsRepository _repo;
  ApplicationsController(this._repo)
      : super(const ApplicationsState(apps: AsyncValue.loading()));

  Future<void> load() async {
    state = state.copyWith(apps: const AsyncValue.loading());
    try {
      final list = await _repo.fetchMyApplications();
      state = state.copyWith(apps: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(apps: AsyncValue.error(e, st));
    }
  }

  void setFilter(ApplicationStatus? s) {
    if (s == state.filter) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filter: s);
    }
  }

  void setSearch(String q) => state = state.copyWith(search: q);

  List<Application> filtered() {
    final all = state.apps.value ?? [];
    final q = state.search.trim().toLowerCase();
    final byStatus = state.filter == null
        ? all
        : all.where((a) => a.status == state.filter);
    final bySearch = q.isEmpty
        ? byStatus
        : byStatus.where((a) =>
            a.listingTitle.toLowerCase().contains(q) ||
            a.companyName.toLowerCase().contains(q));
    final list = [...bySearch]..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    return list;
  }
}
