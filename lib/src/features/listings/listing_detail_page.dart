import 'package:flutter/material.dart';
import 'models.dart';

class ListingDetailPage extends StatelessWidget {
  final JobListing? listing;
  final String? listingId;

  const ListingDetailPage({
    super.key,
    this.listing,
    this.listingId,
  }) : assert(listing != null || listingId != null,
          'Ya listing ya da listingId verilmelidir');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Eğer sadece id geldiyse: repository’den fetch etmen lazım (şimdilik placeholder)
    final jobListing = listing ??
        JobListing(
          id: listingId!,
          title: 'İlan Yükleniyor...',
          company: 'Bilinmiyor',
          description: '',
          rating: 0,
          reviewCount: 0,
          mealIncluded: false,
          transportIncluded: false,
          price: 0,
          hourlyPrice: 0,
          startTime: DateTime.now(),
          endTime: null,
          sector: '',
          city: '',
          address: '',
          applications: 0,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(jobListing.title, overflow: TextOverflow.ellipsis),
        centerTitle: false,
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            icon: const Icon(Icons.how_to_reg_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Başvuru gönderildi (placeholder)')),
              );
            },
            label: const Text('Başvur'),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              jobListing.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            // Firma kartı
            InkWell(
              onTap: () => _openProfile(context, jobListing),
              borderRadius: BorderRadius.circular(28),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: cs.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      child: Text(jobListing.company.isNotEmpty
                          ? jobListing.company[0]
                          : '?'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        jobListing.company,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openReviews(context, jobListing),
                      icon: const Icon(Icons.star_rate_rounded),
                      label: Text(
                          '${jobListing.rating.toStringAsFixed(1)} (${jobListing.reviewCount})'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Açıklama
            if (jobListing.description.isNotEmpty) ...[
              Text('Açıklama',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(jobListing.description,
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
            ],

            // Detaylar
            Text('Detaylar',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth()
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                _row(context, Icons.restaurant_rounded, 'Yemek',
                    jobListing.mealIncluded ? 'Var' : 'Yok'),
                _row(context, Icons.directions_bus_rounded, 'Yol',
                    jobListing.transportIncluded ? 'Var' : 'Yok'),
                _row(context, Icons.price_change_rounded, 'Fiyat',
                    '₺${jobListing.price.toStringAsFixed(0)}'),
                _row(
                  context,
                  Icons.schedule_rounded,
                  'Saat',
                  '${jobListing.startTime.hour.toString().padLeft(2, '0')}:00'
                  '${jobListing.endTime != null ? ' - ${jobListing.endTime!.hour.toString().padLeft(2, '0')}:00' : ''}',
                ),
                _row(context, Icons.work_outline_rounded, 'Sektör',
                    jobListing.sector),
                _row(context, Icons.place_outlined, 'Adres/Konum',
                    jobListing.address ?? jobListing.city),
              ],
            ),

            const SizedBox(height: 16),

            // Harita placeholder
            Text('Konum',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 220,
                color: cs.surfaceVariant.withOpacity(0.6),
                child: const Center(
                    child: Icon(Icons.map_rounded, size: 64)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _row(BuildContext context, IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: cs.primary),
              const SizedBox(width: 10),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  void _openProfile(BuildContext context, JobListing listing) {
    Navigator.pushNamed(context, '/companyProfile', arguments: listing);
  }

  void _openReviews(BuildContext context, JobListing listing) {
    Navigator.pushNamed(context, '/companyReviews', arguments: listing);
  }
}
