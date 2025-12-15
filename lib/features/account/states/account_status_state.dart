class AccountStatusState {
  final bool isLoading;
  final bool isBlocked;
  final String? blockReason;
  final Map<String, dynamic>? staffData;

  const AccountStatusState({
    this.isLoading = true,
    this.isBlocked = false,
    this.blockReason,
    this.staffData,
  });

  AccountStatusState copyWith({
    bool? isLoading,
    bool? isBlocked,
    String? blockReason,
    Map<String, dynamic>? staffData,
  }) {
    return AccountStatusState(
      isLoading: isLoading ?? this.isLoading,
      isBlocked: isBlocked ?? this.isBlocked,
      blockReason: blockReason ?? this.blockReason,
      staffData: staffData ?? this.staffData,
    );
  }
}
