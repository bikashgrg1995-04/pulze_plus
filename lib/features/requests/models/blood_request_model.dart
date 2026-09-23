class BloodRequestModel {
  const BloodRequestModel({
    required this.id,
    required this.bloodGroup,
    required this.units,
    required this.location,
    required this.distance,
    required this.requiredBy,
    required this.status,
    this.note,
  });

  final String id;
  final String bloodGroup;
  final int units;
  final String location;
  final double distance;
  final String requiredBy;
  final BloodRequestStatus status;
  final String? note;
}

enum BloodRequestStatus {
  pending,
  matched,
  accepted,
  completed,
  cancelled,
}