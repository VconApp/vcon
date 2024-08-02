import 'package:get/get.dart';

class AuthController extends GetxController {
  var authorizerIRID = ''.obs;

  void setAuthorizerIRID(String irID) {
    authorizerIRID.value = irID;
  }
}