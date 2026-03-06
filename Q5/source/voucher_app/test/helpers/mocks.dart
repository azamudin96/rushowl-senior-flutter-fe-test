import 'package:mocktail/mocktail.dart';
import 'package:voucher_app/features/voucher/domain/entities/voucher_instance.dart';
import 'package:voucher_app/features/voucher/domain/repositories/voucher_repository.dart';
import 'package:voucher_app/features/voucher/domain/usecases/generate_qr_content.dart';
import 'package:voucher_app/features/voucher/domain/usecases/get_vouchers.dart';

class MockVoucherRepository extends Mock implements VoucherRepository {}

class MockGetVouchers extends Mock implements GetVouchers {}

class MockGenerateQrContent extends Mock implements GenerateQrContent {}

class FakeVoucherInstanceList extends Fake implements List<VoucherInstance> {}
