/// Indicator of the merchant's size/scale.
///
/// Excluding the asset values of occupied land for business and infrastructures.
/// Number figures are represented in IDR.
enum QRISMerchantCriteria {
  /// The smallest merchant size with average net profit up to 50 millions and
  /// sales average up to 300 millions.
  micro,
  /// The small merchant size above [QRISMerchantCriteria.micro] with net profit
  /// up to 500 millions and sales average up to 2.5 billions.
  small,
  /// The medium size specifies a net profit range between 500 millions, up to
  /// 10 billions, with sales average up to 50 billions.
  medium,
  /// Number figures are higher than [QRISMerchantCriteria.medium].
  large,
  /// No clear specifications
  regular,
}