import '../entities/voucher_instance.dart';

abstract class VoucherRepository {
  List<VoucherInstance> getVouchers();
}
