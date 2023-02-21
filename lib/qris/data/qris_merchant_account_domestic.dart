import 'package:qris_monit_package/qris_monit_package.dart';

/// Representation of Unique, Single Merchant Account Information specifically
/// for Domestic Transactions.
///
/// Shares the same signature as [QRISMerchantAccountInformation], excluding
/// the [QRISMerchantAccountInformation.panCode] data.
///
/// This data is expected to be provided, given that no Merchant information
/// exists between ID "02" to "45".
class QRISMerchantAccountDomestic {

  QRISMerchantAccountDomestic(String data,): _data = QRIS.fillData(
    data, (position) => QRISMerchantError(position),
  );

  final Map<String, String> _data;

  /// See [QRISMerchantAccountInformation.globallyUniqueIdentifier]
  String? get globallyUniqueIdentifier => _data["00"];

  /// See [QRISNationalMerchantIdentifier]
  late final QRISNationalMerchantIdentifier merchantID = QRISNationalMerchantIdentifier(_data["02"] ?? "",);

  /// See [QRISMerchantAccountInformation.merchantCriteria]
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