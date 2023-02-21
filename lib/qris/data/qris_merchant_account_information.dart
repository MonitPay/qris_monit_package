import 'package:qris_monit_package/qris_monit_package.dart';

/// The information of a Merchant Account
///
/// Plain merchants usually only have a single Merchant Account embedded in the
/// QRIS code.
///
/// Throws [QRISMerchantError] on invalid Merchant data.
class QRISMerchantAccountInformation {

  QRISMerchantAccountInformation(String data,): _data = QRIS.fillData(
    data, (position) => QRISMerchantError(position),
  );

  final Map<String, String> _data;

  /// Merchant identifier in the form of reverse domain name. Usually presented
  /// in UPPER-CASED.
  ///
  /// e.g: COM.EXAMPLE.DEMO
  String? get globallyUniqueIdentifier => _data["00"];

  /// Personal Account Number (PAN)
  String? get panCode => _data["01"];

  /// National Numbering System (NNS), which is the first 8 digits of PAN
  String? get nationalNumberingSystemDigits {
    final panCode = this.panCode;
    if (panCode != null) {
      if (panCode.length >= 8) {
        return panCode.substring(0, 8,);
      }
    }
    return null;
  }

  /// The main transaction/payment method.
  PANMerchantMethod get panMerchantMethod {
    final panCode = this.panCode;
    if (panCode != null) {
      if (panCode.length >= 9) {
        final indicator = panCode[8];
        switch (indicator) {
          case "0": return PANMerchantMethod.unspecified;
          case "1": return PANMerchantMethod.debit;
          case "2": return PANMerchantMethod.credit;
          case "3": return PANMerchantMethod.electronicMoney;
          default:
            final indicatorValue = int.tryParse(indicator,);
            if (indicatorValue != null) {
              if (indicatorValue >= 4 && indicatorValue <= 9) {
                return PANMerchantMethod.rfu;
              }
            }
            return PANMerchantMethod.unspecified;
        }
      }
    }
    return PANMerchantMethod.unspecified;
  }

  /// Merchant ID, with length up to 15 characters
  String? get id => _data["02"];

  /// Merchant Criteria which describes the size/scale of the merchant
  QRISMerchantCriteria get merchantCriteria {
    final data = _data["03"];
    switch (data) {
      case "UMI": return QRISMerchantCriteria.micro;
      case "UKE": return QRISMerchantCriteria.small;
      case "UME": return QRISMerchantCriteria.medium;
      case "UBE": return QRISMerchantCriteria.large;
    }
    return QRISMerchantCriteria.regular;
  }

  String get merchantCriteriaString => _data["03"] ?? "URE";

  @override
  String toString() {
    return _data.entries.map((e) => "${e.key}: ${e.value}",).join("\n",);
  }
}