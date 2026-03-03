import '../../domain/entities/voucher_instance.dart';
import '../../domain/repositories/voucher_repository.dart';
import '../datasources/voucher_local_datasource.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherLocalDatasource datasource;

  const VoucherRepositoryImpl(this.datasource);

  @override
  List<VoucherInstance> getVouchers() {
    return datasource.getVouchers();
  }
}
