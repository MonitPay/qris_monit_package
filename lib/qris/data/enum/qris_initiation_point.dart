/// The description of the origin of the QRIS Code
enum QRISInitiationPoint {
  /// The QRIS is static, usually printed physically around the merchant's
  /// vicinity.
  staticCode,
  /// The QRIS is dynamically generated, usually through smartphones/EDC devices
  /// from the merchant.
  dynamicCode,
}