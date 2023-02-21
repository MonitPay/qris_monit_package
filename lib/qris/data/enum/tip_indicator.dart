/// Tip Indicator indicates how the Tip to the merchant should be calculated/provided.
enum TipIndicator {
  /// The mobile app should ask for consumer's confirmation to provide the tip amount.
  mobileAppRequiresConfirmation,
  /// The tip value must be a fixed numeric amount.
  tipValueFixed,
  /// The tip value must be calculated as percentage amount between 00.01 - 99.99%.
  tipValuePercentage,
}