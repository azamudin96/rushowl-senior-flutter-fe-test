import 'package:equatable/equatable.dart';

import '../../domain/entities/voucher_instance.dart';

abstract class VoucherState extends Equatable {
  const VoucherState();

  @override
  List<Object?> get props => [];
}

class VoucherInitial extends VoucherState {
  const VoucherInitial();
}

class VoucherLoaded extends VoucherState {
  final List<VoucherInstance> vouchers;
  final int totalAmount;
  final String qrContent;
  final int remainingSeconds;

  const VoucherLoaded({
    required this.vouchers,
    required this.totalAmount,
    required this.qrContent,
    this.remainingSeconds = 0,
  });

  List<VoucherInstance> get selectedVouchers =>
      vouchers.where((v) => v.isSelected).toList();

  bool get hasSelection => selectedVouchers.isNotEmpty;

  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get isExpired => remainingSeconds <= 0;

  @override
  List<Object?> get props => [vouchers, totalAmount, qrContent, remainingSeconds];
}
