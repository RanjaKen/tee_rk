/// The signed in shopper. Mock data in this build: there is no auth.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.city,
    required this.memberSince,
    required this.tier,
  });

  final String id;
  final String fullName;
  final String email;
  final String city;
  final DateTime memberSince;

  /// Loyalty tier shown next to the name.
  final String tier;

  /// Up to two letters for the avatar.
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
