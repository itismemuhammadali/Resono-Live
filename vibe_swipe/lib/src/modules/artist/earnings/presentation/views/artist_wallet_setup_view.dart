import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vibe_swipe/src/core/theme/app_colors.dart';
import 'package:vibe_swipe/src/core/utils/app_extensions.dart';
import 'package:vibe_swipe/src/core/services/routing_service/named_routes.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/components/in_app_alert.dart';
import '../controllers/artist_earnings_controller.dart';

class ArtistWalletSetupView extends ConsumerStatefulWidget {
  const ArtistWalletSetupView({super.key});

  @override
  ConsumerState<ArtistWalletSetupView> createState() => _ArtistWalletSetupViewState();
}

class _ArtistWalletSetupViewState extends ConsumerState<ArtistWalletSetupView> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedMethod = 'bank'; // 'bank', 'paypal', 'crypto'
  
  // Bank fields
  final _bankNameController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();
  
  // PayPal fields
  final _paypalEmailController = TextEditingController();
  
  // Crypto fields
  final _cryptoAddressController = TextEditingController();
  String _selectedNetwork = 'ERC-20';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wallet = ref.read(artistEarningsControllerProvider).payoutWallet;
      if (wallet.isNotEmpty) {
        setState(() {
          _selectedMethod = wallet['payoutMethod'] ?? 'bank';
          if (_selectedMethod == 'bank') {
            _bankNameController.text = wallet['bankName'] ?? '';
            _holderNameController.text = wallet['accountHolderName'] ?? '';
            _accountNumberController.text = wallet['accountNumber'] ?? '';
            _routingNumberController.text = wallet['routingNumber'] ?? '';
          } else if (_selectedMethod == 'paypal') {
            _paypalEmailController.text = wallet['paypalEmail'] ?? '';
          } else if (_selectedMethod == 'crypto') {
            _cryptoAddressController.text = wallet['cryptoAddress'] ?? '';
            _selectedNetwork = wallet['cryptoNetwork'] ?? 'ERC-20';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _holderNameController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _paypalEmailController.dispose();
    _cryptoAddressController.dispose();
    super.dispose();
  }

  void _saveWallet() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(artistEarningsControllerProvider.notifier);
    
    final Map<String, dynamic> walletData = {
      'payoutMethod': _selectedMethod,
    };

    if (_selectedMethod == 'bank') {
      walletData['bankName'] = _bankNameController.text.trim();
      walletData['accountHolderName'] = _holderNameController.text.trim();
      walletData['accountNumber'] = _accountNumberController.text.trim();
      walletData['routingNumber'] = _routingNumberController.text.trim();
    } else if (_selectedMethod == 'paypal') {
      walletData['paypalEmail'] = _paypalEmailController.text.trim();
    } else if (_selectedMethod == 'crypto') {
      walletData['cryptoAddress'] = _cryptoAddressController.text.trim();
      walletData['cryptoNetwork'] = _selectedNetwork;
    }

    try {
      await controller.saveWalletDetails(walletData);
      if (mounted) {
        InAppAlert.show(context, message: 'Payout details saved successfully!', isSuccess: true);
        AppRouterGo.back();
      }
    } catch (e) {
      if (mounted) {
        InAppAlert.show(context, message: 'Failed to save payout details: $e', isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(artistEarningsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryWhite),
          onPressed: () => AppRouterGo.back(),
        ),
        title: Text(
          'Payout Settings',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryWhite,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Payout Method',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryWhite,
                  ),
                ),
                16.ph,
                Row(
                  children: [
                    _buildMethodTab('bank', Icons.account_balance_rounded, 'Bank'),
                    8.pw,
                    _buildMethodTab('paypal', Icons.payment_rounded, 'PayPal'),
                    8.pw,
                    _buildMethodTab('crypto', Icons.currency_bitcoin_rounded, 'Crypto'),
                  ],
                ),
                32.ph,
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildFormFields(),
                ),
                40.ph,
                PrimaryElevatedButton(
                  onTap: _saveWallet,
                  text: 'Save Payout Method',
                  loader: controller.isLoading,
                  backgroundColor: AppColors.listenerYellow,
                  textColor: AppColors.primaryblack,
                  radius: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodTab(String method, IconData icon, String label) {
    final isSelected = _selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = method),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.listenerYellow : AppColors.listenerChipBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.listenerYellow : AppColors.listenerChipBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryblack : AppColors.primaryWhite,
                size: 20.sp,
              ),
              6.ph,
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primaryblack : AppColors.primaryWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    switch (_selectedMethod) {
      case 'bank':
        return Column(
          key: const ValueKey('bank_form'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _bankNameController,
              label: 'Bank Name',
              hint: 'e.g. Chase Bank',
              validator: (v) => v == null || v.isEmpty ? 'Bank Name is required' : null,
            ),
            16.ph,
            _buildTextField(
              controller: _holderNameController,
              label: 'Account Holder Name',
              hint: 'John Doe',
              validator: (v) => v == null || v.isEmpty ? 'Account Holder Name is required' : null,
            ),
            16.ph,
            _buildTextField(
              controller: _accountNumberController,
              label: 'Account Number',
              hint: '1234567890',
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.length < 4 ? 'Enter a valid account number' : null,
            ),
            16.ph,
            _buildTextField(
              controller: _routingNumberController,
              label: 'Routing Number',
              hint: '9-digit routing number',
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.length < 9 ? 'Enter a 9-digit routing number' : null,
            ),
          ],
        );
      case 'paypal':
        return Column(
          key: const ValueKey('paypal_form'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _paypalEmailController,
              label: 'PayPal Email Address',
              hint: 'artist@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                return null;
              },
            ),
          ],
        );
      case 'crypto':
        return Column(
          key: const ValueKey('crypto_form'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _cryptoAddressController,
              label: 'Crypto Wallet Address',
              hint: '0x...',
              validator: (v) => v == null || v.length < 10 ? 'Enter a valid wallet address' : null,
            ),
            16.ph,
            Text(
              'Blockchain Network',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.santagrey,
              ),
            ),
            8.ph,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.listenerChipBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.listenerChipBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedNetwork,
                  dropdownColor: AppColors.listenerDashboardBg,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryWhite),
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 15.sp,
                    color: AppColors.primaryWhite,
                  ),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedNetwork = v);
                    }
                  },
                  items: ['ERC-20', 'TRC-20', 'BSC (BEP-20)', 'Solana']
                      .map((net) => DropdownMenuItem(
                            value: net,
                            child: Text(net),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.santagrey,
          ),
        ),
        8.ph,
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 15.sp,
            color: AppColors.primaryWhite,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15.sp,
              color: AppColors.santagrey,
            ),
            filled: true,
            fillColor: AppColors.listenerChipBg,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.listenerChipBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.listenerYellow),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.eventRed),
            ),
          ),
        ),
      ],
    );
  }
}
