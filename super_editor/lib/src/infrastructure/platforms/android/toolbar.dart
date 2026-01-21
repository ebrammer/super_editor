import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:super_editor/src/infrastructure/flutter/android_toolbar.dart';

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

class AndroidTextEditingFloatingToolbar extends StatefulWidget {
  const AndroidTextEditingFloatingToolbar({
    Key? key,
    this.focalPoint,
    this.floatingToolbarKey,
    this.onCutPressed,
    this.onCopyPressed,
    this.onPastePressed,
    this.onSelectAllPressed,
    this.onDeletePressed,
    this.onSharePressed,
    this.onSelectPressed,
    this.isSelectionCollapsed = false,
  }) : super(key: key);

  final Key? floatingToolbarKey;
  final LeaderLink? focalPoint;

  final VoidCallback? onCutPressed;
  final VoidCallback? onCopyPressed;
  final VoidCallback? onPastePressed;
  final VoidCallback? onSelectAllPressed;
  
  // Steadfast Faith custom actions
  final VoidCallback? onDeletePressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onSelectPressed;
  
  /// Whether the selection is collapsed (cursor only) vs expanded (text selected)
  final bool isSelectionCollapsed;

  @override
  State<AndroidTextEditingFloatingToolbar> createState() => _AndroidTextEditingFloatingToolbarState();
}

class _AndroidTextEditingFloatingToolbarState extends State<AndroidTextEditingFloatingToolbar> {
  /// Whether the toolbar is above or below the focal point.
  ///
  /// This is used to determine the position of the back button in the overflow menu.
  bool _isAbove = true;

  @override
  void initState() {
    super.initState();
    widget.focalPoint?.addListener(_onFocalPointChange);
  }

  @override
  void didUpdateWidget(AndroidTextEditingFloatingToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focalPoint != widget.focalPoint) {
      oldWidget.focalPoint?.removeListener(_onFocalPointChange);
      widget.focalPoint?.addListener(_onFocalPointChange);
    }
  }

  @override
  void dispose() {
    widget.focalPoint?.removeListener(_onFocalPointChange);
    super.dispose();
  }

  void _onFocalPointChange() {
    final leader = widget.focalPoint?.leader;
    if (leader == null) {
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) {
      return;
    }

    final leaderOffset = leader.offset;
    final followerOffset = box.localToGlobal(Offset.zero);
    final isAbove = followerOffset < leaderOffset;

    if (isAbove != _isAbove) {
      setState(() {
        _isAbove = isAbove;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    
    // Build all buttons based on selection state
    final buttons = <_ButtonViewModel>[];
    
    if (!widget.isSelectionCollapsed) {
      // Text selected: Cut, Copy, Paste, Share, Delete
      if (widget.onCutPressed != null) {
        buttons.add(_ButtonViewModel(
          onPressed: widget.onCutPressed!,
          title: 'Cut',
          isDestructive: false,
        ));
      }
      if (widget.onCopyPressed != null) {
        buttons.add(_ButtonViewModel(
          onPressed: widget.onCopyPressed!,
          title: 'Copy',
          isDestructive: false,
        ));
      }
      if (widget.onPastePressed != null) {
        buttons.add(_ButtonViewModel(
          onPressed: widget.onPastePressed!,
          title: 'Paste',
          isDestructive: false,
        ));
      }
      if (widget.onSharePressed != null) {
        buttons.add(_ButtonViewModel(
          onPressed: widget.onSharePressed!,
          title: 'Share',
          isDestructive: false,
        ));
      }
      if (widget.onDeletePressed != null) {
        buttons.add(_ButtonViewModel(
          onPressed: widget.onDeletePressed!,
          title: 'Delete',
          isDestructive: true,
        ));
      }
    } else {
      // Cursor only: Paste, Select, Select All
      if (widget.onPastePressed != null) {
        buttons.add(_ButtonViewModel(
          onPressed: widget.onPastePressed!,
          title: 'Paste',
          isDestructive: false,
        ));
      }
      if (widget.onSelectPressed != null) {
        buttons.add(_ButtonViewModel(
          onPressed: widget.onSelectPressed!,
          title: 'Select',
          isDestructive: false,
        ));
      }
      if (widget.onSelectAllPressed != null) {
        buttons.add(_ButtonViewModel(
          onPressed: widget.onSelectAllPressed!,
          title: 'Select All',
          isDestructive: false,
        ));
      }
    }

    return Theme(
      data: ThemeData(
        colorScheme: brightness == Brightness.light //
            ? const ColorScheme.light(primary: Colors.black)
            : const ColorScheme.dark(primary: Colors.white),
      ),
      child: KeyedSubtree(
        key: widget.floatingToolbarKey,
        child: AndroidPopoverToolbar(
          isAbove: _isAbove,
          toolbarBuilder: (context, child) => _buildSteadfastToolbar(context, child, isDark),
          children: _buildButtonRow(buttons, isDark),
        ),
      ),
    );
  }
  
  /// Build toolbar container with Steadfast Faith styling
  Widget _buildSteadfastToolbar(BuildContext context, Widget child, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? _SteadfastColors.darkSurface : _SteadfastColors.lightSurface,
        borderRadius: BorderRadius.circular(999.0), // Fully rounded (pill)
        border: Border.all(
          color: isDark ? _SteadfastColors.darkBorderSubtle : _SteadfastColors.lightBorderSubtle,
          width: 1,
        ),
        // No shadow
      ),
      child: child,
    );
  }
  
  /// Build button row (no dividers)
  List<Widget> _buildButtonRow(List<_ButtonViewModel> buttons, bool isDark) {
    if (buttons.isEmpty) return [];
    
    return buttons.map((button) {
      final textColor = button.isDestructive
          ? _SteadfastColors.lightDestructive // red500 for destructive
          : (isDark ? _SteadfastColors.darkTextSecondary : _SteadfastColors.lightTextSecondary);
      
      return TextButton(
        onPressed: button.onPressed,
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
          button.title,
          style: TextStyle(
            fontSize: 14, // Match ButtonTertiary text size
            fontWeight: FontWeight.normal,
            color: textColor,
          ),
        ),
      );
    }).toList();
  }
}

Widget _defaultToolbarBuilder(BuildContext context, Widget child) {
  return AndroidPopoverToolbarContainer(child: child);
}

class _ButtonViewModel {
  _ButtonViewModel({
    required this.title,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String title;
  final VoidCallback onPressed;
  final bool isDestructive;
}
