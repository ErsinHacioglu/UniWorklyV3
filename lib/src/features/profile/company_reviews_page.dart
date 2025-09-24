// lib/src/features/profile/company_reviews_page.dart
import 'package:flutter/material.dart';
import '../listings/models.dart';

enum ReviewSort { newest, lowest, highest }

class Review {
  final String id;
  final String author; // gerçek ad-soyad (maskelenecek)
  final String text;
  final int rating; // 1..5
  final DateTime createdAt;
  int likes;
  int dislikes;
  String? ownerReply; // ilan sahibi yanıtı (varsa)

  // UI state (lokal)
  bool iLiked;
  bool iDisliked;

  Review({
    required this.id,
    required this.author,
    required this.text,
    required this.rating,
    required this.createdAt,
    this.likes = 0,
    this.dislikes = 0,
    this.ownerReply,
    this.iLiked = false,
    this.iDisliked = false,
  });
}

class CompanyReviewsPage extends StatefulWidget {
  const CompanyReviewsPage({super.key, required this.listing, this.isOwner = false});

  /// Hangi ilan sahibinin yorumları
  final JobListing listing;

  /// Bu sayfayı açan kullanıcı ilan sahibi mi?
  /// Öğrenci tarafında false kalacak; ilan sahibi panelinde true verirsin.
  final bool isOwner;

  @override
  State<CompanyReviewsPage> createState() => _CompanyReviewsPageState();
}

class _CompanyReviewsPageState extends State<CompanyReviewsPage> {
  ReviewSort _sort = ReviewSort.newest;

