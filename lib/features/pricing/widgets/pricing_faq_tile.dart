import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:emychat/app/theme/app_colors.dart';
import '../providers/pricing_provider.dart';

class PricingFaqTile extends StatelessWidget {
  const PricingFaqTile({
    super.key,
    required this.question,
    required this.answer,
    required this.isDark,
  });

  final String question;
  final String answer;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final pricingProvider = context.watch<PricingProvider>();
    final expanded = pricingProvider.isFaqExpanded(question);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: expanded
              ? (isDark ? AppColors.arcticBlue : AppColors.sapphireBlue)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: expanded,
            onExpansionChanged: (v) => pricingProvider.toggleFaq(question, v),
            trailing: Icon(
              expanded ? RemixIcons.subtract_line : RemixIcons.add_line,
              color: expanded
                  ? (isDark ? AppColors.arcticBlue : AppColors.sapphireBlue)
                  : (isDark ? AppColors.silver : AppColors.lightTextSecondary),
              size: 16,
            ),
            title: Text(
              question,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.crispWhite : AppColors.lightTextPrimary,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppColors.silver : AppColors.lightTextSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
