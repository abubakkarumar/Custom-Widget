# Global State Cache (added Feb 23, 2026)

This note captures the changes we shipped yesterday to cut duplicate API calls by caching shared data with Riverpod. The goal: fetch once, reuse across tabs.

## What changed (quick list)
- Wrapped the app in `ProviderScope` (`lib/main.dart`) so Riverpod is available everywhere.
- Added `global_providers.dart` with three `AsyncNotifier` caches:
  - `tradePairsProvider` → spot trade pairs
  - `walletSummaryProvider` → wallet totals + coins
  - `orderHistoryProvider` → open spot orders
- Updated `WalletView`, `SpotTradePage`, and `HistoryView` to hydrate their existing controllers from the cached data instead of re-calling APIs.

## How the cache works
1) **Fetch once per app boot (or refresh):**
   ```dart
   // e.g. in initState
   ref.read(tradePairsProvider.future);
   ref.read(walletSummaryProvider.future);
   ref.read(orderHistoryProvider.future);
   ```

2) **Listen and apply to controllers (keeps old Provider logic intact):**
   ```dart
   final tradePairsAsync = ref.watch(tradePairsProvider);
   if (tradePairsAsync.hasValue && !_synced) {
     controller.applyTradePairs(tradePairsAsync.value!, context, widget.isNew);
     _synced = true;
   }
   ```
   Similar patterns exist for wallets (`applyWalletSummary`) and open orders (`applyOpenOrdersFromGlobal`).

3) **Refresh explicitly when you need fresh data:**
   ```dart
   await ref.read(tradePairsProvider.notifier).refresh();
   // or ref.refresh(tradePairsProvider); // Riverpod built-in invalidation
   ```

4) **Single source of truth:** The `AsyncNotifier` keeps the latest successful result. Any screen that calls `ref.watch(...)` receives the same instance, eliminating per-tab network calls.

## Key code reference
```dart
// lib/Utility/global_state/global_providers.dart
class TradePairsNotifier extends AsyncNotifier<List<GlobalTradePair>> {
  @override
  Future<List<GlobalTradePair>> build() async => _fetch();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<List<GlobalTradePair>> _fetch() async {
    final response = await DashboardAPI().getTradePairList();
    // parse → List<GlobalTradePair>
  }
}
final tradePairsProvider =
    AsyncNotifierProvider<TradePairsNotifier, List<GlobalTradePair>>(
  TradePairsNotifier.new,
);
```
Wallet and open-order providers follow the same pattern with `WalletApi` and `HistoryApi`.

## Where it’s consumed (entry points)
- `lib/Views/Bottom_Pages/Wallet/wallet_view.dart`
- `lib/Views/Bottom_Pages/trade/spot_trade_page.dart`
- `lib/Views/Bottom_Pages/History/history_view.dart`

Each screen:
- Kicks off the global fetch in `initState`.
- Watches the provider and maps the result into its existing ChangeNotifier controller.
- Falls back to legacy API call only if the shared fetch fails.

## Operational notes
- Keep the per-screen `_synced` flags; they prevent repeated controller hydration on rebuilds.
- Use `refresh()` when users pull-to-refresh; it keeps loading states consistent.
- Because the cache is global, avoid mutating the model classes directly; map into local models first (as the controllers do) to keep UI state isolated.
