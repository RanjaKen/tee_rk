# Provider reference

32 providers in 6 files. The assignment asks for at least 5; the extra ones
exist because derived state belongs in providers rather than in `build()`.

Conventions used throughout:

- **Notifier / AsyncNotifier** — owns mutable state and the rules that guard it.
- **Provider** — pure derivation from other providers. Never mutable.
- **`…RepositoryProvider`** — the single injection seam; overridden in tests.
- **`AsyncValue`** for anything that can fail or take time.

---

## `providers/navigation_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `navigationProvider` | `NotifierProvider<NavigationNotifier, AppTab>` | Selected root tab. Lives in Riverpod so any screen can jump to another tab without callbacks. |

`AppTab` — `home`, `shop`, `favorites`, `cart`, `profile`.

---

## `providers/product_providers.dart`

| Provider | Type | Purpose |
|---|---|---|
| `simulateNetworkErrorProvider` | `NotifierProvider<…, bool>` | Runtime switch (Profile → Developer) that forces the catalog to fail. |
| `productRepositoryProvider` | `Provider<ProductRepository>` | Injection seam. Watches the switch above, so flipping it rebuilds every dependent provider into its error state. |
| `productsProvider` | `AsyncNotifierProvider<ProductsNotifier, List<Product>>` | The catalog. `refresh()` re-fetches while keeping the current list on screen. |
| `productDetailProvider` | `FutureProvider.family<Product, String>` | One product by id; a miss becomes `NotFoundException`. |
| `featuredProductsProvider` | `Provider<AsyncValue<List<Product>>>` | Featured slice for the home hero and pair. |
| `newArrivalsProvider` | `Provider<AsyncValue<List<Product>>>` | Catalog sorted by release date, newest first. |

Both async providers pass `retry: _noRetry` to opt out of Riverpod 3's
automatic backoff retry.

---

## `providers/selected_size_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `selectedSizesProvider` | `NotifierProvider<…, Map<String, String>>` | Chosen size per product id. |
| `selectedSizeProvider` | `Provider.family<String?, String>` | Effective size for one product: the explicit choice, or the only size when a product ships in one size. |

A plain `Notifier` in Riverpod 3 cannot read a family argument, so selections
are stored in one map and the family-shaped read is derived on top.

---

## `providers/cart_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `cartProvider` | `NotifierProvider<CartNotifier, List<CartItem>>` | The bag, and every rule that guards it. |
| `cartCountProvider` | `Provider<int>` | Units in the bag; drives the nav badge. |
| `cartSubtotalProvider` | `Provider<int>` | Sum of the lines, in Ariary. |
| `cartShippingProvider` | `Provider<int>` | Free at or above `AppConfig.freeShippingThreshold`, flat rate below, zero when empty. |
| `cartTotalProvider` | `Provider<int>` | Subtotal + shipping. |

`CartNotifier` API: `add(product, size, {quantity})`, `increment(key)`,
`decrement(key)`, `remove(key)`, `clear()`, `quantityOf(id, size)`.

Rules enforced in the notifier, not the UI:

- Same product **and** size merges into one line (`key = id::size`).
- Quantity is clamped to `min(stock, AppConfig.maxQuantityPerLine)`.
- Sold-out products are refused outright.
- Decrementing the last unit removes the line.

---

## `providers/favorites_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `favoritesRepositoryProvider` | `Provider<FavoritesRepository>` | Injection seam for device storage. |
| `favoritesProvider` | `AsyncNotifierProvider<FavoritesNotifier, Set<String>>` | Saved ids, loaded from and written back to `shared_preferences`. |
| `isFavoriteProvider` | `Provider.family<bool, String>` | Cheap per-card read. |
| `favoritesCountProvider` | `Provider<int>` | Badge / stats count. |
| `favoriteProductsProvider` | `Provider<AsyncValue<List<Product>>>` | Saved ids resolved against the catalog, in catalog order, skipping ids that no longer exist. Stays loading/error while either source is. |

`toggle(id)` and `clear()` update state optimistically, then persist; a failed
write rolls the state back and returns `false`.

