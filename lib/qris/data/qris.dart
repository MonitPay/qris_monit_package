import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:qris_monit_package/qris_monit_package.dart';
import 'package:http/http.dart' as http;

/// Creates an object that holds various information of a QRIS (QR Indonesian
/// Standard) Code.
///
/// Default implementation requires a [String] containing a well-formatted QR
/// text data according to ISO/IEC 18004, which is usually obtainable after
/// scanning a physically printed QR Codes, or the one generated dynamically
/// from certain merchant digital devices.
class QRIS {
  QRIS._(this._data);

  /// Generates a QRIS instance with parsed information, given a [data] String.
  ///
  /// Throws a [QRISError] if the provided data is not a valid String that
  /// conforms to QRIS standard.
  QRIS(String data)
      : _data = fillData(data, (position) => QRISError(position)) {
    _rawQrData = data;
    for (int i = 2; i <= 25; i++) {
      final key = i.toString().padLeft(
            2,
            '0',
          );
      final merchantData = _data[key];
      if (merchantData != null) {
        _primitivePaymentSystemMerchants[key] = merchantData;
      }
    }
    for (int i = 26; i <= 50; i++) {
      final key = i.toString().padLeft(
            2,
            '0',
          );
      final merchantData = _data[key];
      if (merchantData != null) {
        _merchants[key] = QRISMerchantAccountInformation(
          merchantData,
        );
      }
    }
    final additionalData = _data["62"];
    if (additionalData is String) {
      _additionalDataField = QRISAdditionalData(
        additionalData,
      );
    }
  }

  /// Creates a copy of existing QRIS instance with overridden properties.
  ///
  /// A typical use case such as adding a transaction amount to a physically
  /// scanned QRIS Code.
  ///
  /// Accepts a [transactionAmount] currently.
  QRIS copyWith({
    num? transactionAmount,
  }) {
    final Map<String, String?> dataCopy = Map.from(
      _data,
    );
    dataCopy["54"] = transactionAmount?.toString() ?? _data["54"];
    return QRIS._(
      dataCopy,
    );
  }

  late final String _rawQrData;

  final Map<String, String?> _data;

  static Map<String, String> fillData(
    String qris,
    Error Function(
      int position,
    )
        onError,
  ) {
    int i = 0;
    try {
      final Map<String, String> components = {};
      while (i < qris.length) {
        final rootId = "${qris[i]}${qris[i + 1]}";
        final length = int.tryParse(
              "${qris[i + 2]}${qris[i + 3]}",
            ) ??
            0;
        components[rootId] = qris.substring(
          i + 4,
          i + 4 + length,
        );
        i += 4 + length;
      }
      return Map.unmodifiable(
        components,
      );
    } catch (_) {
      throw onError(
        i,
      );
    }
  }

  /// The Payload Format Indicator, indicates the version of the QRIS Code.
  ///
  /// A valid QRIS Code must have this field.
  int get payloadFormatIndicator => int.parse(
        _data["00"] ?? "",
      );

  /// The Point of Initiation Method code. Indicates the origin of the QRIS Code.
  ///
  /// 11 indicates a static QRIS Code, usually the physically printed ones.
  /// 12 indicates a dynamically generated QRIS Code, usually generated by the
  /// merchant.
  QRISInitiationPoint? get pointOfInitiation {
    final data = _data["01"];
    switch (data) {
      case "11":
        return QRISInitiationPoint.staticCode;
      case "12":
        return QRISInitiationPoint.dynamicCode;
    }
    return null;
  }

  final Map<String, String> _primitivePaymentSystemMerchants = {};

  /// List of merchants associated with Primitive Payment Systems such as
  /// VISA, MasterCard, Union Pay, etc.
  ///
  /// Consisted of Strings referring to the payment identifiers such as the
  /// number of credit/debit card provided.
  List<String> get primitivePaymentSystemMerchants =>
      _primitivePaymentSystemMerchants.values.toList(
        growable: false,
      );

  List<String> _getPrimitiveMerchantsByRange(
    int start,
    int end,
  ) {
    final merchants = <String>[];
    for (int i = start; i <= end; i++) {
      final key = i.toString().padLeft(
            2,
            '0',
          );
      final merchant = _primitivePaymentSystemMerchants[key];
      if (merchant != null) {
        merchants.add(
          merchant,
        );
      }
    }
    return List.unmodifiable(
      merchants,
    );
  }

