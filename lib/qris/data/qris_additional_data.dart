import 'package:qris_monit_package/qris_monit_package.dart';

/// Additional data that supports the current QRIS transaction with more
/// technical details.
///
/// Generation of this data may throw [QRISAdditionalDataError].
class QRISAdditionalData {

  QRISAdditionalData(String data,): _data = QRIS.fillData(
    data, (position) => QRISAdditionalDataError(position),
  );

  QRISAdditionalData._copy(this._data,);

  /// Creates a copy of [QRISAdditionalData] with overridden properties.
  QRISAdditionalData copyWith({
    String? billNumber,
    String? mobileNumber,
    String? storeLabel,
    String? loyaltyNumber,
    String? referenceLabel,
    String? customerLabel,
    String? terminalLabel,
    String? purposeOfTransaction,
  }) {
    final Map<String, String?> dataCopy = Map.from(_data,);
    void filter(String key, String? newValue,) {
      if (newValue != null) {
        if (newValue.length >= 3) {
          dataCopy[key] = newValue.substring(0, 3,);
          return;
        }
      }
      dataCopy[key] = _data[key];
    }
    filter("01", billNumber,);
    filter("02", mobileNumber,);
    filter("03", storeLabel,);
    filter("04", loyaltyNumber,);
    filter("05", referenceLabel,);
    filter("06", customerLabel,);
    filter("07", terminalLabel,);
    filter("08", purposeOfTransaction,);
    return QRISAdditionalData._copy(dataCopy,);
  }

  final Map<String, String?> _data;

  /// Bill Number or Invoice Number.
  ///
  /// Indicates that the mobile app should ask the consumer for a Bill Number,
  /// such as for Utility Payments.
  String? get billNumber => _data["01"];

  /// The mobile number that interacts with this transaction.
  ///
  /// Indicates that the consumer should provide a mobile number, especially for
  /// transactions like Phone Utility Payment or Phone Credit Charging.
  String? get mobileNumber => _data["02"];

  /// Information related to the store's label.
  ///
  /// Indicates that the mobile app should ask the consumer for the store's
  /// label. For example, the store's label will be shown for ease of specific
  /// store identification.
  String? get storeLabel => _data["03"];

  /// Loyalty card number, if available.
  ///
  /// Indicates that the mobile app should ask the consumer to provide the
  /// loyalty card number, if available.
  String? get loyaltyNumber => _data["04"];

  /// Merchant/Acquirer defined value for transaction identification.
  ///
  /// Typically used in transaction log or receipts.
  String? get referenceLabel => _data["05"];

  /// Identifier for a customer.
  ///
  /// Usually depicted as unique Customer IDs, such as Subscription Number,
  /// Student Registration Number, etc.
  String? get customerLabel => _data["06"];

  /// Value related to the payment terminal of a merchant.
  ///
  /// Can be used to identify a distinct payment terminal within many choices at
  /// a merchant.
  String? get terminalLabel => _data["07"];

  /// Describes the purpose of the transaction.
  String? get purposeOfTransaction => _data["08"];

  /// Additional information to assist with the transaction completion.
  ///
  /// Example use case, such as providing a flag indicating that the user has to
  /// provide the mobile number of current payment device, and if necessary,
  /// provides it automatically for convenience.
  QRISAdditionalConsumerDataRequest? get additionalConsumerDataRequest {
    final data = _data["09"];
    if (data is String) {
      return QRISAdditionalConsumerDataRequest(data,);
    }
    return null;
  }

  /// Acquirer's use
  QRISProprietaryData? get proprietaryData {
    final data = _data["99"];
    if (data != null) {
      return QRISProprietaryData(data,);
    }
    return null;
  }
}