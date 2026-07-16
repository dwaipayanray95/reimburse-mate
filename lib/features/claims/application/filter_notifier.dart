import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/models/claim_status.dart';
import 'package:reimburse_mate/models/expense_category.dart';

enum SortOption { dateNewest, dateOldest, amountHighest, amountLowest, project }

class FilterState {
  final ClaimStatus? statusFilter;
  final ExpenseCategory? categoryFilter;
  final String searchQuery;
  final SortOption sortBy;

  FilterState({
    this.statusFilter,
    this.categoryFilter,
    this.searchQuery = '',
    this.sortBy = SortOption.dateNewest,
  });

  FilterState copyWith({
    ClaimStatus? statusFilter,
    ExpenseCategory? categoryFilter,
    String? searchQuery,
    SortOption? sortBy,
    bool clearStatus = false,
    bool clearCategory = false,
  }) {
    return FilterState(
      statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
      categoryFilter: clearCategory ? null : (categoryFilter ?? this.categoryFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(FilterState());

  void setStatus(ClaimStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
  }

  void setCategory(ExpenseCategory? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryFilter: category);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortBy: option);
  }

  void reset() {
    state = FilterState();
  }
}
