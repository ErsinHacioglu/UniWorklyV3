import '../domain/application_models.dart';

abstract class ApplicationsRepository {
  Future<List<Application>> fetchMyApplications();
}

class MockApplicationsRepository implements ApplicationsRepository {
  @override
  Future<List<Application>> fetchMyApplications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      Application(
        id: 'a1',
        listingId: 'l1', // 👈
        listingTitle: 'Kafe Servis',
        companyName: 'Cafe Nox',
        appliedAt: DateTime(2025, 9, 21, 10, 12),
        status: ApplicationStatus.pending,
      ),
      Application(
        id: 'a2',
        listingId: 'l2', // 👈
        listingTitle: 'Depo Sayım',
        companyName: 'LogiCo',
        appliedAt: DateTime(2025, 9, 19, 18, 40),
        status: ApplicationStatus.approved,
      ),
      Application(
        id: 'a3',
        listingId: 'l3', // 👈
        listingTitle: 'Stand Görevlisi',
        companyName: 'PromoLab',
        appliedAt: DateTime(2025, 9, 12, 9, 5),
        status: ApplicationStatus.rejected,
      ),
    ];
  }
}
