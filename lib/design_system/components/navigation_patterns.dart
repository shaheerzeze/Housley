import 'package:flutter/material.dart';

import '../theme/housely_tokens.dart';
import 'buttons.dart';
import 'housely_components.dart';
import 'identity.dart';

class HouselyTopBar extends StatelessWidget implements PreferredSizeWidget {
  const HouselyTopBar({
    required this.title,
    this.onBack,
    this.actions = const [],
    super.key,
  });
  final String title;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(58);

  @override
  Widget build(BuildContext context) => AppBar(
    leading: onBack == null
        ? null
        : HouselyIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            label: 'Back',
            onPressed: onBack,
          ),
    title: Text(title),
    actions: actions,
  );
}

class HouselyHomeIdentity extends StatelessWidget {
  const HouselyHomeIdentity({
    required this.name,
    required this.address,
    this.members = const [],
    super.key,
  });
  final String name;
  final String address;
  final List<String> members;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    label: '$name, $address',
    child: Row(
      children: [
        const HomePulse(size: 46),
        const SizedBox(width: HouselySpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(address, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (members.isNotEmpty) HouselyAvatarGroup(names: members),
      ],
    ),
  );
}

enum HouselyDestination { home, split, vault, stuff, you }

class HouselyBottomDock extends StatelessWidget {
  const HouselyBottomDock({
    required this.selected,
    required this.onSelected,
    super.key,
  });
  final HouselyDestination selected;
  final ValueChanged<HouselyDestination> onSelected;

  static const _items = {
    HouselyDestination.home: (Icons.home_outlined, Icons.home_rounded, 'Home'),
    HouselyDestination.split: (
      Icons.receipt_long_outlined,
      Icons.receipt_long_rounded,
      'Split',
    ),
    HouselyDestination.vault: (
      Icons.folder_outlined,
      Icons.folder_rounded,
      'Vault',
    ),
    HouselyDestination.stuff: (
      Icons.chair_outlined,
      Icons.chair_rounded,
      'Stuff',
    ),
    HouselyDestination.you: (
      Icons.person_outline_rounded,
      Icons.person_rounded,
      'You',
    ),
  };

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: HouselyPalette.canvas,
    child: SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: HouselyPalette.violet.withValues(alpha: .14),
                blurRadius: 34,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: HouselyPalette.textPrimary.withValues(alpha: .12),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: HouselyPalette.surface,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(32),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 5, 8, 2),
              child: NavigationBar(
                height: 70,
                backgroundColor: Colors.transparent,
                indicatorColor: HouselyPalette.surface,
                selectedIndex: HouselyDestination.values.indexOf(selected),
                onDestinationSelected: (index) =>
                    onSelected(HouselyDestination.values[index]),
                destinations: _items.entries.map((entry) {
                  final (icon, selectedIcon, label) = entry.value;
                  return NavigationDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selectedIcon),
                    label: label,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
