/// The additional consumer data request contained within [QRISAdditionalData].
///
/// The information is obtained within ID "09", if available. Expected a [String]
/// that contains letter A, M, or E, where each letter represents a requirement
/// for a certain information from the consumer.
/// - **A** stands for Address Requirement
/// - **M** stands for Phone Requirement
/// - **E** stands for Email Requirement
class QRISAdditionalConsumerDataRequest {

  QRISAdditionalConsumerDataRequest(String data,) {
    for (int i = 0; i < data.length; i++) {
      _data[data[i]] = true;
    }
  }

  final Map<String, bool> _data = {};

  bool get consumerAddressRequired => _data["A"] == true;

  bool get consumerPhoneRequired => _data["M"] == true;

  bool get consumerEmailRequired => _data["E"] == true;
}