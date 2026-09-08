# Architecture

TEE_RK is layered so that each concern has exactly one home. The rule that
drives every decision below: **a widget renders state and forwards intent —
it never decides anything.**

---

## Layers

```
┌──────────────────────────────────────────────────────────────┐
│  screens/  widgets/                          PRESENTATION    │
│  Scaffolds, grids, cards, sheets.                            │
│  Reads providers, calls notifier methods. No rules.          │
└───────────────────────────┬──────────────────────────────────┘
                            │ ref.watch / ref.read
┌───────────────────────────▼──────────────────────────────────┐
│  providers/                                  STATE + RULES   │
│  Notifiers own mutable state; Providers derive from it.      │
│  Stock caps, shipping, filtering, sorting, totals.           │
└───────────────────────────┬──────────────────────────────────┘
                            │ interface calls
┌───────────────────────────▼──────────────────────────────────┐
│  repositories/                               CONTRACTS       │
│  ProductRepository, FavoritesRepository, ProfileRepository.  │
│  Fake / local / in-memory implementations.                   │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│  data/                                       SOURCES         │
│  rootBundle JSON, shared_preferences.                        │
│  The only code that knows where bytes come from.             │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│  models/                                     VALUE OBJECTS   │
│  Immutable, self-parsing, no Flutter imports.                │
└──────────────────────────────────────────────────────────────┘

core/  — theme, router, constants, errors, utils. Used by every layer above.
```

Dependencies point downwards only. `models/` imports nothing from the app;
`data/` knows the models; `repositories/` knows data and models; providers
know repositories; the UI knows providers. Nothing points back up.

---

## Data flow: catalog

```
products.json
     │  rootBundle.loadString + jsonDecode
ProductLocalDataSource
     │  List<Product>
FakeProductRepository ── artificial latency, in-memory cache, failure switch
     │
productsProvider (AsyncNotifier)      → AsyncValue<List<Product>>
     ├── featuredProductsProvider     → home hero + pair
     ├── newArrivalsProvider          → sorted by release date
     ├── priceBoundsProvider          → slider bounds
     └── filteredProductsProvider     → search + category + price + sort
                │
          SearchScreen / HomeScreen   → skeleton | ErrorView | grid
```

A failure anywhere below the provider surfaces as `AsyncValue.error` carrying
an `AppException`, which `ErrorView` unwraps into a readable sentence.

## Data flow: favorites (the persisted one)

```
Heart tapped
     │
favoritesProvider.toggle(id)
     ├── state = AsyncData(next)              optimistic, heart flips at once
     └── FavoritesRepository.save(next)
              │
       FavoritesLocalDataSource → shared_preferences ('tee_rk.favorites.v1')
              │
         write fails? → state rolled back to the previous set, toggle
                        returns false, detail screen reports it
```

On launch, `favoritesProvider.build()` reads the stored ids back, and
`favoriteProductsProvider` resolves them against the catalog — ignoring ids
that no longer exist, so a removed product cannot break the screen.

## Data flow: cart → order

```
ProductDetailScreen  ──add(product, size)──►  cartProvider
                                                 │ rules: merge by id::size,
                                                 │ clamp to min(stock, 10),
                                                 │ refuse sold out
                                    ┌────────────┼────────────┐
                          cartCountProvider  cartSubtotal  cartShipping
                                    └────────────┬────────────┘
                                            cartTotalProvider
                                                 │
CartScreen ──checkout──► ordersProvider.placeOrder(items, subtotal, shipping)
                                                 │  snapshots each line
                                          Order (PROCESSING)
                                                 │
                                    ProfileScreen / OrdersScreen
```

---

## Error handling

`AppException` is sealed:

| Type | Raised when |
|---|---|
| `DataLoadException` | The catalog or stored favorites cannot be read/written |
| `NotFoundException` | A product id has no match |

Providers never swallow these; they become `AsyncValue.error`. `ErrorView`
pattern-matches on the type to show `message` rather than a stack trace, and
offers a retry that calls back into the provider.

**Auto-retry is disabled.** Riverpod 3 retries a failed provider with
exponential backoff, which keeps the UI in a permanent loading state. Every
async provider here passes `retry: _noRetry` and exposes an explicit action.

---

## The three states, everywhere

Every screen that reads async data handles all three:

| Screen | Loading | Error | Empty |
|---|---|---|---|
| Home | Banner + grid skeleton | `ErrorView` + retry (scrollable) | "Nothing in store yet" |
| Shop | Grid skeleton | `ErrorView` + retry | "No products found" + clear filters |
| Detail | Full-page skeleton | `ErrorView` + retry | — (not found is an error) |
| Favorites | Grid skeleton | `ErrorView` + retry | "No favorites yet" + shop shortcut |
| Cart | — (synchronous) | — | "Your bag is empty" + shop shortcut |
| Profile | Header + orders skeleton | `ErrorView` + retry | "No orders yet" |
| Orders | Card skeletons | `ErrorView` + retry | "No orders yet" |

Error and empty branches are scroll views wherever pull-to-refresh exists, so
the gesture keeps working in every state.

The error path is reachable at runtime: **Profile → Developer → Simulate
network error** flips `simulateNetworkErrorProvider`, which rebuilds
`productRepositoryProvider` into a failing repository.

---

## Testability

Every external dependency enters through an overridable provider:

```dart
ProviderContainer(overrides: [
  productRepositoryProvider.overrideWithValue(
    FakeProductRepository(latency: Duration.zero, shouldFail: true),
  ),
  favoritesRepositoryProvider.overrideWithValue(InMemoryFavoritesRepository()),
  profileRepositoryProvider.overrideWithValue(
    MockProfileRepository(latency: Duration.zero),
  ),
]);
```

`FakeProductRepository` takes `latency` and `shouldFail`;
`InMemoryFavoritesRepository` takes `initial` and `failOnSave`. That is enough
to drive every state in a test without mocking frameworks.

---

## Navigation

`MainShell` keeps the five destinations alive in an `IndexedStack`, so scroll
position and local state survive tab switches. The selected tab lives in
`navigationProvider`, which lets any screen jump elsewhere ("continue
shopping" from the empty bag, "view bag" from an add-to-cart snackbar).

Pushed routes go through `AppRouter.onGenerateRoute`:

| Route | Screen | Argument |
|---|---|---|
| `/` | `MainShell` | — |
| `/product` | `ProductDetailScreen` | product id (`String`) |
| `/orders` | `OrdersScreen` | — |

An unknown route, or `/product` with a non-`String` argument, renders a
"page not found" screen instead of throwing.

---

## Theming

One `ThemeData`, built from tokens in `core/theme/`. Widgets never declare raw
colors or text styles — they use `AppColors`, `AppTypography` and
`AppSpacing`. Changing the accent is a one-line edit in `app_colors.dart`.
