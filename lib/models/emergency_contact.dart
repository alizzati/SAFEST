class EmergencyContact {
  final String name;
  final String relationship;
  final String avatarUrl;
  final String? phoneNumber;
  final String? userId;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.avatarUrl,
    this.phoneNumber,
    this.userId,
  });
}