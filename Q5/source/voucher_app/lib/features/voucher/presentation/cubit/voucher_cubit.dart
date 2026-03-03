import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/voucher_instance.dart';
import '../../domain/usecases/generate_qr_content.dart';
import '../../domain/usecases/get_vouchers.dart';
import 'voucher_state.dart';

class VoucherCubit extends Cubit<VoucherState> {
  final GetVouchers getVouchers;
  final GenerateQrContent generateQrContent;

  static const int expiryDurationSeconds = 5 * 60;
  Timer? _countdownTimer;

  VoucherCubit({
    required this.getVouchers,
    required this.generateQrContent,
  }) : super(const VoucherInitial());

  void loadVouchers() {
    final vouchers = getVouchers();
    _emitLoaded(vouchers);
  }

  void toggleVoucher(String id) {
    final currentState = state;
    if (currentState is! VoucherLoaded) return;

    final updatedVouchers = currentState.vouchers.map((v) {
      if (v.id == id) {
        return v.copyWith(isSelected: !v.isSelected);
      }
      return v;
    }).toList();

    _emitLoaded(updatedVouchers);
  }

  void startCountdown() {
    _countdownTimer?.cancel();
    final currentState = state;
    if (currentState is! VoucherLoaded) return;

    emit(VoucherLoaded(
      vouchers: currentState.vouchers,
      totalAmount: currentState.totalAmount,
      qrContent: currentState.qrContent,
      remainingSeconds: expiryDurationSeconds,
    ));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is! VoucherLoaded) return;

      final next = s.remainingSeconds - 1;
      if (next <= 0) {
        _countdownTimer?.cancel();
        emit(VoucherLoaded(
          vouchers: s.vouchers,
          totalAmount: s.totalAmount,
          qrContent: s.qrContent,
          remainingSeconds: 0,
        ));
      } else {
        emit(VoucherLoaded(
          vouchers: s.vouchers,
          totalAmount: s.totalAmount,
          qrContent: s.qrContent,
          remainingSeconds: next,
        ));
      }
    });
  }

  void stopCountdown() {
    _countdownTimer?.cancel();
  }

  void _emitLoaded(List<VoucherInstance> vouchers) {
    final selected = vouchers.where((v) => v.isSelected);
    final total = selected.fold<int>(0, (sum, v) => sum + v.amount);
    final qrContent = generateQrContent(vouchers);

    final currentState = state;
    final remaining = currentState is VoucherLoaded
        ? currentState.remainingSeconds
        : 0;

    emit(VoucherLoaded(
      vouchers: vouchers,
      totalAmount: total,
      qrContent: qrContent,
      remainingSeconds: remaining,
    ));
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
