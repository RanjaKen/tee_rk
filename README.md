# TEE_RK

A basketball lifestyle store built with **Flutter** and **Riverpod** — tees, sneakers,
jerseys and court accessories, under the RanjaKen brand.

Dark, editorial, product-first: near-black surfaces, large imagery, uppercase
typography with wide tracking, and one red accent.

---



## Features

**Catalog** — 16 mock products across 4 categories, editorial home feed
(lookbook banners, featured pair, new arrivals), and a full shop grid.

**Product detail** — Hero image transition, price, category, rating, stock
line, size selector, colourway, description and a details table.

**Cart** — Add, remove, increase/decrease quantity, live totals. Same product
in two sizes is two lines. Quantities are capped by stock, sold-out items are
refused, and shipping is free above 500 000 Ar.

**Favorites** — Heart on every card and on the detail page. The list is
**persisted on the device** with `shared_preferences` and survives restarts.

**Search, filter and sort** — Search across name, brand, category and
description; category chips; a price range whose bounds come from the catalog;
five sort orders. All four compose.

**Profile** — Mock account, order history (checkout records real orders),
favorites and bag shortcuts, settings switches, and a developer switch that
forces the catalog into its error state.

---





### Project structure

```
lib/
├── core/
│   ├── constants/      app_assets, app_config, app_strings
│   ├── errors/         AppException, DataLoadException, NotFoundException
│   ├── router/         AppRoutes + AppRouter
│   ├── theme/          colors, typography, spacing, ThemeData
│   └── utils/          PriceFormatter (Ariary)
├── data/               product + favorites data sources
├── models/             Product, CartItem, Order, UserProfile, …
├── providers/          32 providers across 6 files
├── repositories/       product, favorites, profile
├── screens/            home, search, favorites, cart, product, profile, shell
├── widgets/            cart/, common/, home/, product/, profile/
└── main.dart           ProviderScope + MaterialApp
```

---

## State management

Riverpod is the only state solution used — there is no `setState` for app
state, no `InheritedWidget`, no singletons.

**32 providers.** Async data uses `AsyncValue`, so every consumer handles
loading, error and data explicitly:

```dart
catalog.when(
  loading: () => const SliverProductGridSkeleton(),
  error:   (error, _) => ErrorView(error: error, onRetry: refresh),
  data:    (products) => SliverProductGrid(products: products),
);
```

Riverpod 3 retries failed providers with exponential backoff by default,
which leaves the UI spinning instead of reporting the problem. TEE_RK opts
out (`retry: _noRetry`) and offers an explicit **RETRY** button instead.

Derived state is computed in providers, never in `build()`:
`filteredProductsProvider` applies search + category + price + sort;
`cartTotalProvider` composes subtotal and shipping; `favoriteProductsProvider`
resolves saved ids against the catalog.

---



Notable cases: favorites persistence verified by rebuilding a fresh
`ProviderContainer` (equivalent to relaunching the app); order lines asserted
to be snapshots rather than live product references; sold-out and
stock-ceiling rules; the empty-catalog regression on the home feed.

Widget tests boot with a phone-sized surface and warm the repository through
`runAsync`, because the default 800×600 test window leaves lower slivers
unbuilt and asset IO does not complete under fake time. `pumpAndSettle` is
avoided — the loading skeleton pulses forever and would never settle.

---

## Design decisions

- **Dark only.** The brand mark ships white-on-transparent and the reference
  language is a dark gallery; a light theme would fight both.
- **Integer Ariary** over `double`, for exact totals.
- **Auto-retry disabled**, so failures are visible and user-driven.
- **Order lines snapshot the product**, so catalog edits cannot rewrite
  history.
- **`ProductCard.useHero`** exists because the home feed can show one product
  twice (featured pair and new arrivals); duplicate Hero tags crash Flutter.
- **Size selection lives in a provider**, keyed by product id, because
  Riverpod 3's plain `Notifier` cannot read a family argument.



Built with the RanjaKen brand mark. Product data is fictional.
Author : Andi Andriamalala
