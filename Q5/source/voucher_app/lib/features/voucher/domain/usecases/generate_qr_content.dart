import '../entities/voucher_instance.dart';

class GenerateQrContent {
  const GenerateQrContent();

  String call(List<VoucherInstance> vouchers) {
    final selected = vouchers.where((v) => v.isSelected).toList()
      ..sort((a, b) {
        final amountCompare = a.amount.compareTo(b.amount);
        if (amountCompare != 0) return amountCompare;
        return a.id.compareTo(b.id);
      });

    return selected.map((v) => v.amount.toString()).join(',');
  }
}
