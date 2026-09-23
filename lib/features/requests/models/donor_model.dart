class DonorModel {
  const DonorModel({
    required this.id,
    required this.bloodGroup,
    required this.distance,
    required this.isAvailable,
    required this.isEligible,
    this.lastDonation,
  });

  final String id;
  final String bloodGroup;
  final double distance;
  final bool isAvailable;
  final bool isEligible;
  final String? lastDonation;
}