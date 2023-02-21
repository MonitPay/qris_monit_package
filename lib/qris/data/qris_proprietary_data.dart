import 'package:qris_monit_package/qris_monit_package.dart';

/// Additional information for Acquirer's purposes.
///
/// Throws [QRISAdditionalDataError] on invalid format.
class QRISProprietaryData {

  QRISProprietaryData(String data,): _data = QRIS.fillData(
    data, (position) => QRISAdditionalDataError(position),
  );

  final Map<String, String> _data;

  /// Unique Identifier for this Proprietary Data. Mostly defaults to "00".
  ///
  /// Max length of 32 characters.
  String? get globallyUniqueIdentifier => _data["00"];

  /// The proprietary data content.
  ///
  /// Max length of 81 characters.
  String? get proprietary => _data["01"];
}