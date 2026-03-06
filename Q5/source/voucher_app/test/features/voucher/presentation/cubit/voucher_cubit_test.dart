import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voucher_app/features/voucher/domain/entities/voucher_instance.dart';
import 'package:voucher_app/features/voucher/presentation/cubit/voucher_cubit.dart';
import 'package:voucher_app/features/voucher/presentation/cubit/voucher_state.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockGetVouchers mockGetVouchers;
  late MockGenerateQrContent mockGenerateQrContent;

  setUpAll(() {
    registerFallbackValue(<VoucherInstance>[]);
  });

  setUp(() {
    mockGetVouchers = MockGetVouchers();
    mockGenerateQrContent = MockGenerateQrContent();
  });

  VoucherCubit buildCubit() => VoucherCubit(
        getVouchers: mockGetVouchers,
        generateQrContent: mockGenerateQrContent,
      );

  group('VoucherCubit', () {
    test('initial state is VoucherInitial', () {
      when(() => mockGetVouchers()).thenReturn(tAllVouchers);
      when(() => mockGenerateQrContent(any())).thenReturn('');
      final cubit = buildCubit();
      expect(cubit.state, isA<VoucherInitial>());
      cubit.close();
    });

    blocTest<VoucherCubit, VoucherState>(
      'loadVouchers emits VoucherLoaded',
      setUp: () {
        when(() => mockGetVouchers()).thenReturn(tAllVouchers);
        when(() => mockGenerateQrContent(any())).thenReturn('');
      },
      build: buildCubit,
      act: (cubit) => cubit.loadVouchers(),
      expect: () => [
        isA<VoucherLoaded>()
            .having((s) => s.vouchers, 'vouchers', tAllVouchers)
            .having((s) => s.totalAmount, 'totalAmount', 0)
            .having((s) => s.qrContent, 'qrContent', ''),
      ],
    );

    blocTest<VoucherCubit, VoucherState>(
      'toggleVoucher selects a voucher',
      setUp: () {
        when(() => mockGetVouchers()).thenReturn(tAllVouchers);
        when(() => mockGenerateQrContent(any())).thenReturn('2');
      },
      build: buildCubit,
      seed: () {
        when(() => mockGenerateQrContent(any())).thenReturn('');
        final cubit = buildCubit();
        cubit.loadVouchers();
        final state = cubit.state as VoucherLoaded;
        cubit.close();
        return state;
      },
      act: (cubit) {
        when(() => mockGenerateQrContent(any())).thenReturn('2');
        cubit.toggleVoucher('v2_1');
      },
      expect: () => [
        isA<VoucherLoaded>().having(
          (s) => s.vouchers.firstWhere((v) => v.id == 'v2_1').isSelected,
          'v2_1 selected',
          true,
        ),
      ],
    );

    blocTest<VoucherCubit, VoucherState>(
      'toggleVoucher deselects a selected voucher',
      setUp: () {
        when(() => mockGetVouchers()).thenReturn(tAllVouchers);
        when(() => mockGenerateQrContent(any())).thenReturn('');
      },
      build: buildCubit,
      seed: () => VoucherLoaded(
        vouchers: [tSelectedVoucher1, tVoucher2, tVoucher3],
        totalAmount: 2,
        qrContent: '2',
      ),
      act: (cubit) => cubit.toggleVoucher('v2_1'),
      expect: () => [
        isA<VoucherLoaded>().having(
          (s) => s.vouchers.firstWhere((v) => v.id == 'v2_1').isSelected,
          'v2_1 deselected',
          false,
        ),
      ],
    );

    blocTest<VoucherCubit, VoucherState>(
      'toggleVoucher supports multiple selections',
      setUp: () {
        when(() => mockGetVouchers()).thenReturn(tAllVouchers);
        when(() => mockGenerateQrContent(any())).thenReturn('2,5');
      },
      build: buildCubit,
      seed: () => VoucherLoaded(
        vouchers: [tSelectedVoucher1, tVoucher2, tVoucher3],
        totalAmount: 2,
        qrContent: '2',
      ),
      act: (cubit) => cubit.toggleVoucher('v5_1'),
      expect: () => [
        isA<VoucherLoaded>()
            .having(
              (s) => s.vouchers.where((v) => v.isSelected).length,
              'selected count',
              2,
            ),
      ],
    );

    blocTest<VoucherCubit, VoucherState>(
      'toggleVoucher no-op when state is not VoucherLoaded',
      setUp: () {
        when(() => mockGetVouchers()).thenReturn(tAllVouchers);
        when(() => mockGenerateQrContent(any())).thenReturn('');
      },
      build: buildCubit,
      // initial state is VoucherInitial
      act: (cubit) => cubit.toggleVoucher('v2_1'),
      expect: () => [],
    );

    test('startCountdown sets remainingSeconds to 300 and decrements', () {
      fakeAsync((async) {
        when(() => mockGetVouchers()).thenReturn(tAllVouchers);
        when(() => mockGenerateQrContent(any())).thenReturn('');
        final cubit = buildCubit();
        cubit.loadVouchers();

        cubit.startCountdown();
        expect(
          (cubit.state as VoucherLoaded).remainingSeconds,
          VoucherCubit.expiryDurationSeconds,
        );

        // After 1 second
        async.elapse(const Duration(seconds: 1));
        expect(
          (cubit.state as VoucherLoaded).remainingSeconds,
          VoucherCubit.expiryDurationSeconds - 1,
        );

        // After 10 seconds total
        async.elapse(const Duration(seconds: 9));
        expect(
          (cubit.state as VoucherLoaded).remainingSeconds,
          VoucherCubit.expiryDurationSeconds - 10,
        );

        cubit.close();
      });
    });

    test('countdown reaches 0 and timer stops', () {
      fakeAsync((async) {
        when(() => mockGetVouchers()).thenReturn(tAllVouchers);
        when(() => mockGenerateQrContent(any())).thenReturn('');
        final cubit = buildCubit();
        cubit.loadVouchers();

        cubit.startCountdown();

        // Advance to expiry
        async.elapse(const Duration(seconds: 300));
        expect((cubit.state as VoucherLoaded).remainingSeconds, 0);

        // Advance further — should stay at 0
        async.elapse(const Duration(seconds: 10));
        expect((cubit.state as VoucherLoaded).remainingSeconds, 0);

        cubit.close();
      });
    });

    test('stopCountdown freezes the timer', () {
      fakeAsync((async) {
        when(() => mockGetVouchers()).thenReturn(tAllVouchers);
        when(() => mockGenerateQrContent(any())).thenReturn('');
        final cubit = buildCubit();
        cubit.loadVouchers();

        cubit.startCountdown();
        async.elapse(const Duration(seconds: 5));
        final frozenSeconds = (cubit.state as VoucherLoaded).remainingSeconds;
        expect(frozenSeconds, VoucherCubit.expiryDurationSeconds - 5);

        cubit.stopCountdown();

        // Advance further — should stay frozen
        async.elapse(const Duration(seconds: 10));
        expect(
          (cubit.state as VoucherLoaded).remainingSeconds,
          frozenSeconds,
        );

        cubit.close();
      });
    });

    test('close cancels countdown timer', () {
      fakeAsync((async) {
        when(() => mockGetVouchers()).thenReturn(tAllVouchers);
        when(() => mockGenerateQrContent(any())).thenReturn('');
        final cubit = buildCubit();
        cubit.loadVouchers();

        cubit.startCountdown();
        cubit.close();

        // Advancing should not throw
        async.elapse(const Duration(seconds: 300));
      });
    });

    group('VoucherLoaded computed properties', () {
      test('selectedVouchers returns only selected', () {
        const state = VoucherLoaded(
          vouchers: [tSelectedVoucher1, tVoucher2, tSelectedVoucher2],
          totalAmount: 7,
          qrContent: '2,5',
        );

        expect(state.selectedVouchers, [tSelectedVoucher1, tSelectedVoucher2]);
      });

      test('hasSelection returns true when has selected vouchers', () {
        const withSelection = VoucherLoaded(
          vouchers: [tSelectedVoucher1],
          totalAmount: 2,
          qrContent: '2',
        );
        const withoutSelection = VoucherLoaded(
          vouchers: [tVoucher1],
          totalAmount: 0,
          qrContent: '',
        );

        expect(withSelection.hasSelection, true);
        expect(withoutSelection.hasSelection, false);
      });

      test('formattedTime formats MM:SS correctly', () {
        const state5min = VoucherLoaded(
          vouchers: [],
          totalAmount: 0,
          qrContent: '',
          remainingSeconds: 300,
        );
        expect(state5min.formattedTime, '05:00');

        const state1min30s = VoucherLoaded(
          vouchers: [],
          totalAmount: 0,
          qrContent: '',
          remainingSeconds: 90,
        );
        expect(state1min30s.formattedTime, '01:30');

        const state0 = VoucherLoaded(
          vouchers: [],
          totalAmount: 0,
          qrContent: '',
          remainingSeconds: 0,
        );
        expect(state0.formattedTime, '00:00');
      });

      test('isExpired returns true when remainingSeconds <= 0', () {
        const expired = VoucherLoaded(
          vouchers: [],
          totalAmount: 0,
          qrContent: '',
          remainingSeconds: 0,
        );
        const notExpired = VoucherLoaded(
          vouchers: [],
          totalAmount: 0,
          qrContent: '',
          remainingSeconds: 1,
        );

        expect(expired.isExpired, true);
        expect(notExpired.isExpired, false);
      });
    });
  });
}
