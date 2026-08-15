import 'package:flutter/material.dart';

import '../theme/housely_tokens.dart';

enum HouselyScope { personal, household, privateGroup }

class HouselyScopeBadge extends StatelessWidget {
  const HouselyScopeBadge({required this.scope, super.key});
  final HouselyScope scope;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (scope) {
      HouselyScope.personal => ('Personal', Icons.person_outline_rounded),
      HouselyScope.household => ('Household', Icons.home_outlined),
      HouselyScope.privateGroup => (
        'Private group',
        Icons.lock_outline_rounded,
      ),
    };
    return Semantics(
      label: 'Visibility: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: HouselyPalette.surfacePressed,
          borderRadius: BorderRadius.circular(HouselyRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: HouselyPalette.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class HouselyAvatar extends StatelessWidget {
  const HouselyAvatar({
    required this.name,
    this.image,
    this.size = 40,
    this.statusColor,
    super.key,
  });

  final String name;
  final ImageProvider? image;
  final double size;
  final Color? statusColor;

  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((part) => part.isEmpty ? '' : part[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final avatarColors = [
      HouselyPalette.sky,
      HouselyPalette.coral,
      HouselyPalette.mint,
      HouselyPalette.violet,
    ];
    final colorIndex = name.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    final avatarColor = avatarColors[colorIndex % avatarColors.length];
    return Semantics(
      label: name,
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: size / 2,
              backgroundColor: avatarColor,
              foregroundImage: image,
              child: image == null
                  ? Text(
                      initials,
                      style: TextStyle(
                        color: HouselyPalette.onAccent,
                        fontSize: size * .33,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : null,
            ),
            if (statusColor != null)
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: size * .28,
                  height: size * .28,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: HouselyPalette.canvas, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HouselyAvatarGroup extends StatelessWidget {
  const HouselyAvatarGroup({
    required this.names,
    this.maxVisible = 3,
    super.key,
  });
  final List<String> names;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final visible = names.take(maxVisible).toList();
    final remaining = names.length - visible.length;
    const size = 36.0;
    const overlap = 10.0;
    final total = visible.length + (remaining > 0 ? 1 : 0);
    return Semantics(
      label: names.join(', '),
      child: SizedBox(
        width: total == 0 ? 0 : size + (total - 1) * (size - overlap),
        height: size,
        child: Stack(
          children: [
            for (var i = 0; i < visible.length; i++)
              Positioned(
                left: i * (size - overlap),
                child: HouselyAvatar(name: visible[i], size: size),
              ),
            if (remaining > 0)
              Positioned(
                left: visible.length * (size - overlap),
                child: CircleAvatar(
                  radius: size / 2,
                  backgroundColor: HouselyPalette.violetSoft,
                  child: Text(
                    '+$remaining',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
