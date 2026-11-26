import 'package:flutter/material.dart';
import 'package:emychat/core/utils/shell_scope.dart';

class DashboardMetricModel {
  const DashboardMetricModel({
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.destination,
  });

  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final NavDestination destination;

  DashboardMetricModel copyWith({
    String? label,
    String? value,
    String? subtext,
    IconData? icon,
    NavDestination? destination,
  }) {
    return DashboardMetricModel(
      label: label ?? this.label,
      value: value ?? this.value,
      subtext: subtext ?? this.subtext,
      icon: icon ?? this.icon,
      destination: destination ?? this.destination,
    );
  }
}
