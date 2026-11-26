class WorkspaceSettingsModel {
  const WorkspaceSettingsModel({
    required this.name,
    required this.webhookUrl,
    required this.isWebhookVerified,
  });

  final String name;
  final String webhookUrl;
  final bool isWebhookVerified;

  WorkspaceSettingsModel copyWith({
    String? name,
    String? webhookUrl,
    bool? isWebhookVerified,
  }) {
    return WorkspaceSettingsModel(
      name: name ?? this.name,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      isWebhookVerified: isWebhookVerified ?? this.isWebhookVerified,
    );
  }
}