  // Dummy veriler
  late List<Review> _reviews = [
    Review(
      id: 'r1',
      author: 'Ayşe Demir',
      text: 'Zamanında ve profesyonellerdi, tavsiye ederim.',
      rating: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      likes: 4,
      ownerReply: 'Güzel yorumunuz için teşekkürler!',
    ),
    Review(
      id: 'r2',
      author: 'Mehmet Kaya',
      text: 'Yoğunlukta iletişimde gecikme oldu.',
      rating: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      likes: 1,
      dislikes: 1,
    ),
    Review(
      id: 'r3',
      author: 'Elif S.',
      text: 'Beklentimin üzerindeydi, tekrar çalışırım.',
      rating: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      likes: 2,
    ),
    Review(
      id: 'r4',
      author: 'Can D.',
      text: 'Ücret geç yattı, süreç zordu.',
      rating: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      dislikes: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Sıralama uygula
    final items = [..._reviews]..sort((a, b) {
        switch (_sort) {
          case ReviewSort.newest:
            return b.createdAt.compareTo(a.createdAt);
          case ReviewSort.lowest:
            return a.rating.compareTo(b.rating);
          case ReviewSort.highest:
            return b.rating.compareTo(a.rating);
        }
      });

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.listing.company} • Yorumlar'),
      ),
      body: Column(
        children: [
          // Sıralama seçici
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                const Icon(Icons.sort_rounded),
                const SizedBox(width: 8),
                DropdownButton<ReviewSort>(
                  value: _sort,
                  items: const [
                    DropdownMenuItem(value: ReviewSort.newest,  child: Text('En yeni')),
                    DropdownMenuItem(value: ReviewSort.lowest,  child: Text('En düşük puan')),
                    DropdownMenuItem(value: ReviewSort.highest, child: Text('En yüksek puan')),
                  ],
                  onChanged: (v) => setState(() => _sort = v ?? _sort),
                ),
                const Spacer(),
                // Ortalama puan özet
                Row(
                  children: [
                    _Stars(rating: widget.listing.rating.round()),
                    const SizedBox(width: 6),
                    Text('${widget.listing.rating.toStringAsFixed(1)} (${widget.listing.reviewCount})'),
                  ],
                )
              ],
            ),
          ),
          const Divider(height: 1),

          // Liste
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, i) {
                final r = items[i];
                return _ReviewTile(
                  review: r,
                  canReply: widget.isOwner, // sadece ilan sahibi cevap yazabilir
                  onLike: () => setState(() {
                    if (r.iLiked) {
                      r.iLiked = false; r.likes -= 1;
                    } else {
                      r.iLiked = true; r.likes += 1;
                      if (r.iDisliked) { r.iDisliked = false; r.dislikes -= 1; }
                    }
                  }),
                  onDislike: () => setState(() {
                    if (r.iDisliked) {
                      r.iDisliked = false; r.dislikes -= 1;
                    } else {
                      r.iDisliked = true; r.dislikes += 1;
                      if (r.iLiked) { r.iLiked = false; r.likes -= 1; }
                    }
                  }),
                  onReply: (text) => setState(() => r.ownerReply = text),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- Widgets --------------------

class _ReviewTile extends StatefulWidget {
  const _ReviewTile({
    required this.review,
    required this.canReply,
    required this.onLike,
    required this.onDislike,
    required this.onReply,
  });

  final Review review;
  final bool canReply;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final ValueChanged<String> onReply;

  @override
  State<_ReviewTile> createState() => _ReviewTileState();
}

class _ReviewTileState extends State<_ReviewTile> {
  bool _replying = false;
  final _replyCtl = TextEditingController();

  @override
  void dispose() {
    _replyCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Üst satır: avatar + maskeli isim + tarih + yıldızlar
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              child: Text(_initials(r.author)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_maskedName(r.author), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _Stars(rating: r.rating),
                      const SizedBox(width: 8),
                      Text(_formatDate(r.createdAt), style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Yorum metni
        Text(r.text),

        const SizedBox(height: 8),

        // Like / Dislike
        Row(
          children: [
            _IconBadgeButton(
              icon: Icons.thumb_up_alt_outlined,
              filledIcon: Icons.thumb_up_alt,
              filled: r.iLiked,
              count: r.likes,
              onTap: widget.onLike,
            ),
            const SizedBox(width: 6),
            _IconBadgeButton(
              icon: Icons.thumb_down_alt_outlined,
              filledIcon: Icons.thumb_down_alt,
              filled: r.iDisliked,
              count: r.dislikes,
              onTap: widget.onDislike,
            ),
            const Spacer(),
            if (widget.canReply && r.ownerReply == null)
              TextButton.icon(
                onPressed: () => setState(() => _replying = !_replying),
                icon: const Icon(Icons.reply_outlined),
                label: const Text('Yanıtla'),
              ),
          ],
        ),

        // Yanıt girişi (sadece ilan sahibi)
        if (widget.canReply && _replying) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyCtl,
                  decoration: const InputDecoration(
                    hintText: 'Yanıtınız…',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final t = _replyCtl.text.trim();
                  if (t.isEmpty) return;
                  widget.onReply(t);
                  setState(() { _replying = false; _replyCtl.clear(); });
                },
                child: const Text('Gönder'),
              ),
            ],
          ),
        ],

        // Mevcut yanıt (varsa)
        if (r.ownerReply != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user_rounded, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(r.ownerReply!),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _initials(String name) {
    final trimmed = name.trim();
    final firstChar = trimmed.isNotEmpty ? trimmed[0] : '?';
    return firstChar.toUpperCase();
  }

  // -> tek maskeli format: "Ayşe Demir" => "A****"
  String _maskedName(String name) {
    if (name.isEmpty) return '';
    final first = name[0].toUpperCase();
    return '$first****';
  }

  String _formatDate(DateTime dt) {
    final d = DateUtils.dateOnly(dt);
    final today = DateUtils.dateOnly(DateTime.now());
    if (d == today) return 'Bugün';
    if (d == today.subtract(const Duration(days: 1))) return 'Dün';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, this.size = 18});
  final int rating; // 0..5
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: filled ? cs.primary : cs.onSurfaceVariant,
        );
      }),
    );
  }
}

class _IconBadgeButton extends StatelessWidget {
  const _IconBadgeButton({
    required this.icon,
    required this.filledIcon,
    required this.filled,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final IconData filledIcon;
  final bool filled;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(filled ? filledIcon : icon, size: 18, color: filled ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text('$count', style: TextStyle(color: filled ? cs.primary : cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