  /// VISA Merchants (ID "02" and "03")
  List<String> get visaMerchants => _getPrimitiveMerchantsByRange(
        2,
        3,
      );

  /// MasterCard Merchants (ID "04" and "05)
  List<String> get mastercardMerchants => _getPrimitiveMerchantsByRange(
        4,
        5,
      );

  /// EMVCo Merchants (ID "06" - "08")
  List<String> get emvCoMerchants => _getPrimitiveMerchantsByRange(
        6,
        8,
      );

  /// Discover Credit Card Merchants (ID "09" and "10")
  List<String> get discoverMerchants => _getPrimitiveMerchantsByRange(
        9,
        10,
      );

  /// AMEX (American Express) Merchants (ID "11" and "12")
  List<String> get amExMerchants => _getPrimitiveMerchantsByRange(
        11,
        12,
      );

  /// JCB (Japan Credit Bureau) Merchants (ID "13" and "14")
  List<String> get jcbMerchants => _getPrimitiveMerchantsByRange(
        13,
        14,
      );

  /// Union Pay Merchants (ID "15" and "16")
  List<String> get unionPayMerchants => _getPrimitiveMerchantsByRange(
        15,
        16,
      );

  /// EMVCo Merchants (ID "17" - "25")
  List<String> get emvCoMerchants2 => _getPrimitiveMerchantsByRange(
        17,
        25,
      );

  final Map<String, QRISMerchantAccountInformation> _merchants = {};

  /// All available non-primitive merchants listed on this QRIS Code
  List<QRISMerchantAccountInformation> get merchants =>
      _merchants.values.toList(
        growable: false,
      );

  List<QRISMerchantAccountInformation> _getMerchantsByRange(
    int start,
    int end,
  ) {
    final merchants = <QRISMerchantAccountInformation>[];
    for (int i = start; i <= end; i++) {
      final key = i.toString().padLeft(
            2,
            '0',
          );
      final merchant = _merchants[key];
      if (merchant != null) {
        merchants.add(
          merchant,
        );
      }
    }
    return List.unmodifiable(
      merchants,
    );
  }

  /// Domestic Merchants, most common QRIS Codes are used by domestic merchants (ID "26" - "45")
  List<QRISMerchantAccountInformation> get domesticMerchants =>
      _getMerchantsByRange(
        26,
        45,
      );

  /// Additional Domestic Merchants information as reserve list, usually empty (ID "46" - "50")
  List<QRISMerchantAccountInformation> get reservedDomesticMerchants =>
      _getMerchantsByRange(
        46,
        50,
      );

  /// Merchant Account Information Domestic Central Repository
  ///
  /// If [merchants] is empty, then most likely there's a single Merchant Account
  /// available at ID "51". (No merchant information between ID "02" to "45")
  QRISMerchantAccountDomestic? get merchantAccountDomestic {
    final data = _data["51"];
    if (data != null) {
      return QRISMerchantAccountDomestic(
        data,
      );
    }
    return null;
  }

  /// Merchant Category Code (MCC in short)
  ///
  /// Code references are available at [https://github.com/greggles/mcc-codes/](https://github.com/greggles/mcc-codes/)
  int? get merchantCategoryCode => int.tryParse(
        _data["52"] ?? "",
      );

  /// The Transaction Currency, conforms to ISO 4217, represented as 3 digits Numeric.
  ///
  /// Should default to constant **"360"** to represent IDR currency (Indonesian).
  /// Reference: [https://en.wikipedia.org/wiki/ISO_4217](https://en.wikipedia.org/wiki/ISO_4217)
  String? get transactionCurrency => _data["53"];

  Future<Currency> getTransactionCurrency() async {
    var response = await http.get(
      Uri.parse(
          'https://restcountries.com/v3.1/alpha/$transactionCurrency?fields=name,currencies'),
    );

    debugPrint('response.body: ${response.body}');
    debugPrint('response.body Map: ${jsonDecode(response.body)}');
    debugPrint('statusCode: ${response.statusCode}');

    var data = jsonDecode(response.body);
    debugPrint('response.body Map: ${data['name']}');
    debugPrint('response.body Map: ${data['currencies']}');
    debugPrint('response.body Map: ${(data['currencies'] as Map).keys.first}');
    debugPrint(
        'response.body Map: ${data['currencies'][(data['currencies'] as Map).keys.first]['name']}');
    debugPrint(
        'response.body Map: ${data['currencies'][(data['currencies'] as Map).keys.first]['symbol']}');

    return Currency(
      data['currencies'][(data['currencies'] as Map).keys.first]['name'],
      (data['currencies'] as Map).keys.first,
      data['currencies'][(data['currencies'] as Map).keys.first]['symbol'],
    );
  }

