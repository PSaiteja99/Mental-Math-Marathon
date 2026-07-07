import 'package:flutter_riverpod/flutter_riverpod.dart';

final tabResetProvider = StateNotifierProvider<TabResetNotifier, List<int>>((ref) {
  return TabResetNotifier();
});

class TabResetNotifier extends StateNotifier<List<int>> {
  TabResetNotifier() : super([0, 0, 0, 0]);

  void reset(int tabIndex) {
    final newState = [...state];
    newState[tabIndex]++;
    state = newState;
  }
}
