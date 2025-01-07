import 'package:auth_riverpod/src/services/distance_unit_preference.dart';
import 'package:auth_riverpod/src/services/location_service.dart';
import 'package:auth_riverpod/src/util/url_launcher_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressWidget extends ConsumerWidget {
  const AddressWidget({
    super.key,
    required this.address,
    this.showDistance = true,
    this.showIcon = true,
    this.iconColor,
    this.textStyle,
    this.onTap,
    this.showBothUnits = true, // Add this parameter
  });

  final String address;
  final bool showDistance;
  final bool showIcon;
  final Color? iconColor;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final bool showBothUnits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distance = showDistance
        ? ref.watch(distanceToAddressProvider(address))
        : const AsyncValue<double?>.data(null);

    return InkWell(
      onTap: onTap ?? () => context.launchMap(address),
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(
              Icons.location_on,
              size: 20,
              color: iconColor ?? Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address,
                  style: textStyle?.copyWith(
                        decoration: TextDecoration.underline,
                      ) ??
                      const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                ),
                if (showDistance) ...[
                  const SizedBox(height: 4),
                  distance.when(
                    data: (meters) {
                      if (meters == null) return const SizedBox();
                      return _buildDistanceText(context, meters);
                    },
                    loading: () => SizedBox(
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceText(BuildContext context, double meters) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        );

    if (showBothUnits) {
      return Row(
        children: [
          Text(
            _formatDistanceMetric(meters),
            style: textStyle,
          ),
          Text(
            ' • ',
            style: textStyle,
          ),
          Text(
            _formatDistanceImperial(meters),
            style: textStyle,
          ),
        ],
      );
    } else {
      return Text(
        _formatDistanceMetric(meters),
        style: textStyle,
      );
    }
  }

  String _formatDistanceMetric(double meters) {
    if (meters < 1000) {
      return '${meters.round()}m';
    } else {
      final km = meters / 1000;
      if (km < 10) {
        return '${km.toStringAsFixed(1)}km';
      } else {
        return '${km.round()}km';
      }
    }
  }

  String _formatDistanceImperial(double meters) {
    final feet = meters * 3.28084;
    if (feet < 1000) {
      return '${feet.round()}ft';
    } else {
      final miles = meters / 1609.344;
      if (miles < 10) {
        return '${miles.toStringAsFixed(1)}mi';
      } else {
        return '${miles.round()}mi';
      }
    }
  }
}

// Optional: Add a provider for distance unit preference
enum DistanceUnit {
  metric,
  imperial,
  both;

  String formatDistance(double meters) {
    return switch (this) {
      metric => _formatMetric(meters),
      imperial => _formatImperial(meters),
      both => '${_formatMetric(meters)} • ${_formatImperial(meters)}',
    };
  }

  String _formatMetric(double meters) {
    if (meters < 1000) {
      return '${meters.round()}m';
    } else {
      final km = meters / 1000;
      if (km < 10) {
        return '${km.toStringAsFixed(1)}km';
      } else {
        return '${km.round()}km';
      }
    }
  }

  String _formatImperial(double meters) {
    final feet = meters * 3.28084;
    if (feet < 1000) {
      return '${feet.round()}ft';
    } else {
      final miles = meters / 1609.344;
      if (miles < 10) {
        return '${miles.toStringAsFixed(1)}mi';
      } else {
        return '${miles.round()}mi';
      }
    }
  }
}

// Updated AddressWidget using the preference provider
class AddressWidgetWithPreference extends ConsumerWidget {
  const AddressWidgetWithPreference({
    super.key,
    required this.address,
    this.showDistance = true,
    this.showIcon = true,
    this.iconColor,
    this.textStyle,
    this.onTap,
    this.textAlign = TextAlign.end,
    this.maxLines = 1,
  });

  final String address;
  final bool showDistance;
  final bool showIcon;
  final Color? iconColor;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final TextAlign textAlign;
  final int maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distance = showDistance
        ? ref.watch(distanceToAddressProvider(address))
        : const AsyncValue<double?>.data(null);

    return InkWell(
      onTap: onTap ?? () => context.launchMap(address),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.location_on,
              size: 20,
              color: iconColor ?? Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  address,
                  style: textStyle?.copyWith(
                        decoration: TextDecoration.underline,
                      ) ??
                      const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                  textAlign: textAlign,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showDistance) ...[
                  const SizedBox(height: 4),
                  distance.when(
                    data: (meters) {
                      if (meters == null) return const SizedBox();
                      return Text(
                        _formatDistance(ref, meters),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: textAlign,
                      );
                    },
                    loading: () => SizedBox(
                      height: 2,
                      width: 50,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(WidgetRef ref, double meters) {
    final distanceUnit = ref.watch(distanceUnitPreferenceProvider);
    return distanceUnit.formatDistance(meters);
  }
}

// Example settings widget to change distance unit preference
class DistanceUnitSelector extends ConsumerWidget {
  const DistanceUnitSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUnit = ref.watch(distanceUnitPreferenceProvider);

    return SegmentedButton<DistanceUnit>(
      segments: const [
        ButtonSegment(
          value: DistanceUnit.metric,
          label: Text('Metric'),
        ),
        ButtonSegment(
          value: DistanceUnit.imperial,
          label: Text('Imperial'),
        ),
        ButtonSegment(
          value: DistanceUnit.both,
          label: Text('Both'),
        ),
      ],
      selected: {currentUnit},
      onSelectionChanged: (Set<DistanceUnit> selection) {
        ref
            .read(distanceUnitPreferenceProvider.notifier)
            .setUnit(selection.first);
      },
    );
  }
}

// For optimized list rendering, use a keyed version
class KeyedAddressWidget extends ConsumerWidget {
  const KeyedAddressWidget({
    super.key,
    required this.address,
    this.showDistance = true,
    this.showIcon = true,
    this.showBothUnits = true,
    this.iconColor,
    this.textStyle,
    this.onTap,
  });

  final String address;
  final bool showDistance;
  final bool showIcon;
  final bool showBothUnits;
  final Color? iconColor;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distanceUnit = ref.watch(distanceUnitPreferenceProvider);
    // Pre-fetch the distance calculation
    if (showDistance) {
      ref.watch(distanceToAddressProvider(address));
    }

    return AddressWidget(
      address: address,
      showDistance: showDistance,
      showIcon: showIcon,
      iconColor: iconColor,
      textStyle: textStyle,
      onTap: onTap,
      showBothUnits: distanceUnit == DistanceUnit.both,
    );
  }
}

// With preference support
class KeyedAddressWidgetWithPreference extends ConsumerWidget {
  const KeyedAddressWidgetWithPreference({
    super.key,
    required this.address,
    this.showDistance = true,
    this.showIcon = true,
    this.iconColor,
    this.textStyle,
    this.onTap,
  });

  final String address;
  final bool showDistance;
  final bool showIcon;
  final Color? iconColor;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distanceUnit = ref.watch(distanceUnitPreferenceProvider);

    return KeyedAddressWidget(
      key: ValueKey(address),
      address: address,
      showDistance: showDistance,
      showIcon: showIcon,
      iconColor: iconColor,
      textStyle: textStyle,
      onTap: onTap,
      showBothUnits: distanceUnit == DistanceUnit.both,
    );
  }
}

// Example usage in lists
class AddressList extends ConsumerWidget {
  const AddressList({
    super.key,
    required this.addresses,
  });

  final List<String> addresses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        final address = addresses[index];
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: KeyedAddressWidgetWithPreference(
            key: ValueKey(address),
            address: address,
          ),
        );
      },
    );
  }
}

