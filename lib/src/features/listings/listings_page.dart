import 'package:flutter/material.dart';
import 'models.dart';
import 'mock_listings.dart';
import 'listing_detail_page.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  String _query = '';

  // SIRALAMA
  SortBy _sort = SortBy.newest;

  // FİLTRELER
  DateTime? _dateFrom; // Tarih başlangıcı (sadece gün dikkate alınır)
  DateTime? _dateTo;   // Tarih bitişi
  int? _startHour;     // 0..24
  int? _endHour;       // 0..24
  bool? _meal;         // null=önemsiz, true=dahil, false=değil
  bool? _transport;    // null=önemsiz
  String? _city;       // null=hepsi
  String? _sector;     // null=hepsi

  List<String> get _allCities => {for (final j in mockListings) j.city}.toList()..sort();
  List<String> get _allSectors => {for (final j in mockListings) j.sector}.toList()..sort();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // FİLTRELE
    var items = mockListings.where((j) {
      // Arama
      final text = '${j.title} ${j.company} ${j.city} ${j.sector} ${j.hourlyPrice} ${j.price}'.toLowerCase();
      if (_query.isNotEmpty && !text.contains(_query.toLowerCase())) return false;

      // Tarih aralığı: sadece startTime gününe bakıyoruz
      final jDay = DateUtils.dateOnly(j.startTime);
      if (_dateFrom != null && jDay.isBefore(DateUtils.dateOnly(_dateFrom!))) return false;
      if (_dateTo != null && jDay.isAfter(DateUtils.dateOnly(_dateTo!))) return false;

      // Yemek / Yol
      if (_meal != null && j.mealIncluded != _meal) return false;
      if (_transport != null && j.transportIncluded != _transport) return false;

      // Şehir / Sektör
      if (_city != null && j.city != _city) return false;
      if (_sector != null && j.sector != _sector) return false;

      // Saat kuralları
      final startH = hourOnly(j.startTime);
      final endH = j.endTime != null ? hourOnly(j.endTime!) : null;

      if (_startHour != null && _endHour == null) {
        if (!(startH >= _startHour! && startH < 24)) return false;
      } else if (_startHour == null && _endHour != null) {
        if (endH != null) {
          if (endH > _endHour!) return false;
        } else {
          if (startH > _endHour!) return false;
        }
      } else if (_startHour != null && _endHour != null) {
        if (!(startH >= _startHour! && startH < _endHour!)) return false;
      }

      return true;
    }).toList();

    // SIRALA
    items.sort((a, b) {
      switch (_sort) {
        case SortBy.priceAsc:
          return a.price.compareTo(b.price);
        case SortBy.priceDesc:
          return b.price.compareTo(a.price);
        case SortBy.newest:
          return b.startTime.compareTo(a.startTime);
        case SortBy.oldest:
          return a.startTime.compareTo(b.startTime);
        case SortBy.popular:
          return b.applications.compareTo(a.applications);
      }
    });

    return Column(
      children: [
        // ARAMA
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'İlan ara, şirket/başlık/sektör...',
              filled: true,
              fillColor: cs.surfaceVariant.withOpacity(0.4),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
            ),
          ),
        ),

        // ÜST SEÇENEKLER: SIRALA ve FİLTRELE
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.sort_rounded),
                  label: const Text('Sırala'),
                  onPressed: () => _openSortSheet(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.filter_list_rounded),
                  label: const Text('Filtrele'),
                  onPressed: () => _openFilterSheet(context),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // LİSTE
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final j = items[i];
              return ListTile(
                leading: CircleAvatar(child: Text(j.company.isNotEmpty ? j.company[0] : '?')),
                title: Text(j.title),
                subtitle: Text('${j.company} · ${j.city} · ${j.sector}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₺${j.price.toStringAsFixed(0)}  •  ₺${j.hourlyPrice.toStringAsFixed(0)}/s'),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${j.startTime.hour.toString().padLeft(2, '0')}:00'
                          '${j.endTime != null ? ' - ${j.endTime!.hour.toString().padLeft(2, '0')}:00' : ''}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                   builder: (_) => ListingDetailPage(listing: j),
                  ));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ================== SHEETLER ==================

  void _openSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        Widget tile(String text, SortBy v) => RadioListTile<SortBy>(
              value: v,
              groupValue: _sort,
              onChanged: (val) {
                if (val != null) setState(() => _sort = val);
                Navigator.pop(ctx);
              },
              title: Text(text),
            );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              tile('Fiyat (artan)', SortBy.priceAsc),
              tile('Fiyat (azalan)', SortBy.priceDesc),
              tile('Yeniden eskiye', SortBy.newest),
              tile('Eskiden yeniye', SortBy.oldest),
              tile('Popüler ilanlar', SortBy.popular),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _openFilterSheet(BuildContext context) {
    final cities = _allCities;
    final sectors = _allSectors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        int? tempStartH = _startHour;
        int? tempEndH = _endHour;
        bool? tempMeal = _meal;
        bool? tempTransport = _transport;
        String? tempCity = _city;
        String? tempSector = _sector;
        DateTime? tempFrom = _dateFrom;
        DateTime? tempTo = _dateTo;

        List<DropdownMenuItem<int?>> hourItems() {
          final items = <DropdownMenuItem<int?>>[
            const DropdownMenuItem(value: null, child: Text('—')),
          ];
          for (var h = 0; h <= 24; h++) {
            items.add(DropdownMenuItem(value: h, child: Text(h.toString().padLeft(2, '0'))));
          }
          return items;
        }

        Widget triChip({
          required String label,
          required bool? value,
          required ValueChanged<bool?> onChanged,
          String activeText = 'Dahil',
          String inactiveText = 'Değil',
        }) {
          String text;
          if (value == null) text = '$label: Hepsi';
          else if (value == true) text = '$label: $activeText';
          else text = '$label: $inactiveText';
          return ChoiceChip(
            label: Text(text),
            selected: value != null,
            onSelected: (_) {
              if (value == null) onChanged(true);
              else if (value == true) onChanged(false);
              else onChanged(null);
            },
          );
        }

        Future<void> pickDate({required bool isFrom}) async {
          final initial = isFrom ? (tempFrom ?? DateTime.now()) : (tempTo ?? DateTime.now());
          final picked = await showDatePicker(
            context: ctx,
            initialDate: initial,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) {
            if (isFrom) tempFrom = picked;
            else tempTo = picked;
            (ctx as Element).markNeedsBuild();
          }
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
              left: 16, right: 16, top: 8,
            ),
            child: StatefulBuilder(
              builder: (ctx, setModalState) {
                void rebuild() => setModalState(() {});
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TARİH
                      Text('Tarih', style: Theme.of(ctx).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async { await pickDate(isFrom: true); rebuild(); },
                              child: Text(tempFrom == null ? 'Başlangıç' : '${tempFrom!.day}.${tempFrom!.month}.${tempFrom!.year}'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async { await pickDate(isFrom: false); rebuild(); },
                              child: Text(tempTo == null ? 'Bitiş' : '${tempTo!.day}.${tempTo!.month}.${tempTo!.year}'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // SAAT
                      Text('Saat', style: Theme.of(ctx).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('Başlangıç'),
                          const SizedBox(width: 6),
                          DropdownButton<int?>(
                            value: tempStartH,
                            items: hourItems(),
                            onChanged: (v) { tempStartH = v; rebuild(); },
                          ),
                          const SizedBox(width: 14),
                          const Text('Bitiş'),
                          const SizedBox(width: 6),
                          DropdownButton<int?>(
                            value: tempEndH,
                            items: hourItems(),
                            onChanged: (v) { tempEndH = v; rebuild(); },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // YEMEK / YOL
                      Text('Yemek & Yol', style: Theme.of(ctx).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          triChip(label: 'Yemek', value: tempMeal, onChanged: (v) { tempMeal = v; rebuild(); }),
                          triChip(label: 'Yol', value: tempTransport, onChanged: (v) { tempTransport = v; rebuild(); }),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ŞEHİR / SEKTÖR
                      Text('Konum & Sektör', style: Theme.of(ctx).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              value: tempCity,
                              decoration: const InputDecoration(labelText: 'Şehir'),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Hepsi')),
                                ...cities.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                              ],
                              onChanged: (v) { tempCity = v; rebuild(); },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              value: tempSector,
                              decoration: const InputDecoration(labelText: 'Sektör'),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Hepsi')),
                                ...sectors.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                              ],
                              onChanged: (v) { tempSector = v; rebuild(); },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              tempFrom = null; tempTo = null;
                              tempStartH = null; tempEndH = null;
                              tempMeal = null; tempTransport = null;
                              tempCity = null; tempSector = null;
                              rebuild();
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Temizle'),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                _dateFrom = tempFrom; _dateTo = tempTo;
                                _startHour = tempStartH; _endHour = tempEndH;
                                _meal = tempMeal; _transport = tempTransport;
                                _city = tempCity; _sector = tempSector;
                              });
                              Navigator.pop(ctx);
                            },
                            child: const Text('Uygula'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
