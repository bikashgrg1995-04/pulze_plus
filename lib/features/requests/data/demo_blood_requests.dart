import '../models/blood_request_model.dart';

const demoBloodRequests = [
  BloodRequestModel(
    id: 'request_001',
    bloodGroup: 'O+',
    units: 2,
    location: 'Bharatpur Hospital',
    distance: 2.4,
    requiredBy: 'Today, 6:00 PM',
    status: BloodRequestStatus.pending,
    note: 'Urgent requirement for surgery.',
  ),
  BloodRequestModel(
    id: 'request_002',
    bloodGroup: 'A+',
    units: 1,
    location: 'Chitwan Medical College',
    distance: 4.1,
    requiredBy: 'Tomorrow, 10:00 AM',
    status: BloodRequestStatus.matched,
  ),
  BloodRequestModel(
    id: 'request_003',
    bloodGroup: 'B+',
    units: 2,
    location: 'Bharatpur Central Hospital',
    distance: 5.8,
    requiredBy: 'Sep 25, 2026',
    status: BloodRequestStatus.accepted,
  ),
];