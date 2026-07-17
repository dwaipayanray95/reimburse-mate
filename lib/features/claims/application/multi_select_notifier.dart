import 'package:flutter_riverpod/flutter_riverpod.dart';

class MultiSelectState {
  final Set<String> selectedIds;
  final bool isMultiSelectMode;

  MultiSelectState({
    required this.selectedIds,
    required this.isMultiSelectMode,
  });

  MultiSelectState copyWith({
    Set<String>? selectedIds,
    bool? isMultiSelectMode,
  }) {
    return MultiSelectState(
      selectedIds: selectedIds ?? this.selectedIds,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
    );
  }
}

class MultiSelectNotifier extends StateNotifier<MultiSelectState> {
  MultiSelectNotifier() : super(MultiSelectState(selectedIds: {}, isMultiSelectMode: false));

  void toggle(String id) {
    final updated = Set<String>.from(state.selectedIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = state.copyWith(
      selectedIds: updated,
      isMultiSelectMode: updated.isNotEmpty,
    );
  }

  void enterSelectMode() {
    state = MultiSelectState(selectedIds: {}, isMultiSelectMode: true);
  }

  void selectAll(List<String> ids) {
    state = state.copyWith(
      selectedIds: Set<String>.from(ids),
      isMultiSelectMode: true,
    );
  }

  void clearSelection() {
    state = MultiSelectState(selectedIds: {}, isMultiSelectMode: false);
  }
}
