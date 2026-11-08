import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/constants.dart';

class WaterSizeSelector extends StatelessWidget {
  final int selectedSize;
  final int? customSize;
  final ValueChanged<int> onSizeChanged;

  const WaterSizeSelector({
    super.key,
    required this.selectedSize,
    this.customSize,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'CONTAINER SIZE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
        ),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: WaterDefaults.presetSizes.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == WaterDefaults.presetSizes.length) {
                // Custom size button
                final isCustomSelected =
                    !WaterDefaults.presetSizes.contains(selectedSize);
                return _CustomSizeChip(
                  isSelected: isCustomSelected,
                  currentCustomSize:
                      isCustomSelected ? selectedSize : customSize,
                  onCustomSize: onSizeChanged,
                );
              }
              final size = WaterDefaults.presetSizes[index];
              final isSelected = size == selectedSize;
              return _SizeChip(
                sizeMl: size,
                isSelected: isSelected,
                onTap: () => onSizeChanged(size),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SizeChip extends StatelessWidget {
  final int sizeMl;
  final bool isSelected;
  final VoidCallback onTap;

  const _SizeChip({
    required this.sizeMl,
    required this.isSelected,
    required this.onTap,
  });

  Widget _buildContainerIcon(Color color) {
    final filter = ColorFilter.mode(color, BlendMode.srcIn);
    if (sizeMl <= 100) {
      return SvgPicture.asset(
        'assets/images/drop_d1.svg',
        width: 18,
        height: 18,
        colorFilter: filter,
      );
    } else if (sizeMl <= 250) {
      return SvgPicture.asset(
        'assets/images/glass.svg',
        width: 20,
        height: 20,
        colorFilter: filter,
      );
    } else {
      return Icon(
        Icons.sports_bar_rounded,
        size: 22,
        color: color,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = isSelected ? Colors.black : AppColors.textMuted;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 74,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? Colors.white : AppColors.borderSubtle,
            width: 1.0,
          ),
          boxShadow: isSelected ? AppColors.whitePillShadow : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Center(
                child: _buildContainerIcon(activeColor),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${sizeMl}ml',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.black : AppColors.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomSizeChip extends StatelessWidget {
  final bool isSelected;
  final int? currentCustomSize;
  final ValueChanged<int> onCustomSize;

  const _CustomSizeChip({
    required this.isSelected,
    required this.currentCustomSize,
    required this.onCustomSize,
  });

  void _showCustomDialog(BuildContext context) {
    final controller = TextEditingController(
      text: currentCustomSize?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        title: const Text(
          'Custom Size',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'Enter amount',
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
            ),
            suffixText: 'ml',
            suffixStyle: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: AppColors.cardLight,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.emeraldPrimary, width: 1.5),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0 && value <= 5000) {
                onCustomSize(value);
                Navigator.pop(ctx);
              }
            },
            child: const Text(
              'Set',
              style: TextStyle(
                color: AppColors.emeraldBright,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showCustomDialog(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 74,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? Colors.white : AppColors.borderSubtle,
            width: 1.0,
          ),
          boxShadow: isSelected ? AppColors.whitePillShadow : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune_rounded,
              color: isSelected ? Colors.black : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              isSelected ? '${currentCustomSize}ml' : 'Custom',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.black : AppColors.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
