import 'package:voucher_app/features/voucher/domain/entities/voucher_instance.dart';

const tVoucher1 = VoucherInstance(
  id: 'v2_1',
  amount: 2,
  displayNumber: '#8812',
);

const tVoucher2 = VoucherInstance(
  id: 'v5_1',
  amount: 5,
  displayNumber: '#9021',
);

const tVoucher3 = VoucherInstance(
  id: 'v10_1',
  amount: 10,
  displayNumber: '#7740',
);

const tSelectedVoucher1 = VoucherInstance(
  id: 'v2_1',
  amount: 2,
  displayNumber: '#8812',
  isSelected: true,
);

const tSelectedVoucher2 = VoucherInstance(
  id: 'v5_1',
  amount: 5,
  displayNumber: '#9021',
  isSelected: true,
);

const tAllVouchers = [
  VoucherInstance(id: 'v2_1', amount: 2, displayNumber: '#8812'),
  VoucherInstance(id: 'v2_2', amount: 2, displayNumber: '#8813'),
  VoucherInstance(id: 'v5_1', amount: 5, displayNumber: '#9021'),
  VoucherInstance(id: 'v5_2', amount: 5, displayNumber: '#9022'),
  VoucherInstance(id: 'v10_1', amount: 10, displayNumber: '#7740'),
  VoucherInstance(id: 'v10_2', amount: 10, displayNumber: '#7741'),
];
