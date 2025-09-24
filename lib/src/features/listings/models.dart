import 'package:flutter/material.dart';

enum SortBy { priceAsc, priceDesc, newest, oldest, popular }

class JobListing {
  final String id;
  final String title;
  final String company;
  final DateTime startTime;
  final DateTime? endTime;
  final double price;
  final double hourlyPrice;
  final int applications;
  final String city;
  final String sector;
  final bool mealIncluded;
  final bool transportIncluded;

  // — yeni alanlar —
  final String description; // ilan açıklaması
  final String? address;    // ayrıntılı adres (opsiyonel)
  final double rating;      // 0–5
  final int reviewCount;    // yorum sayısı

  const JobListing({
    required this.id,
    required this.title,
    required this.company,
    required this.startTime,
    this.endTime,
    required this.price,
    required this.hourlyPrice,
    required this.applications,
    required this.city,
    required this.sector,
    required this.mealIncluded,
    required this.transportIncluded,
    this.description = '',
    this.address,
    this.rating = 0,
    this.reviewCount = 0,
  });
}

int hourOnly(DateTime dt) => dt.hour;
