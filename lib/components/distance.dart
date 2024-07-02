import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class Distance extends StatelessWidget {
  final String currentLoc;
  final String destinationLoc;

  const Distance({
    super.key,
    required this.currentLoc,
    required this.destinationLoc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Ionicons.locate_outline,
          color: Colors.black54,
          size: 14,
        ),
        Text(
          _truncateLocation(currentLoc),
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 3),
        ...List.generate(
          18,
          (index) {
            return Expanded(
              child: Container(
                height: 2,
                color: index.isOdd ? Colors.transparent : Colors.black54,
              ),
            );
          },
        ),
        const SizedBox(width: 3),
        Icon(
          Ionicons.location_outline,
          size: 14,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 2),
        Text(
          _truncateLocation(destinationLoc),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        )
      ],
    );
  }

  String _truncateLocation(String location) {
    return location.length > 6 ? '${location.substring(0, 6)} ' : location;
  }
}
