import 'package:equatable/equatable.dart';

class JobProgress extends Equatable {
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;

  const JobProgress({
    this.checkInAt,
    this.checkOutAt,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });

  bool get isCheckedIn => checkInAt != null && checkOutAt == null;
  bool get isCompleted => checkOutAt != null;

  JobProgress copyWith({
    DateTime? checkInAt,
    DateTime? checkOutAt,
    double? checkInLat,
    double? checkInLng,
    double? checkOutLat,
    double? checkOutLng,
  }) {
    return JobProgress(
      checkInAt: checkInAt ?? this.checkInAt,
      checkOutAt: checkOutAt ?? this.checkOutAt,
      checkInLat: checkInLat ?? this.checkInLat,
      checkInLng: checkInLng ?? this.checkInLng,
      checkOutLat: checkOutLat ?? this.checkOutLat,
      checkOutLng: checkOutLng ?? this.checkOutLng,
    );
  }

  @override
  List<Object?> get props =>
      [checkInAt, checkOutAt, checkInLat, checkInLng, checkOutLat, checkOutLng];
}
