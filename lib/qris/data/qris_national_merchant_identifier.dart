/// National Merchant Identifier contained within Entry ID 51 of the QRIS.
class QRISNationalMerchantIdentifier {

  QRISNationalMerchantIdentifier._(this._merchantId, {
    this.countryCode,
    this.entityTypeCode,
    this.centuryCode,
    this.generatedYearLastTwoDigits,
    this.sequenceNumberAndCheckDigit,
  });

  factory QRISNationalMerchantIdentifier(String merchantId,) {
    String? countryCode;
    int? entityTypeCode;
    int? centuryCode;
    String? generatedYearLastTwoDigits;
    String? sequenceNumberAndCheckDigit;
    final id = merchantId;
    if (id.length >= 2) {
      countryCode = "${id[0]}${id[1]}";
      if (id.length >= 3) {
        entityTypeCode = int.tryParse(id[2],);
        if (id.length >= 4) {
          centuryCode = int.tryParse(id[3],);
          if (id.length >= 6) {
            generatedYearLastTwoDigits = "${id[4]}${id[5]}";
            if (id.length > 6) {
              sequenceNumberAndCheckDigit = id.substring(6,);
            }
          }
        }
      }
    }
    return QRISNationalMerchantIdentifier._(
      merchantId,
      countryCode: countryCode,
      centuryCode: centuryCode,
      generatedYearLastTwoDigits: generatedYearLastTwoDigits,
      entityTypeCode: entityTypeCode,
      sequenceNumberAndCheckDigit: sequenceNumberAndCheckDigit,
    );
  }

  String? _merchantId;

  /// Expected to default to "ID" (Indonesia)
  final String? countryCode;

  /// Numeric identifier for Business Entity (1 or 2)
  final int? entityTypeCode;

  final int? centuryCode;

  /// QR Code Generated year, last two digits
  final String? generatedYearLastTwoDigits;

  final String? sequenceNumberAndCheckDigit;

  @override
  String toString() => _merchantId ?? "";
}