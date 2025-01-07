import 'package:auth_riverpod/src/features/widgets/address_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

enum InfoType {
  email,
  phone,
  address,
  name,
  date,
  url,
  text,
  currency,
  percentage,
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final InfoType type;
  final VoidCallback? onTap;
  final bool isVerified;
  final bool copyable;
  final bool isLoading;
  final String? errorText;
  final String? notProvidedText;
  final bool showDistance;
  final bool showElapsedTime;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.type = InfoType.text,
    this.onTap,
    this.errorText,
    this.notProvidedText,
    this.isVerified = false,
    this.copyable = false,
    this.isLoading = false,
    this.showDistance = false,
    this.showElapsedTime = true,
  });

  String get formattedValue {
    // If value is null or empty, return the custom or default "not provided" message
    if (value == null || value!.isEmpty) {
      return _getNotProvidedText();
    }

    switch (type) {
      case InfoType.email:
        return value!.toLowerCase();

      case InfoType.phone:
        // Format phone number: (XXX) XXX-XXXX
        final cleaned = value!.replaceAll(RegExp(r'[^\d]'), '');
        if (cleaned.length == 10) {
          return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
        }
        return value!;

      case InfoType.address:
        // Capitalize first letter of each word
        return value!
            .split(' ')
            .map((word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '')
            .join(' ');

      case InfoType.name:
        // Capitalize first letter of each word
        return value!
            .split(' ')
            .map((word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                : '')
            .join(' ');

      case InfoType.date:
        try {
          final dateTime = DateTime.parse(value!);
          final bool hasTime = _hasTimeComponent(value!);

          // Get the user's locale
          final String locale = Intl.getCurrentLocale();

          if (hasTime) {
            // Format with both date and time
            final dateStr = DateFormat.yMMMd(locale).format(dateTime);
            final timeStr =
                DateFormat.jm(locale).format(dateTime); // 12-hour format
            // Or use DateFormat.Hm(locale) for 24-hour format

            return '$dateStr at $timeStr';
          } else {
            // Format date only
            return DateFormat.yMMMd(locale).format(dateTime);
          }
        } catch (e) {
          return value!;
        }

      case InfoType.currency:
        try {
          final amount = double.parse(value!);
          return NumberFormat.currency(symbol: '\$').format(amount);
        } catch (e) {
          return value!;
        }

      case InfoType.percentage:
        try {
          final number = double.parse(value!);
          return '${number.toStringAsFixed(1)}%';
        } catch (e) {
          return value!;
        }

      case InfoType.url:
        return value!.replaceAll(RegExp(r'https?://'), '');

      default:
        return value!;
    }
  }

  bool _hasTimeComponent(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return dateTime.hour != 0 ||
          dateTime.minute != 0 ||
          dateTime.second != 0 ||
          dateString.contains('T') ||
          dateString.contains(' ');
    } catch (e) {
      return false;
    }
  }

  String _getNotProvidedText() {
    if (notProvidedText != null) return notProvidedText!;

    // Default messages based on type
    switch (type) {
      case InfoType.phone:
        return 'No phone number provided';
      case InfoType.email:
        return 'No email address provided';
      case InfoType.address:
        return 'No address provided';
      case InfoType.name:
        return 'No name provided';
      case InfoType.date:
        return 'Date not available';
      case InfoType.currency:
        return 'No amount available';
      case InfoType.percentage:
        return 'No percentage available';
      case InfoType.url:
        return 'No URL provided';
      default:
        return 'Not provided';
    }
  }

  bool get _isValueMissing => value == null || value!.isEmpty;

  void _handleCopy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: value!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${label.toLowerCase()} copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMultiLine =
        type == InfoType.address || (type == InfoType.date && showElapsedTime);

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(label),
            const Spacer(),
            const SizedBox(
              width: 100,
              child: LinearProgressIndicator(),
            ),
          ],
        ),
      );
    }

    // Special handling for address type with distance
    if (type == InfoType.address && showDistance && !_isValueMissing) {
      return _buildAddressRow(context: context, address: value!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side with icon and label
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.30,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: _isValueMissing
                          ? Colors.grey.withOpacity(0.5)
                          : (onTap != null
                              ? Theme.of(context).primaryColor
                              : Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _isValueMissing
                              ? Colors.grey.withOpacity(0.7)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right side with value and secondary info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Main value row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isVerified && !_isValueMissing) ...[
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            formattedValue,
                            style: _getValueStyle(context),
                            textAlign: TextAlign.end,
                            softWrap: isMultiLine,
                          ),
                        ),
                        if (copyable && !_isValueMissing) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: () => _handleCopy(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ],
                    ),

                    // Secondary info (elapsed time or distance)
                    if (!_isValueMissing && _hasSecondaryInfo) ...[
                      const SizedBox(height: 4),
                      Text(
                        _getSecondaryInfo(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Error text
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final bool isMultiLine =
  //       type == InfoType.address || (type == InfoType.date && showElapsedTime);

  //   if (isLoading) {
  //     return Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 8),
  //       child: Row(
  //         crossAxisAlignment: isMultiLine
  //             ? CrossAxisAlignment.start
  //             : CrossAxisAlignment.center,
  //         children: [
  //           Icon(icon, size: 20, color: Colors.grey),
  //           const SizedBox(width: 8),
  //           Text(label),
  //           const Spacer(),
  //           const SizedBox(
  //             width: 100,
  //             child: LinearProgressIndicator(),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   // Special handling for address type with distance
  //   if (type == InfoType.address && showDistance && !_isValueMissing) {
  //     return _buildAddressRow(context: context, address: value!);
  //   }
  //   return InkWell(
  //     onTap: _isValueMissing ? null : onTap, // Disable tap if value is missing,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 8),
  //           child: Row(
  //             children: [
  //               // Left side with icon and label
  //               SizedBox(
  //                 width: MediaQuery.of(context).size.width *
  //                     0.35, // 35% of screen width
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     Icon(
  //                       icon,
  //                       size: 20,
  //                       color: _isValueMissing
  //                           ? Colors.grey.withOpacity(0.5)
  //                           : (onTap != null
  //                               ? Theme.of(context).primaryColor
  //                               : Colors.grey),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Flexible(
  //                       child: Text(
  //                         label,
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.w500,
  //                           color: _isValueMissing
  //                               ? Colors.grey.withOpacity(0.7)
  //                               : null,
  //                         ),
  //                       ),
  //                     ),
  //                     if (isVerified && !_isValueMissing) ...[
  //                       const SizedBox(width: 4),
  //                       Icon(
  //                         Icons.verified,
  //                         size: 16,
  //                         color: Theme.of(context).primaryColor,
  //                       ),
  //                     ],
  //                   ],
  //                 ),
  //               ),

  //               // Right side with value
  //               Expanded(
  //                 child: Column(
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         if (isVerified) ...[
  //                           Icon(
  //                             Icons.verified,
  //                             size: 16,
  //                             color: Theme.of(context).primaryColor,
  //                           ),
  //                           const SizedBox(width: 4),
  //                         ],
  //                         Flexible(
  //                           child: type == InfoType.date
  //                               ? Column(
  //                                   crossAxisAlignment: CrossAxisAlignment.end,
  //                                   children: _buildDateContent(context),
  //                                 )
  //                               : Text(
  //                                   formattedValue,
  //                                   style: _getValueStyle(context),
  //                                   textAlign: TextAlign.end,
  //                                   softWrap: isMultiLine,
  //                                 ),
  //                         ),
  //                         if (copyable && !_isValueMissing) ...[
  //                           const SizedBox(width: 4),
  //                           IconButton(
  //                             icon: const Icon(Icons.copy, size: 16),
  //                             onPressed: () => _handleCopy(context),
  //                             padding: EdgeInsets.zero,
  //                             constraints: const BoxConstraints(),
  //                             visualDensity: VisualDensity.compact,
  //                           ),
  //                         ],
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               // Secondary info (elapsed time or distance)
  //               if (!_isValueMissing && _hasSecondaryInfo) ...[
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   _getSecondaryInfo(),
  //                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //                         color: Colors.grey,
  //                         fontStyle: FontStyle.italic,
  //                       ),
  //                   textAlign: TextAlign.end,
  //                 ),
  //               ],

  //               if (errorText != null)
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 4),
  //                   child: Text(
  //                     errorText!,
  //                     style: TextStyle(
  //                       color: Theme.of(context).colorScheme.error,
  //                       fontSize: 12,
  //                     ),
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  bool get _hasSecondaryInfo {
    return (type == InfoType.date && showElapsedTime) ||
        (type == InfoType.address && showDistance);
  }

  String _getSecondaryInfo() {
    if (_isValueMissing) return '';

    switch (type) {
      case InfoType.date:
        if (showElapsedTime) {
          try {
            final dateTime = DateTime.parse(value!);
            final now = DateTime.now();
            return _formatElapsedTime(dateTime, now);
          } catch (e) {
            return '';
          }
        }
        return '';

      case InfoType.address:
        if (showDistance) {
          // Return distance info from AddressWidgetWithPreference
          return '2.5 km away'; // Replace with actual distance calculation
        }
        return '';

      default:
        return '';
    }
  }

  String _formatElapsedTime(DateTime dateTime, DateTime now) {
    final difference = now.difference(dateTime);

    final years = difference.inDays ~/ 365;
    final months = difference.inDays ~/ 30;
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    final List<String> parts = [];

    if (years > 0) {
      parts.add('${years} ${_pluralize('year', years)}');
    }
    if (months > 0 && years == 0) {
      parts.add('${months} ${_pluralize('month', months)}');
    }
    if (days > 0 && years == 0 && months == 0) {
      parts.add('${days} ${_pluralize('day', days)}');
    }
    if (hours > 0 && days == 0) {
      parts.add('${hours} ${_pluralize('hour', hours)}');
    }
    if (minutes > 0 && days == 0 && hours == 0) {
      parts.add('${minutes} ${_pluralize('minute', minutes)}');
    }
    if (parts.isEmpty) {
      return 'just now';
    }

    return '${parts.join(', ')} ago';
  }

  String _pluralize(String word, int count) {
    return count == 1 ? word : '${word}s';
  }

  TextStyle _getValueStyle(BuildContext context) {
    return TextStyle(
      color: _isValueMissing
          ? Colors.grey.withOpacity(0.7)
          : (onTap != null ? Theme.of(context).primaryColor : null),
      decoration:
          (!_isValueMissing && onTap != null) ? TextDecoration.underline : null,
      fontStyle: _isValueMissing ? FontStyle.italic : FontStyle.normal,
    );
  }

  Widget _buildAddressRow(
      {required BuildContext context, required String address}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side with icon and label
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: onTap != null
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isVerified) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.verified,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ],
            ),
          ),
          // Right side with AddressWidgetWithPreference
          Expanded(
            child: AddressWidgetWithPreference(
              address: value!,
              showIcon: false,
              textStyle: TextStyle(
                color: onTap != null ? Theme.of(context).primaryColor : null,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
