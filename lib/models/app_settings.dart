/// In app preferences.
///
/// Session scoped in this build: only favorites are persisted to the
/// device.
class AppSettings {
  const AppSettings({
    this.dropNotifications = true,
    this.newsletter = false,
    this.priceAlerts = false,
  });

  final bool dropNotifications;
  final bool newsletter;
  final bool priceAlerts;

  AppSettings copyWith({
    bool? dropNotifications,
    bool? newsletter,
    bool? priceAlerts,
  }) {
    return AppSettings(
      dropNotifications: dropNotifications ?? this.dropNotifications,
      newsletter: newsletter ?? this.newsletter,
      priceAlerts: priceAlerts ?? this.priceAlerts,
    );
  }
}
