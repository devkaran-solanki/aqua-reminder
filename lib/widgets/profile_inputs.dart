import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';

/// Section Header with micro uppercase label style
class ProfileSectionHeader extends StatelessWidget {
  final String title;
  const ProfileSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}

/// Instagram-style inline profile input field with subtle top micro-label
class InstagramProfileInput extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? unitSuffix;
  final double? inputWidth;
  final Widget? trailing;
  final ValueChanged<String>? onSubmitted;
  final bool isInteractive;

  const InstagramProfileInput({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.unitSuffix,
    this.inputWidth,
    this.trailing,
    this.onSubmitted,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isFocused = focusNode.hasFocus;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!focusNode.hasFocus) {
          focusNode.requestFocus();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFocused
                ? AppColors.cyanBright.withValues(alpha: 0.35)
                : AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cardElevated,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: 1.0,
                ),
              ),
              child: Icon(
                icon,
                color: isFocused ? AppColors.cyanBright : AppColors.textSecondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: isFocused ? AppColors.cyanBright : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (unitSuffix != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: inputWidth ?? 38,
                          child: isInteractive
                              ? TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  keyboardType: keyboardType,
                                  textCapitalization: textCapitalization,
                                  inputFormatters: inputFormatters,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  cursorColor: AppColors.cyanBright,
                                  decoration: InputDecoration(
                                    hintText: hintText,
                                    hintStyle: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                  onSubmitted: onSubmitted,
                                )
                              : Text(
                                  controller.text.isNotEmpty
                                      ? controller.text
                                      : hintText,
                                  style: TextStyle(
                                    color: controller.text.isNotEmpty
                                        ? AppColors.textPrimary
                                        : AppColors.textMuted,
                                    fontSize: 15,
                                    fontWeight: controller.text.isNotEmpty
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unitSuffix!,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  else
                    isInteractive
                        ? TextField(
                            controller: controller,
                            focusNode: focusNode,
                            keyboardType: keyboardType,
                            textCapitalization: textCapitalization,
                            inputFormatters: inputFormatters,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            cursorColor: AppColors.cyanBright,
                            decoration: InputDecoration(
                              hintText: hintText,
                              hintStyle: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            onSubmitted: onSubmitted,
                          )
                        : Text(
                            controller.text.isNotEmpty
                                ? controller.text
                                : hintText,
                            style: TextStyle(
                              color: controller.text.isNotEmpty
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                              fontSize: 15,
                              fontWeight: controller.text.isNotEmpty
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Instagram-style inline input specifically for feet & inches (e.g. 5 ft 10 in)
class InstagramHeightFtInput extends StatelessWidget {
  final TextEditingController feetController;
  final TextEditingController inchesController;
  final FocusNode feetFocus;
  final FocusNode inchesFocus;
  final VoidCallback onSave;
  final bool isInteractive;

  const InstagramHeightFtInput({
    super.key,
    required this.feetController,
    required this.inchesController,
    required this.feetFocus,
    required this.inchesFocus,
    required this.onSave,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isFocused = feetFocus.hasFocus || inchesFocus.hasFocus;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!feetFocus.hasFocus && !inchesFocus.hasFocus) {
          feetFocus.requestFocus();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFocused
                ? AppColors.cyanBright.withValues(alpha: 0.35)
                : AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cardElevated,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: 1.0,
                ),
              ),
              child: Icon(
                Icons.height_rounded,
                color: isFocused ? AppColors.cyanBright : AppColors.textSecondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'HEIGHT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: isFocused ? AppColors.cyanBright : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (!feetFocus.hasFocus) {
                            feetFocus.requestFocus();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 28,
                              child: isInteractive
                                  ? TextField(
                                      controller: feetController,
                                      focusNode: feetFocus,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      cursorColor: AppColors.cyanBright,
                                      decoration: const InputDecoration(
                                        hintText: '5',
                                        hintStyle: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      onSubmitted: (_) => onSave(),
                                    )
                                  : Text(
                                      feetController.text.isNotEmpty
                                          ? feetController.text
                                          : '5',
                                      style: TextStyle(
                                        color: feetController.text.isNotEmpty
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted,
                                        fontSize: 15,
                                        fontWeight:
                                            feetController.text.isNotEmpty
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                      ),
                                    ),
                            ),
                            const Text(
                              'ft',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (!inchesFocus.hasFocus) {
                            inchesFocus.requestFocus();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 28,
                              child: isInteractive
                                  ? TextField(
                                      controller: inchesController,
                                      focusNode: inchesFocus,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      cursorColor: AppColors.cyanBright,
                                      decoration: const InputDecoration(
                                        hintText: '0',
                                        hintStyle: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      onSubmitted: (_) => onSave(),
                                    )
                                  : Text(
                                      inchesController.text.isNotEmpty
                                          ? inchesController.text
                                          : '0',
                                      style: TextStyle(
                                        color: inchesController.text.isNotEmpty
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted,
                                        fontSize: 15,
                                        fontWeight:
                                            inchesController.text.isNotEmpty
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                      ),
                                    ),
                            ),
                            const Text(
                              'in',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dropdown option item model
class InstagramDropdownItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const InstagramDropdownItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });
}

/// Generic premium cyber obsidian dropdown with smooth expandable accordion animation
class InstagramDropdown<T> extends StatefulWidget {
  final String label;
  final T selectedValue;
  final IconData? icon;
  final IconData Function(T value)? dynamicIcon;
  final List<InstagramDropdownItem<T>> items;
  final bool isOpen;
  final bool showOptionIcons;
  final VoidCallback onToggle;
  final ValueChanged<T> onSelected;

  const InstagramDropdown({
    super.key,
    required this.label,
    required this.selectedValue,
    this.icon,
    this.dynamicIcon,
    required this.items,
    required this.isOpen,
    this.showOptionIcons = true,
    required this.onToggle,
    required this.onSelected,
  });

  @override
  State<InstagramDropdown<T>> createState() => _InstagramDropdownState<T>();
}

class _InstagramDropdownState<T> extends State<InstagramDropdown<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _chevronAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 170),
      vsync: this,
      value: widget.isOpen ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.08, 1.0, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 0.88, curve: Curves.easeIn),
    );
    _chevronAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(_expandAnimation);
  }

  @override
  void didUpdateWidget(InstagramDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  InstagramDropdownItem<T> _getSelectedItem() {
    return widget.items.firstWhere(
      (item) => item.value == widget.selectedValue,
      orElse: () => widget.items.first,
    );
  }

  IconData _getHeaderIcon() {
    if (widget.icon != null) {
      return widget.icon!;
    }
    if (widget.dynamicIcon != null) {
      return widget.dynamicIcon!(widget.selectedValue);
    }
    return _getSelectedItem().icon ?? Icons.straighten_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final aqua = AppColors.cyanPrimary;
    final selectedItem = _getSelectedItem();
    final headerIcon = _getHeaderIcon();

    // Pre-build options body once so it is NEVER rebuilt on animation frame ticks
    final optionsBody = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: AppColors.borderSubtle,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.items.map((item) {
              final isSelected = item.value == widget.selectedValue;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: _buildOption(
                  item: item,
                  isSelected: isSelected,
                  aqua: aqua,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: optionsBody,
        builder: (context, child) {
          final progress = _expandAnimation.value;
          final borderColor = Color.lerp(
            AppColors.borderSubtle,
            aqua.withValues(alpha: 0.35),
            progress,
          )!;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Trigger Tile
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onToggle();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        // Icon box
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.cardElevated,
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: AppColors.borderSubtle,
                              width: 1.0,
                            ),
                          ),
                          child: Icon(
                            headerIcon,
                            color: aqua,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Label & Value
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.label.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: Color.lerp(AppColors.textMuted, aqua, progress),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedItem.label,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Rotating chevron
                        RotationTransition(
                          turns: _chevronAnimation,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color.lerp(AppColors.textMuted, aqua, progress),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Expanding Dropdown Body (smooth hardware accelerated)
                ClipRect(
                  clipBehavior: Clip.hardEdge,
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: progress,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOption({
    required InstagramDropdownItem<T> item,
    required bool isSelected,
    required Color aqua,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onSelected(item.value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? aqua.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? aqua.withValues(alpha: 0.28)
                : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            if (widget.showOptionIcons && item.icon != null) ...[
              Icon(
                item.icon,
                color: isSelected ? aqua : AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 1.5),
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.textMuted
                            : AppColors.textMuted.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? aqua.withValues(alpha: 0.16)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? aqua.withValues(alpha: 0.65)
                      : AppColors.borderSubtle,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: aqua,
                        size: 13,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Instagram-style selectable field (stacked label & value with trailing chevron)
class InstagramSelectableField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const InstagramSelectableField({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cardElevated,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: 1.0,
                ),
              ),
              child: Icon(icon, color: AppColors.cyanBright, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Cyber Obsidian "Recalculate Recommended Goal" action button
class RecalculateGoalButton extends StatelessWidget {
  final VoidCallback onTap;

  const RecalculateGoalButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderSubtleCyan,
            width: 1.0,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_fix_high_rounded,
              color: AppColors.cyanBright,
              size: 18,
            ),
            SizedBox(width: 10),
            Text(
              'Recalculate Recommended Goal',
              style: TextStyle(
                color: AppColors.cyanBright,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Display the hydration target recommendation dialog with recalculated amount
void showRecalculateGoalDialog(
  BuildContext context,
  WaterProvider provider, {
  VoidCallback? onGoalApplied,
}) {
  final profile = provider.profile;
  final recommendedMl = profile.recommendedIntakeMl;
  final isOz = profile.unit == MeasureUnit.oz;

  final recommendedDisplay = isOz
      ? UnitConverter.mlToOz(recommendedMl.toDouble()).round()
      : recommendedMl;
  final currentDisplay = isOz
      ? UnitConverter.mlToOz(provider.dailyGoalMl.toDouble()).round()
      : provider.dailyGoalMl;
  final unitStr = isOz ? 'oz' : 'ml';

  showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: AppColors.cardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cyanBright.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_fix_high_rounded,
                      color: AppColors.cyanBright,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Target Recommendation',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Based on your weight (${profile.weightKg.round()} kg), height (${profile.heightCm.round()} cm), age (${profile.age}), activity level, and climate:',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT GOAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$currentDisplay $unitStr',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.textMuted,
                        size: 16,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.cyanBright,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$recommendedDisplay $unitStr',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.cyanBright,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Keep Current',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      provider.setDailyGoal(recommendedMl);
                      onGoalApplied?.call();
                      Navigator.pop(ctx);
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Goal updated to $recommendedDisplay $unitStr!',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: AppColors.cyanDark,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyanBright,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Goal',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

