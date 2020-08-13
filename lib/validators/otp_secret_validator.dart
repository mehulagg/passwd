import 'package:passwd/models/validator.dart';

class OtpSecretValidator implements Validator {
  @override
  bool validate(String input) {
    return input.length == 16 || input.length == 32;
  }
}
