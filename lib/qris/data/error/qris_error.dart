class _QRISError extends Error {
  _QRISError(this.position);

  final int position;
}

class QRISError extends _QRISError {
  QRISError(int position) : super(position);

  @override
  String toString() => "Invalid QRIS String data at position $position";
}

class QRISMerchantError extends _QRISError {
  QRISMerchantError(int position) : super(position);

  @override
  String toString() => "Invalid Merchant data at position $position";
}

class QRISAdditionalDataError extends _QRISError {
  QRISAdditionalDataError(int position) : super(position);

  @override
  String toString() =>
      "Invalid Additional Data Field Template at position $position";
}

class QRISLocalizationError extends _QRISError {
  QRISLocalizationError(int position) : super(position);

  @override
  String toString() => "Invalid Localized Merchant Info at position $position";
}
