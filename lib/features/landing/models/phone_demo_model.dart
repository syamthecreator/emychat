enum PhoneDemoPlatform {
  neutral,
  whatsapp,
}

class PhoneDemoMessageModel {
  const PhoneDemoMessageModel({
    required this.text,
    required this.isSender,
    required this.time,
    this.status,
  });

  final String text;
  final bool isSender;
  final String time;
  final String? status;
}
