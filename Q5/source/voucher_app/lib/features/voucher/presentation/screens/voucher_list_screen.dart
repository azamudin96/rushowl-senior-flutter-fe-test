import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../di/injection.dart';
import '../cubit/voucher_cubit.dart';
import '../cubit/voucher_state.dart';
import '../widgets/pay_button.dart';
import '../widgets/voucher_card.dart';
import 'qr_code_screen.dart';

class VoucherListScreen extends StatelessWidget {
  const VoucherListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VoucherCubit>()..loadVouchers(),
      child: const _VoucherListView(),
    );
  }
}

class _VoucherListView extends StatelessWidget {
  const _VoucherListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Select Vouchers',
          style: TextStyle(color: AppColors.primary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.borderDark,
          ),
        ),
      ),
      body: BlocBuilder<VoucherCubit, VoucherState>(
        builder: (context, state) {
          if (state is! VoucherLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Section header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 24, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AVAILABLE VOUCHERS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Select one or more vouchers to pay',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Voucher grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.15,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final voucher = state.vouchers[index];
                            return VoucherCard(
                              voucher: voucher,
                              onTap: () => context
                                  .read<VoucherCubit>()
                                  .toggleVoucher(voucher.id),
                            );
                          },
                          childCount: state.vouchers.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                  ],
                ),
              ),
              PayButton(
                totalAmount: state.totalAmount,
                selectedCount: state.selectedVouchers.length,
                enabled: state.hasSelection,
                onPressed: () {
                  final cubit = context.read<VoucherCubit>();
                  cubit.startCountdown();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: const QrCodeScreen(),
                      ),
                    ),
                  ).then((_) => cubit.stopCountdown());
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
