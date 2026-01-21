import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/follow_the_leader.dart';
import 'package:overlord/overlord.dart';
import 'package:super_editor/src/infrastructure/platforms/ios/colors.dart';

/// Steadfast Faith design system colors (hard-coded to match app theme)
class _SteadfastColors {
  // Light theme
  static const Color lightSurface = Color(0xFFFAFAFA); // neutral50
  static const Color lightTextSecondary = Color(0xFF525252); // neutral600
  static const Color lightBorderSubtle = Color(0xFFE5E5E5); // neutral200
  static const Color lightDestructive = Color(0xFFEF4444); // red500

  // Dark theme
  static const Color darkSurface = Color(0xFF0F172A); // slate900
  static const Color darkTextSecondary = Color(0xFF94A3B8); // slate400
  static const Color darkBorderSubtle = Color(0xFF1E293B); // slate800
  static const Color darkDestructive = Color(0xFFEF4444); // red500
}

class IOSTextEditingFloatingToolbar extends StatelessWidget {
  const IOSTextEditingFloatingToolbar({
    Key? key,
    this.floatingToolbarKey,
    required this.focalPoint,
    this.onCutPressed,
    this.onCopyPressed,
    this.onPastePressed,
    this.onDeletePressed,
    this.onSharePressed,
    this.onSelectPressed,
    this.onSelectAllPressed,
    this.isSelectionCollapsed = false,
  }) : super(key: key);

  final Key? floatingToolbarKey;

  /// Direction that the toolbar arrow should point.
  final LeaderLink focalPoint;

  final VoidCallback? onCutPressed;
  final VoidCallback? onCopyPressed;
  final VoidCallback? onPastePressed;
  
  // Steadfast Faith custom actions
  final VoidCallback? onDeletePressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onSelectPressed;
  final VoidCallback? onSelectAllPressed;
  
  /// Whether the selection is collapsed (cursor only) vs expanded (text selected)
  final bool isSelectionCollapsed;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // Build all buttons based on selection state
    final buttons = <Widget>[];
    
    if (!isSelectionCollapsed) {
      // Text selected: Cut, Copy, Paste, Share, Delete
      if (onCutPressed != null) {
        buttons.add(_buildButton(
          onPressed: onCutPressed!,
          title: 'Cut',
          isDestructive: false,
          isDark: isDark,
        ));
      }
      if (onCopyPressed != null) {
        buttons.add(_buildButton(
          onPressed: onCopyPressed!,
          title: 'Copy',
          isDestructive: false,
          isDark: isDark,
        ));
      }
      if (onPastePressed != null) {
        buttons.add(_buildButton(
          onPressed: onPastePressed!,
          title: 'Paste',
          isDestructive: false,
          isDark: isDark,
        ));
      }
      if (onSharePressed != null) {
        buttons.add(_buildButton(
          onPressed: onSharePressed!,
          title: 'Share',
          isDestructive: false,
          isDark: isDark,
        ));
      }
      if (onDeletePressed != null) {
        buttons.add(_buildButton(
          onPressed: onDeletePressed!,
          title: 'Delete',
          isDestructive: true,
          isDark: isDark,
        ));
      }
    } else {
      // Cursor only: Paste, Select, Select All
      if (onPastePressed != null) {
        buttons.add(_buildButton(
          onPressed: onPastePressed!,
          title: 'Paste',
          isDestructive: false,
          isDark: isDark,
        ));
      }
      if (onSelectPressed != null) {
        buttons.add(_buildButton(
          onPressed: onSelectPressed!,
          title: 'Select',
          isDestructive: false,
          isDark: isDark,
        ));
      }
      if (onSelectAllPressed != null) {
        buttons.add(_buildButton(
          onPressed: onSelectAllPressed!,
          title: 'Select All',
          isDestructive: false,
          isDark: isDark,
        ));
      }
    }

    // Build simple horizontal row with all buttons (no pagination/arrows)
    // Use CupertinoPopoverToolbar for positioning, but wrap buttons in a scrollable row
    return Theme(
      data: ThemeData(
        colorScheme: brightness == Brightness.light //
            ? const ColorScheme.light(primary: Colors.black)
            : const ColorScheme.dark(primary: Colors.white),
      ),
      child: CupertinoPopoverToolbar(
        key: floatingToolbarKey,
        focalPoint: LeaderMenuFocalPoint(link: focalPoint),
        elevation: 0.0, // Remove shadow
        backgroundColor: isDark ? _SteadfastColors.darkSurface : _SteadfastColors.lightSurface,
        activeButtonTextColor: isDark ? _SteadfastColors.darkTextSecondary : _SteadfastColors.lightTextSecondary,
        inactiveButtonTextColor: isDark ? _SteadfastColors.darkTextSecondary : _SteadfastColors.lightTextSecondary,
        children: [
          // Wrap in SingleChildScrollView to allow horizontal scrolling without pagination arrows
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: buttons,
            ),
          ),
        ],
      ),
    );
  }
  

  Widget _buildButton({
    required String title,
    required VoidCallback onPressed,
    required bool isDestructive,
    required bool isDark,
  }) {
    // Steadfast Faith ButtonTertiary styling
    final textColor = isDestructive
        ? _SteadfastColors.lightDestructive // red500 for destructive
        : (isDark ? _SteadfastColors.darkTextSecondary : _SteadfastColors.lightTextSecondary);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(kMinInteractiveDimension, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Space.x8, Space.x6
        backgroundColor: isDark ? _SteadfastColors.darkSurface : _SteadfastColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Radius.md
        ),
        splashFactory: NoSplash.splashFactory,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14, // Match ButtonTertiary text size
          fontWeight: FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }
}
