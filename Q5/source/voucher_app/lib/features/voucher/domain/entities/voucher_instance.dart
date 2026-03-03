import 'package:equatable/equatable.dart';

class VoucherInstance extends Equatable {
  final String id;
  final int amount;
  final String displayNumber;
  final bool isSelected;

  const VoucherInstance({
    required this.id,
    required this.amount,
    required this.displayNumber,
    this.isSelected = false,
  });

  VoucherInstance copyWith({bool? isSelected}) {
    return VoucherInstance(
      id: id,
      amount: amount,
      displayNumber: displayNumber,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [id, amount, displayNumber, isSelected];
}
