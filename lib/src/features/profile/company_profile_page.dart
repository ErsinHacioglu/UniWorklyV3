import 'package:flutter/material.dart';
import '../listings/models.dart';

class CompanyProfilePage extends StatelessWidget {
  const CompanyProfilePage({super.key, required this.listing});
  final JobListing listing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(listing.company, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 28, child: Text(listing.company[0])),
              const SizedBox(width: 12),
              Expanded(
                child: Text(listing.company, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Önyazı', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Kurum/özel ders veren hakkında kısa tanıtım (placeholder). '
            'Gerçek veride burada kendilerini anlatan içerik yer alacak.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rate_rounded),
                const SizedBox(width: 6),
                Text('${listing.rating.toStringAsFixed(1)} (${listing.reviewCount})'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/companyReviews', arguments: listing),
                  icon: const Icon(Icons.reviews_rounded),
                  label: const Text('Yorumlar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
