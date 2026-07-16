import '../../../../../core/utils/app_exports.dart';
import '../../../../../components/custom_textfield.dart';

class ArtistLabeledField extends StatelessWidget {
  const ArtistLabeledField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.prefixWidget,
    this.isObscure = false,
    this.isSuffix = false,
    this.isLast = false,
    this.textInputType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.validator,
    this.textAlignVertical,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final Widget? prefixWidget;
  final bool isObscure;
  final bool isSuffix;
  final bool isLast;
  final TextInputType? textInputType;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? minLines;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? Function(String?)? validator;
  final TextAlignVertical? textAlignVertical;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.gray300,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        8.ph,
        CustomTextField(
          hintText: hintText,
          controller: controller,
          isPrefix: prefixWidget != null,
          prefixWidget: prefixWidget,
          isObscure: isObscure,
          isSuffix: isSuffix,
          isLast: isLast,
          textInputType: textInputType ?? TextInputType.text,
          textCapitalization: textCapitalization,
          textAlign: TextAlign.start,
          textAlignVertical: textAlignVertical,
          maxLines: maxLines,
          minLines: minLines,
          onChanged: onChanged,
          onTap: onTap,
          readOnly: readOnly,
          validator: validator,
          fillColor: AppColors.listenerChipBg,
          enableBorderColor: AppColors.listenerChipBorder,
          focusedBorderColor: AppColors.listenerYellow,
          cursorColor: AppColors.primaryWhite,
          textStyle: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.primaryWhite,
            fontSize: 14.sp,
          ),
          hintTextStyle: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.gray500,
            fontSize: 14.sp,
          ),
          contentPadding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: minLines != null && minLines! > 1 ? 12.h : 12.h,
            bottom: 16.h,
          ),
          inputBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ],
    );
  }
}
