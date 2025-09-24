// lib/src/features/jobs/presentation/jobs_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../jobs/application/jobs_controller.dart';
import '../../jobs/domain/job_models.dart';
import 'rate_employer_dialog.dart';
import 'job_detail_page.dart';

import '../../applications/application/applications_controller.dart';
import '../../applications/domain/application_models.dart';
import '../../applications/presentation/application_detail_page.dart'; // Başvuru detayı

/// Üstteki iki kademeli sekme: 0 = İşlerim, 1 = Başvurularım
final jobsTabProvider = StateProvider<int>((ref) => 0);

class JobsPage extends ConsumerWidget {
  const JobsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(jobsTabProvider);

    // İşlerim
    final jobsState = ref.watch(jobsControllerProvider);
    final jobsCtrl  = ref.read(jobsControllerProvider.notifier);

    // Başvurularım
    final appsState = ref.watch(applicationsControllerProvider);
    final appsCtrl  = ref.read(applicationsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('İşlerim')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: CustomScrollView(
          slivers: [
            // Sekme (İşlerim | Başvurularım)
            SliverToBoxAdapter(
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('İşlerim')),
                  ButtonSegment(value: 1, label: Text('Başvurularım')),
                ],
                selected: {tab},
                onSelectionChanged: (s) =>
                    ref.read(jobsTabProvider.notifier).state = s.first,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // Arama
            SliverToBoxAdapter(
              child: TextField(
                onChanged: (q) {
                  if (tab == 0) {
                    jobsCtrl.setSearch(q);
                  } else {
                    appsCtrl.setSearch(q);
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'İş veya işveren ara',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // İçerik
            if (tab == 0)
              ..._buildJobsSlivers(context, ref, jobsState, jobsCtrl)
            else
              ..._buildApplicationsSlivers(context, ref, appsState, appsCtrl),
          ],
        ),
      ),
    );
  }

  // ------------------- İşlerim -------------------
  List<Widget> _buildJobsSlivers(
    BuildContext context,
    WidgetRef ref,
    JobsState state,
    JobsController ctrl,
  ) {
    final filter = state.filter;

    // Hangi liste gösterilecek?
    final items = switch (filter) {
      JobsFilter.active   => [if (ctrl.activeJob() != null) ctrl.activeJob()!],
      JobsFilter.upcoming => ctrl.upcomingJobs(),
      JobsFilter.past     => ctrl.pastJobs(),
      null                => ctrl.unifiedList(),
    };

    return [
      // Filtre butonları (başlangıçta hiçbiri seçili değil)
      SliverToBoxAdapter(
        child: Wrap(
          spacing: 8,
          children: [
            _FilterBtn(
              label: 'Aktif İşim',
              selected: filter == JobsFilter.active,
              onTap: () => ctrl.setFilter(JobsFilter.active),
            ),
            _FilterBtn(
              label: 'Gelecek İşlerim',
              selected: filter == JobsFilter.upcoming,
              onTap: () => ctrl.setFilter(JobsFilter.upcoming),
            ),
            _FilterBtn(
              label: 'Geçmiş İşlerim',
              selected: filter == JobsFilter.past,
              onTap: () => ctrl.setFilter(JobsFilter.past),
            ),
          ],
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 12)),

      // Liste gövdesi
      switch (state.jobs) {
        AsyncLoading() => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator())),
        AsyncError(:final error) => SliverToBoxAdapter(
            child: Center(child: Text('Bir hata oluştu: $error'))),
        AsyncData() => items.isEmpty
            ? const SliverToBoxAdapter(
                child: _EmptyHint(text: 'Kayıt bulunamadı'),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final j = items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _JobCard(
                        job: j,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => JobDetailPage(job: j),
                          ),
                        ),
                        onRateTap: j.canRate
                            ? () async {
                                final result = await showDialog<RatingResult>(
                                  context: context,
                                  builder: (_) => RateEmployerDialog(job: j),
                                );
                                if (result != null) {
                                  await ctrl.rate(j.id, result.stars,
                                      comment: result.comment);
                                  if (context.mounted) {
                                    await showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Teşekkürler'),
                                        content: const Text(
                                            'Değerlendirmeniz başarıyla alınmıştır.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Tamam'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              }
                            : null,
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
        _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
      },
      const SliverToBoxAdapter(child: SizedBox(height: 12)),
    ];
  }

  // ------------------- Başvurularım -------------------
  List<Widget> _buildApplicationsSlivers(
    BuildContext context,
    WidgetRef ref,
    ApplicationsState state,
    ApplicationsController ctrl,
  ) {
    final list = ctrl.filtered();

    return [
      switch (state.apps) {
        AsyncLoading() => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator())),
        AsyncError(:final error) => SliverToBoxAdapter(
            child: Center(child: Text('Bir hata oluştu: $error'))),
        AsyncData() => list.isEmpty
            ? const SliverToBoxAdapter(
                child: _EmptyHint(text: 'Başvurunuz yok'),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final a = list[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          leading: const Icon(Icons.assignment_outlined),
                          title: Text(a.listingTitle),
                          subtitle: Text(a.companyName),
                          trailing: _AppStatusBadge(status: a.status),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ApplicationDetailPage(application: a),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  childCount: list.length,
                ),
              ),
        _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
      },
      const SliverToBoxAdapter(child: SizedBox(height: 12)),
    ];
  }
}

