/// Represents the Transaction/Payment Method using this QRIS Code
enum PANMerchantMethod {
  unspecified,
  /// Debit Cards
  debit,
  /// Credit Cards
  credit,
  /// Common/Popular Electronic Money Providers, e.g: GoPay, OVO, DANA, etc
  electronicMoney,
  /// Reserved for Future Use
  rfu,
}