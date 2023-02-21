import 'package:qris_monit_package/qris_monit_package.dart';

///
/// Information of the Main Merchant, presented in a preferred language setting.
///
class QRISMerchantInformationLocalized {
  QRISMerchantInformationLocalized(
    String data,
  ) : _data = QRIS.fillData(
          data,
          (position) => QRISLocalizationError(position),
        );

  final Map<String, String> _data;

  /// The preferred language, presented in ISO 639 standard (two letters alphabet).
  String? get languagePreference => _data["00"];

  /// The merchant name, localized by [languagePreference]
  String? get merchantName => _data["01"];

  /// The city of the merchant location, localized by [languagePreference]
  String? get merchantCity => _data["02"];
}
