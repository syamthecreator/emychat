import 'package:flutter/material.dart';

class MetricStatModel {
  const MetricStatModel({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
  });

  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;

  MetricStatModel copyWith({
    String? title,
    String? value,
    String? change,
    bool? isPositive,
    IconData? icon,
  }) {
    return MetricStatModel(
      title: title ?? this.title,
      value: value ?? this.value,
      change: change ?? this.change,
      isPositive: isPositive ?? this.isPositive,
      icon: icon ?? this.icon,
    );
  }
}

class ChannelVolumeModel {
  const ChannelVolumeModel({
    required this.title,
    required this.totalVolume,
    required this.icon,
    required this.iconColor,
    required this.inbound,
    required this.outbound,
    required this.avgResponse,
  });

  final String title;
  final String totalVolume;
  final IconData icon;
  final Color iconColor;
  final String inbound;
  final String outbound;
  final String avgResponse;
}

class AnalyticsOverviewModel {
  const AnalyticsOverviewModel({
    required this.range,
    required this.stats,
    required this.channelVolume,
  });

  final String range;
  final List<MetricStatModel> stats;
  final ChannelVolumeModel channelVolume;
}
