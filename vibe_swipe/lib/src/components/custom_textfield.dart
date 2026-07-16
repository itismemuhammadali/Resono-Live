import 'dart:async';
import '../core/utils/app_exports.dart';

// ignore: must_be_immutable
class CustomTextField extends StatefulWidget with AppSize {
  final TextEditingController? controller;
  final String? hintText;
  final int? maxLength;
  bool isObscure;
  final bool isPrefix;
  final bool isSuffix;
  final Widget? suffixbutton;
  final int? minLines;
  final TextInputType textInputType;
  final TextAlign textAlign;
  final String? suffixIcon;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool focus;
  final bool? enabled;
  final OutlineInputBorder? inputBorder;
  void Function(String)? onFieldSubmitted;
  final bool enableInteractiveSelection;
  final bool removeSpacing;
  final Color? fillColor;
  final Widget? prefixWidget;
  final TextStyle? hintTextStyle;
  final Color? enableBorderColor;
  final TextCapitalization textCapitalization;
  final bool isLast;
  final TextStyle? textStyle;
  final Color? focusedBorderColor;
  final Color? cursorColor;
  final EdgeInsetsGeometry? contentPadding;
  final double? fieldBorderRadius;
  final double? borderWidth;
  final TextAlignVertical? textAlignVertical;

  CustomTextField({
    super.key,
    this.onFieldSubmitted,
    this.controller,
    this.hintText,
    this.isObscure = false,
    this.isSuffix = false,
    this.isPrefix = false,
    this.textInputType = TextInputType.text,
    this.suffixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.focus = false,
    this.onChanged,
    this.validator,
    this.inputBorder,
    this.maxLength,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.onEditingComplete,
    this.enabled,
    this.enableInteractiveSelection = true,
    this.removeSpacing = false,
    this.fillColor,
    this.prefixWidget,
    this.hintTextStyle,
    this.enableBorderColor,
    this.textCapitalization = TextCapitalization.none,
    this.suffixbutton,
    this.minLines,
    this.isLast = false,
    this.textStyle,
    this.focusedBorderColor,
    this.cursorColor,
    this.contentPadding,
    this.fieldBorderRadius,
    this.borderWidth,
    this.textAlignVertical,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    if (widget.removeSpacing) {
      widget.controller?.addListener(removeSpaces);
    }
  }

  void removeSpaces() {
    String? text = widget.controller?.text;
    if (text!.contains(' ')) {
      // Cancel any previous timer to avoid multiple triggers
      _timer?.cancel();

      // Start a new timer with a brief delay
      _timer = Timer(const Duration(milliseconds: 500), () {
        // Remove spaces and update text
        widget.controller?.text = text.replaceAll(' ', '');
        // Move cursor to the end of the text
        widget.controller?.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller!.text.length),
        );
      });
    }
  }

  @override
  void dispose() {
    if (widget.removeSpacing) {
      widget.controller?.removeListener(removeSpaces);
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: widget.minLines,

      enableInteractiveSelection: widget
          .enableInteractiveSelection, // For copy & Paste OPtion Enable and Disable
      contextMenuBuilder: widget.enableInteractiveSelection
          ? (context, editableTextState) {
              return AdaptiveTextSelectionToolbar.editableText(
                editableTextState: editableTextState,
              );
            }
          : (context, editableTextState) {
              return const SizedBox.shrink();
            },
      onFieldSubmitted: widget.onFieldSubmitted,
      textCapitalization: widget.textCapitalization,
      enabled: widget.enabled,
      textInputAction: widget.isLast
          ? TextInputAction.done
          : TextInputAction.next,
      onTap: widget.onTap,
      onChanged: widget.onChanged,

      onEditingComplete: widget.onEditingComplete,
      keyboardType: widget.textInputType,
      enableSuggestions: false,
      focusNode: widget.focusNode,
      autocorrect: false,
      readOnly: widget.readOnly,
      controller: widget.controller,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      maxLength: widget.maxLength,
      cursorColor: widget.cursorColor ?? AppColors.listenerCursorDark,
      style: widget.textStyle ?? AppTextTheme.bodyLabelBlack,
      obscureText: widget.isObscure,
      maxLines: widget.maxLines,

      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        // errorMaxLines: 6,
        prefixIcon: widget.isPrefix ? widget.prefixWidget : null,
        isDense: true,
        counterText: "",
        filled: true,

        suffixIcon: widget.isSuffix
            ? IconButton(
                splashRadius: 25.r,

                onPressed: () {
                  setState(() {
                    widget.isObscure = !widget.isObscure;
                  });
                },
                icon: widget.suffixIcon == null
                    ? Icon(
                        !widget.isObscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: widget.isMobile ? 18 : 24,
                      )
                    : SvgPicture.asset(widget.suffixIcon!),
              )
            : widget.suffixbutton,
        fillColor: widget.fillColor ?? AppColors.shadeGrey,
        contentPadding:
            widget.contentPadding ??
            const EdgeInsets.only(left: 16, right: 16, top: 30),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.focus
                ? AppColors.primaryGreen
                : widget.enableBorderColor ?? AppColors.inactiveGray,
            width: widget.borderWidth ?? 1.0,
          ),
          borderRadius: BorderRadius.circular((widget.fieldBorderRadius ?? 12).r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color:
                widget.focusedBorderColor ??
                (widget.focus ? AppColors.primaryGreen : AppColors.borderGreen),
            width: widget.borderWidth ?? 1.0,
          ),
          borderRadius: BorderRadius.circular((widget.fieldBorderRadius ?? 12).r),
        ),
        errorBorder:
            widget.inputBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.focus ? AppColors.eventRed : AppColors.eventRed,
                width: widget.borderWidth ?? 1.0,
              ),
              borderRadius: BorderRadius.circular((widget.fieldBorderRadius ?? 12).r),
            ),
        border:
            widget.inputBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.focus
                    ? AppColors.primaryGreen
                    : AppColors.borderGreen,
                width: widget.borderWidth ?? 1.0,
              ),
              borderRadius: BorderRadius.circular((widget.fieldBorderRadius ?? 12).r),
            ),
        hintText: widget.hintText ?? '',
        hintStyle:
            widget.hintTextStyle ??
            TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.huegrey,
            ),
      ),
    );
  }
}
