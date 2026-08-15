import 'package:flutter/material.dart';

abstract final class HouselyPalette {
  static const canvas = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceRaised = Color(0xFFF7F7FA);
  static const surfacePressed = Color(0xFFEFF0F5);
  static const divider = Color(0xFFE8E9F0);
  static const textPrimary = Color(0xFF090A12);
  static const textSecondary = Color(0xFF656875);
  static const textTertiary = Color(0xFF9295A1);
  static const violet = Color(0xFF5B3CFF);
  static const violetPressed = Color(0xFF4525E6);
  static const violetSoft = Color(0xFFF1EFFF);
  static const mint = Color(0xFF0EAA70);
  static const mintSoft = Color(0xFFE8F9F2);
  static const coral = Color(0xFFF13F61);
  static const coralSoft = Color(0xFFFFEDF1);
  static const apricot = Color(0xFFFFF3D8);
  static const skySoft = Color(0xFFEAF3FF);
  static const sky = Color(0xFF1677FF);
  static const amber = Color(0xFFFF9D00);
  static const lilac = Color(0xFF7357F6);
  static const lilacSoft = Color(0xFFF0EDFF);
  static const onAccent = Color(0xFFFFFFFF);
  static const onAccentPressed = Color(0x14FFFFFF);
  static const onAccentOverlay = Color(0x12FFFFFF);
  static const shadow = Color(0x1A23233A);
  static const scrim = Color(0x4D000000);
}

abstract final class HouselyIconColors {
  static final _finance = <IconData>{
    Icons.receipt_long_outlined,
    Icons.receipt_long_rounded,
    Icons.payments_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.pie_chart_outline_rounded,
  };
  static final _documents = <IconData>{
    Icons.folder_outlined,
    Icons.folder_rounded,
    Icons.description_outlined,
    Icons.upload_file_outlined,
    Icons.photo_camera_outlined,
  };
  static final _people = <IconData>{
    Icons.person_outline_rounded,
    Icons.person_rounded,
    Icons.people_outline_rounded,
    Icons.group_outlined,
  };
  static final _home = <IconData>{
    Icons.home_outlined,
    Icons.home_rounded,
    Icons.chair_outlined,
    Icons.chair_rounded,
    Icons.inventory_2_outlined,
  };
  static final _violet = <IconData>{
    Icons.event_note_outlined,
    Icons.calendar_month_outlined,
    Icons.lock_outline_rounded,
    Icons.security_outlined,
    Icons.shield_outlined,
  };
  static final _positive = <IconData>{
    Icons.check_rounded,
    Icons.check_circle_outline_rounded,
    Icons.verified_outlined,
    Icons.download_done_rounded,
  };
  static final _urgent = <IconData>{
    Icons.priority_high_rounded,
    Icons.error_outline_rounded,
    Icons.bolt_rounded,
    Icons.notifications_outlined,
  };

  static ({Color foreground, Color background}) resolve(IconData icon) {
    if (_finance.contains(icon)) {
      return (
        foreground: HouselyPalette.coral,
        background: HouselyPalette.coralSoft,
      );
    }
    if (_documents.contains(icon)) {
      return (
        foreground: HouselyPalette.sky,
        background: HouselyPalette.skySoft,
      );
    }
    if (_people.contains(icon) || _positive.contains(icon)) {
      return (
        foreground: HouselyPalette.mint,
        background: HouselyPalette.mintSoft,
      );
    }
    if (_home.contains(icon)) {
      return (
        foreground: HouselyPalette.amber,
        background: HouselyPalette.apricot,
      );
    }
    if (_violet.contains(icon)) {
      return (
        foreground: HouselyPalette.lilac,
        background: HouselyPalette.lilacSoft,
      );
    }
    if (_urgent.contains(icon)) {
      return (
        foreground: HouselyPalette.coral,
        background: HouselyPalette.coralSoft,
      );
    }
    return (foreground: HouselyPalette.sky, background: HouselyPalette.skySoft);
  }
}

abstract final class HouselySpace {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 18.0;
  static const xl = 22.0;
  static const xxl = 28.0;
  static const section = 32.0;
}

abstract final class HouselyRadius {
  static const control = 14.0;
  static const group = 20.0;
  static const feature = 24.0;
  static const pill = 999.0;
}

abstract final class HouselySize {
  static const minTouch = 48.0;
  static const iconSmall = 18.0;
  static const icon = 22.0;
  static const iconLarge = 28.0;
  static const phoneGutter = 20.0;
  static const tabletGutter = 24.0;
  static const maxContentWidth = 600.0;
}

abstract final class HouselyMotion {
  static const quick = Duration(milliseconds: 150);
  static const standard = Duration(milliseconds: 200);
  static const deliberate = Duration(milliseconds: 240);
  static const curve = Curves.easeOutCubic;
}
