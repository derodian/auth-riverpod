import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomMultipleLineTextFormField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool isRequired;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final bool isEnabled;
  final int? maxLength;
  final int? maxLines; // Changed to nullable
  final int? minLines; // Added for flexible height
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final Widget? prefix;
  final Widget? suffix;
  final bool showCounter; // Added for character count
  final bool enableInteractiveSelection; // Added for copy/paste
  final TextInputAction? textInputAction; // Added for keyboard action
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding; // Added for custom padding
  final bool isDense; // Added for compact layout option

  const CustomMultipleLineTextFormField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.isRequired = true,
    this.validator,
    this.onChanged,
    this.controller,
    this.isEnabled = true,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.onTap,
    this.prefix,
    this.suffix,
    this.showCounter = false,
    this.enableInteractiveSelection = true,
    this.textInputAction,
    this.autofocus = false,
    this.contentPadding,
    this.isDense = false,
  });

  @override
  State<CustomMultipleLineTextFormField> createState() =>
      _CustomMultipleLineTextFormFieldState();
}

class _CustomMultipleLineTextFormFieldState
    extends State<CustomMultipleLineTextFormField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label + (widget.isRequired ? ' *' : ''),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword ? _obscureText : false,
            enabled: widget.isEnabled,
            maxLength: widget.maxLength,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            minLines: widget.minLines,
            inputFormatters: widget.inputFormatters,
            textCapitalization: widget.textCapitalization,
            focusNode: widget.focusNode,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            autofocus: widget.autofocus,
            enableInteractiveSelection: widget.enableInteractiveSelection,
            textInputAction: widget.textInputAction,
            validator: widget.validator ??
                (widget.isRequired
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return '${widget.label} is required';
                        }
                        return null;
                      }
                    : null),
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefix,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffix,
              filled: true,
              isDense: widget.isDense,
              contentPadding: widget.contentPadding ??
                  EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: widget.maxLines != null ? 16 : 12,
                  ),
              counterText: widget.showCounter ? null : '',
              fillColor: widget.isEnabled
                  ? _isFocused
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