---

## `providers/catalog_filter_providers.dart`

| Provider | Type | Purpose |
|---|---|---|
| `searchQueryProvider` | `NotifierProvider<…, String>` | Free text from the shop search field. |
| `categoryFilterProvider` | `NotifierProvider<…, ProductCategory?>` | Selected category; `null` is ALL. Re-selecting the active one clears it. |
| `priceBoundsProvider` | `Provider<PriceRange>` | Cheapest/most expensive in the catalog — the slider never hardcodes prices. |
| `priceRangeProvider` | `NotifierProvider<…, PriceRange?>` | User-chosen window; `null` means "not narrowed". |
| `effectivePriceRangeProvider` | `Provider<PriceRange>` | The window actually applied, resolved against the bounds. |
| `sortOptionProvider` | `NotifierProvider<…, SortOption>` | Newest (default), price ↑/↓, name A→Z / Z→A. |
| `filteredProductsProvider` | `Provider<AsyncValue<List<Product>>>` | Search + category + price + sort, preserving the catalog's `AsyncValue`. |
| `activeFilterCountProvider` | `Provider<int>` | Badge on the filter button. A price window still covering the full bounds does not count. |

`resetCatalogFilters(ref)` clears all four in one call.

Search matches name, brand, category label and description, case-insensitive
and whitespace-trimmed.

---

## `providers/profile_providers.dart`

| Provider | Type | Purpose |
|---|---|---|
| `profileRepositoryProvider` | `Provider<ProfileRepository>` | Injection seam for the mock account. |
| `profileProvider` | `AsyncNotifierProvider<ProfileNotifier, UserProfile>` | The account, with `refresh()`. |
| `ordersProvider` | `AsyncNotifierProvider<OrdersNotifier, List<Order>>` | Order history, newest first. `placeOrder(...)` converts the bag into an order and prepends it. |
| `ordersCountProvider` | `Provider<int>` | Stats row / shortcut count. |
| `settingsProvider` | `NotifierProvider<SettingsNotifier, AppSettings>` | Drop notifications, newsletter, price alerts. |

`placeOrder` **snapshots** each line's name, image, size and unit price, so a
later catalog change cannot rewrite order history.

---

## Dependency graph

```
simulateNetworkErrorProvider
        └─► productRepositoryProvider
                    └─► productsProvider ──┬─► featuredProductsProvider
                            │              ├─► newArrivalsProvider
                            │              └─► priceBoundsProvider
                            │                        └─► effectivePriceRangeProvider
                            │                                    │
                            └────────────────► filteredProductsProvider ◄── searchQueryProvider
                                                     ▲                  ◄── categoryFilterProvider
                                                     └──────────────────◄── sortOptionProvider
        productRepositoryProvider
                    └─► productDetailProvider ─► selectedSizeProvider ◄── selectedSizesProvider

favoritesRepositoryProvider ─► favoritesProvider ─┬─► isFavoriteProvider
                                                  ├─► favoritesCountProvider
                                                  └─► favoriteProductsProvider ◄── productsProvider

cartProvider ─┬─► cartCountProvider
              └─► cartSubtotalProvider ─┬─► cartShippingProvider
                                        └─► cartTotalProvider ◄──┘

profileRepositoryProvider ─┬─► profileProvider
                           └─► ordersProvider ─► ordersCountProvider
```

---

## Overriding in tests

```dart
final container = ProviderContainer(
  overrides: [
    productRepositoryProvider.overrideWithValue(
      FakeProductRepository(latency: Duration.zero, shouldFail: false),
    ),
    favoritesRepositoryProvider.overrideWithValue(
      InMemoryFavoritesRepository(initial: {'tee-001'}),
    ),
    profileRepositoryProvider.overrideWithValue(
      MockProfileRepository(latency: Duration.zero),
    ),
  ],
);
addTearDown(container.dispose);
```

Widget tests wrap the same container in `UncontrolledProviderScope`, which
lets the test read provider state directly while driving the UI.
