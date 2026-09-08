import '../models/order.dart';
import '../models/user_profile.dart';

/// Account and order history source.
abstract interface class ProfileRepository {
  Future<UserProfile> fetchProfile();

  Future<List<Order>> fetchOrders();
}

/// Mock account with a short order history.
///
/// There is no backend and no auth in this build: the data lives here so
/// no widget ever hardcodes it.
class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({this.latency = const Duration(milliseconds: 400)});

  final Duration latency;

  static const String _tee = 'assets/images/product/product_tee-rk.png';

  @override
  Future<UserProfile> fetchProfile() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return UserProfile(
      id: 'usr-001',
      fullName: 'Ranja Andriamalala',
      email: 'ranja@tee-rk.mg',
      city: 'Antananarivo, MG',
      memberSince: DateTime(2024, 3, 18),
      tier: 'COURTSIDE MEMBER',
    );
  }

  @override
  Future<List<Order>> fetchOrders() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return [
      Order(
        reference: 'RK-2608-0142',
        placedAt: DateTime(2026, 8, 26),
        subtotal: 414000,
        shipping: 20000,
        status: OrderStatus.delivered,
        lines: const [
          OrderLine(
            productId: 'tee-001',
            name: 'RKN-ATHL. Urban Canvas Tee',
            image: _tee,
            size: 'L',
            quantity: 1,
            unitPrice: 129000,
          ),
          OrderLine(
            productId: 'jrs-001',
            name: 'RKN Home Jersey 01',
            image: _tee,
            size: 'L',
            quantity: 1,
            unitPrice: 285000,
          ),
        ],
      ),
      Order(
        reference: 'RK-2507-0087',
        placedAt: DateTime(2026, 7, 11),
        subtotal: 690000,
        shipping: 0,
        status: OrderStatus.shipped,
        lines: const [
          OrderLine(
            productId: 'snk-001',
            name: 'RK Court Pro 82 Low',
            image: _tee,
            size: '43',
            quantity: 1,
            unitPrice: 690000,
          ),
        ],
      ),
    ];
  }
}