// // Example usage in a business directory
// class BusinessDirectoryItem extends StatelessWidget {
//   const BusinessDirectoryItem({
//     super.key,
//     required this.business,
//   });

//   final Business business;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         title: Text(business.name),
//         subtitle: KeyedAddressWidgetWithPreference(
//           key: ValueKey('${business.id}_address'),
//           address: business.address,
//           showIcon: false,
//           textStyle: Theme.of(context).textTheme.bodySmall,
//         ),
//         trailing: IconButton(
//           icon: const Icon(Icons.directions),
//           onPressed: () => context.launchMap(business.address),
//         ),
//       ),
//     );
//   }
// }

// // Example usage in an event list
// class EventListItem extends StatelessWidget {
//   const EventListItem({
//     super.key,
//     required this.event,
//   });

//   final Event event;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListTile(
//             title: Text(event.title),
//             subtitle: Text(event.date.toString()),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: KeyedAddressWidgetWithPreference(
//               key: ValueKey('${event.id}_address'),
//               address: event.venue,
//               showIcon: true,
//               showDistance: true,
//             ),
//           ),
//           ButtonBar(
//             children: [
//               TextButton.icon(
//                 icon: const Icon(Icons.directions),
//                 label: const Text('Directions'),
//                 onPressed: () => context.launchMap(event.venue),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Example of a search result list
// class LocationSearchResults extends ConsumerWidget {
//   const LocationSearchResults({
//     super.key,
//     required this.searchResults,
//   });

//   final List<SearchResult> searchResults;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ListView.builder(
//       itemCount: searchResults.length,
//       itemBuilder: (context, index) {
//         final result = searchResults[index];
//         return ListTile(
//           leading: Icon(
//             result.type.icon,
//             color: Theme.of(context).primaryColor,
//           ),
//           title: Text(result.name),
//           subtitle: KeyedAddressWidgetWithPreference(
//             key: ValueKey(result.id),
//             address: result.address,
//             showIcon: false,
//             showDistance: true,
//           ),
//           trailing: IconButton(
//             icon: const Icon(Icons.arrow_forward_ios),
//             onPressed: () {
//               // Navigate to detail page
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// // Optional: Add a distance comparator for sorting
// class DistanceComparator {
//   static int compare(String address1, String address2, WidgetRef ref) {
//     final distance1 = ref.read(distanceToAddressProvider(address1)).valueOrNull ?? double.infinity;
//     final distance2 = ref.read(distanceToAddressProvider(address2)).valueOrNull ?? double.infinity;
//     return distance1.compareTo(distance2);
//   }
// }

// // Example of sorted list by distance
// class SortedAddressList extends ConsumerWidget {
//   const SortedAddressList({
//     super.key,
//     required this.addresses,
//   });

//   final List<String> addresses;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Create a sorted copy of the addresses
//     final sortedAddresses = [...addresses]
//       ..sort((a, b) => DistanceComparator.compare(a, b, ref));

//     return ListView.builder(
//       itemCount: sortedAddresses.length,
//       itemBuilder: (context, index) {
//         final address = sortedAddresses[index];
//         return Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 8,
//           ),
//           child: KeyedAddressWidgetWithPreference(
//             key: ValueKey(address),
//             address: address,
//           ),
//         );
//       },
//     );
//   }
// }
