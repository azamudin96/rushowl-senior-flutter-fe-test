import 'package:get_it/get_it.dart';

import '../features/voucher/data/datasources/voucher_local_datasource.dart';
import '../features/voucher/data/repositories/voucher_repository_impl.dart';
import '../features/voucher/domain/repositories/voucher_repository.dart';
import '../features/voucher/domain/usecases/generate_qr_content.dart';
import '../features/voucher/domain/usecases/get_vouchers.dart';
import '../features/voucher/presentation/cubit/voucher_cubit.dart';

final sl = GetIt.instance;

void configureDependencies() {
  // Data sources
  sl.registerLazySingleton(() => VoucherLocalDatasource());

  // Repositories
  sl.registerLazySingleton<VoucherRepository>(
    () => VoucherRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetVouchers(sl()));
  sl.registerLazySingleton(() => const GenerateQrContent());

  // Cubits — factory so each screen creation gets a fresh instance
  sl.registerFactory(() => VoucherCubit(
        getVouchers: sl(),
        generateQrContent: sl(),
      ));
}