  num? _userInputTransactionAmount;

  /// The transaction amount contained within this QRIS, or the one entered manually
  /// through [transactionAmount]'s setter, if any.
  num? get transactionAmount =>
      _userInputTransactionAmount ?? originalTransactionAmount;

  /// The original transaction amount available within this QRIS, fetched from
  /// the raw data, if available.
  num? get originalTransactionAmount => num.tryParse(
        _data["54"] ?? "",
      );

  set transactionAmount(
    num? amount,
  ) =>
      _userInputTransactionAmount = amount;

  /// The [TipIndicator] of the QRIS Code.
  ///
  /// Indicates the origin of the provided Tip to the merchant, if available.
  TipIndicator? get tipIndicator {
    final data = _data["55"];
    switch (data) {
      case "01":
        return TipIndicator.mobileAppRequiresConfirmation;
      case "02":
        return TipIndicator.tipValueFixed;
      case "03":
        return TipIndicator.tipValuePercentage;
    }
    return null;
  }

  /// This should be a non-null value if [tipIndicator] is [TipIndicator.tipValueFixed]
  num? get tipValueOfFixed {
    final data = _data["56"];
    if (data != null) {
      return num.tryParse(
        data,
      );
    }
    return null;
  }

  /// This should be a non-null value if [tipIndicator] is [TipIndicator.tipValuePercentage]
  ///
  /// Expected range is 00.01 to 99.99 (in percentage)
  double? get tipValueOfPercentage {
    final data = _data["57"];
    if (data != null) {
      return double.tryParse(
        data,
      );
    }
    return null;
  }

  /// The country code of the merchant, conforming to ISO 3166-1's Alpha 2 Code.
  ///
  /// Should default to "ID", if available.
  String? get countryCode => _data["58"];

  /// Name of the merchant, usually presented in UPPER-CASED String.
  String? get merchantName => _data["59"];

  /// City name of where the merchant is located, usually presented in UPPER-CASED
  /// String.
  String? get merchantCity => _data["60"];

  /// The postal code that corresponds to merchant's location.
  ///
  /// A non-null value is expected for [countryCode] equals to **"ID"**.
  String? get postalCode => _data["61"];

  QRISAdditionalData? _additionalDataField;

  /// Additional data that complements the QRIS data with more technical details.
  QRISAdditionalData? get additionalDataField => _additionalDataField;

  /// The additional information about the merchant, represented in a preferred
  /// language preference.
  QRISMerchantInformationLocalized? get merchantInformationLocalized {
    final data = _data["64"];
    if (data is String) {
      return QRISMerchantInformationLocalized(data);
    }
    return null;
  }

  /// The CRC Checksum of the QRIS Code contents as [int].
  int? get crc {
    final crc = _data["63"];
    if (crc != null) {
      return int.tryParse(
        crc,
        radix: 16,
      );
    }
    return null;
  }

  /// The CRC Checksum of the QRIS Code contents as Hex String
  String? get crcHex => _data["63"];

  List<String> get emvCo {
    return List.generate(
      15,
      (index) => index + 65,
    )
        .map(
          (e) => e.toString(),
        )
        .map(
          (e) => _data[e],
        )
        .whereType<String>()
        .toList();
  }

  /// The raw QRIS data stored as a plain [Map] of Strings.
  Map<String, String> get rawMapData => Map.unmodifiable(
        _data,
      );

  /// Print the QRIS contents using the [MapEntry] approach.
  void printByEntries() {
    // ignore: avoid_print
    print(
      _data.entries
          .map(
            (e) => "${e.key}: ${e.value}",
          )
          .join(
            "\n",
          ),
    );
  }

  /// The raw [String] of the scanned QRIS Code.
  @override
  String toString() {
    return _rawQrData;
  }
}