// ----------------------------------------------------
// Küçük UI yardımcıları
// ----------------------------------------------------

class _FilterBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: cs.primary.withOpacity(.15),
      labelStyle: TextStyle(color: selected ? cs.primary : cs.onSurface),
      showCheckmark: selected,
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  final VoidCallback? onRateTap;
  const _JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onRateTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = job.status == JobStatus.past;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.work_outline, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            job.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        _StatusBadge(job: job), // sağ üst rozet
                      ],
                    ),
                    Text(job.companyName,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text(_timeRangeText(job),
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isPast)
                (job.isRated && job.myRating != null)
                    ? SizedBox(
                        height: 44,
                        child: Center(
                            child: _Stars(stars: job.myRating!.stars)),
                      )
                    : ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 88,
                          maxWidth: 160,
                          minHeight: 40,
                          maxHeight: 44,
                        ),
                        child: ElevatedButton(
                          onPressed: onRateTap,
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: const Size(88, 40),
                          ),
                          child: const Text('Değerlendir'),
                        ),
                      )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  String _timeRangeText(Job j) {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '${fmt(j.startAt)} - ${fmt(j.endAt)}';
  }
}

class _StatusBadge extends StatelessWidget {
  final Job job;
  const _StatusBadge({required this.job});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    late final Color bg;
    late final Color fg;
    late final Widget child;

    switch (job.status) {
      case JobStatus.active:
        bg = cs.primary.withOpacity(.12);
        fg = cs.primary;
        child = Row(children: const [
          Icon(Icons.bolt, size: 16),
          SizedBox(width: 4),
          Text('Aktif'),
        ]);
        break;
      case JobStatus.upcoming:
        bg = cs.tertiary.withOpacity(.12);
        fg = cs.tertiary;
        child = Row(children: const [
          Icon(Icons.schedule, size: 16),
          SizedBox(width: 4),
          Text('Gelecek'),
        ]);
        break;
      case JobStatus.past:
        final failed = job.outcome == JobOutcome.failed;
        bg = (failed ? Colors.red : Colors.green).withOpacity(.12);
        fg = failed ? Colors.red.shade700 : Colors.green.shade700;
        child = Row(children: [
          Icon(failed ? Icons.close : Icons.check, size: 16),
          const SizedBox(width: 4),
          Text(failed ? 'Tamamlanamadı' : 'Tamamlandı'),
        ]);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: IconTheme(
        data: IconThemeData(color: fg),
        child: DefaultTextStyle(
          style: TextStyle(color: fg),
          child: child,
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final int stars;
  const _Stars({super.key, required this.stars});
  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(
          5,
          (i) => Icon(i < stars ? Icons.star : Icons.star_border),
        ),
      );
}

// ---------------- Başvurular Rozeti ----------------

class _AppStatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  const _AppStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final IconData icon;
    late final String text;

    switch (status) {
      case ApplicationStatus.pending:
        bg = Colors.amber.withOpacity(.12);
        fg = Colors.amber.shade800;
        icon = Icons.schedule;
        text = 'Onay bekliyor';
        break;
      case ApplicationStatus.approved:
        bg = Colors.green.withOpacity(.12);
        fg = Colors.green.shade700;
        icon = Icons.check;
        text = 'Onaylandı';
        break;
      case ApplicationStatus.rejected:
        bg = Colors.red.withOpacity(.12);
        fg = Colors.red.shade700;
        icon = Icons.close;
        text = 'Reddedildi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: fg),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: fg)),
      ]),
    );
  }
}
