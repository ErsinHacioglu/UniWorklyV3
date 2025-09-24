import 'package:equatable/equatable.dart';

enum ApplicationStatus { pending, approved, rejected }

class Application extends Equatable {
  final String id;
  final String listingId;     
  final String listingTitle;
  final String companyName;
  final DateTime appliedAt;
  final ApplicationStatus status;

  const Application({
    required this.id,
    required this.listingId,  
    required this.listingTitle,
    required this.companyName,
    required this.appliedAt,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        listingId,
        listingTitle,
        companyName,
        appliedAt,
        status,
      ];
}
