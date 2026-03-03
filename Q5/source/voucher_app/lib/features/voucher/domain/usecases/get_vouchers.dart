import '../entities/voucher_instance.dart';
import '../repositories/voucher_repository.dart';

class GetVouchers {
  final VoucherRepository repository;

  const GetVouchers(this.repository);

  List<VoucherInstance> call() {
    return repository.getVouchers();
  }
}
