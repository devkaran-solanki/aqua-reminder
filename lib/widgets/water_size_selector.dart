import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class WaterSizeSelector extends StatelessWidget {
  final int selectedSize;
  final ValueChanged<int> onSizeChanged;

  const WaterSizeSelector({
    super.key,
    required this.selectedSize,
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
            'Container Size',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: WaterDefaults.presetSizes.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == WaterDefaults.presetSizes.length) {
                // Custom size button
                return _CustomSizeChip(
                  isSelected: !WaterDefaults.presetSizes.contains(selectedSize),
                  currentCustomSize: WaterDefaults.presetSizes.contains(selectedSize)
                      ? null
                      : selectedSize,
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

  IconData _getGlassIcon() {
    if (sizeMl <= 150) return Icons.local_cafe;
    if (sizeMl <= 350) return Icons.water_drop;
    if (sizeMl <= 500) return Icons.local_drink;
    return Icons.sports_bar;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 72,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.surfaceLight.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getGlassIcon(),
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              '${sizeMl}ml',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text(
          'Custom Size',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: 'Enter amount in ml',
            hintStyle: TextStyle(
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            suffixText: 'ml',
            suffixStyle: const TextStyle(color: AppColors.textSecondary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.surfaceLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.primary),
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
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
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
        width: 72,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary.withValues(alpha: 0.5)
                : AppColors.surfaceLight.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune,
              color: isSelected ? AppColors.secondary : AppColors.textTertiary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              isSelected ? '${currentCustomSize}ml' : 'Custom',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.secondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
