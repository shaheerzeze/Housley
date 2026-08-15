import 'package:flutter/material.dart';

import '../theme/housely_tokens.dart';
import 'housely_components.dart';
import 'identity.dart';

class HouselyGroupedList extends StatelessWidget {
  const HouselyGroupedList({required this.children, super.key});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => HouselySurface(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        const SizedBox(height: 5),
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index < children.length - 1)
            const Divider(indent: 78, endIndent: 18),
        ],
        const SizedBox(height: 5),
      ],
    ),
  );
}

class HouselyRecordRow extends StatelessWidget {
  const HouselyRecordRow({
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.onTap,
    this.semanticLabel,
    super.key,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tone = HouselyIconColors.resolve(icon);
    final background = iconColor ?? tone.foreground;
    const foreground = HouselyPalette.onAccent;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: ListTile(
        minTileHeight: 72,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HouselySpace.md,
          vertical: 6,
        ),
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 22, color: foreground),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: subtitle == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
        trailing:
            trailing ??
            (onTap == null
                ? null
                : const Icon(
                    Icons.chevron_right_rounded,
                    color: HouselyPalette.textSecondary,
                    size: 22,
                  )),
      ),
    );
  }
}

class HouselyAttentionRow extends StatelessWidget {
  const HouselyAttentionRow({
    required this.title,
    required this.detail,
    required this.actionLabel,
    required this.onTap,
    this.amount,
    super.key,
  });
  final String title;
  final String detail;
  final String actionLabel;
  final String? amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HouselyRecordRow(
    title: title,
    subtitle: detail,
    icon: Icons.priority_high_rounded,
    iconColor: HouselyPalette.coral,
    semanticLabel: '$title. $detail. $actionLabel',
    onTap: onTap,
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (amount != null)
          Text(amount!, style: Theme.of(context).textTheme.titleMedium),
        Text(
          actionLabel,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: HouselyPalette.coral),
        ),
      ],
    ),
  );
}

class HouselyMemberRow extends StatelessWidget {
  const HouselyMemberRow({
    required this.name,
    required this.role,
    this.status,
    this.onTap,
    super.key,
  });
  final String name;
  final String role;
  final String? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 74,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: HouselySpace.md,
      vertical: 7,
    ),
    leading: HouselyAvatar(name: name),
    title: Text(name, style: Theme.of(context).textTheme.titleMedium),
    subtitle: Text(role),
    trailing: status == null ? null : HouselyStatusPill(label: status!),
    onTap: onTap,
  );
}

class HouselyMoneyRow extends StatelessWidget {
  const HouselyMoneyRow({
    required this.title,
    required this.detail,
    required this.amount,
    this.paid = false,
    this.onTap,
    super.key,
  });
  final String title;
  final String detail;
  final String amount;
  final bool paid;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => HouselyRecordRow(
    title: title,
    subtitle: detail,
    icon: Icons.receipt_long_outlined,
    iconColor: paid ? HouselyPalette.mint : HouselyPalette.coral,
    onTap: onTap,
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(amount, style: Theme.of(context).textTheme.titleMedium),
        Text(
          paid ? 'Paid' : 'Due',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: paid ? HouselyPalette.mint : HouselyPalette.coral,
          ),
        ),
      ],
    ),
  );
}

class HouselyFileRow extends StatelessWidget {
  const HouselyFileRow({
    required this.title,
    required this.metadata,
    this.onTap,
    super.key,
  });
  final String title;
  final String metadata;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => HouselyRecordRow(
    title: title,
    subtitle: metadata,
    icon: Icons.description_outlined,
    onTap: onTap,
  );
}

class HouselyOwnershipRow extends StatelessWidget {
  const HouselyOwnershipRow({
    required this.owner,
    required this.share,
    this.valid = true,
    super.key,
  });
  final String owner;
  final String share;
  final bool valid;

  @override
  Widget build(BuildContext context) => HouselyRecordRow(
    title: owner,
    subtitle: 'Ownership share',
    icon: Icons.person_outline_rounded,
    iconColor: valid ? HouselyPalette.violet : HouselyPalette.coral,
    trailing: Text(
      share,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: valid ? null : HouselyPalette.coral,
      ),
    ),
  );
}
