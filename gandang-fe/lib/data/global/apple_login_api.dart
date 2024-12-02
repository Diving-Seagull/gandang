import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleLoginApi {
  static final instance = AppleLoginApi();

  Future<AuthorizationCredentialAppleID?> signInWithApple() async {
    try {
      return await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: "gandang.divingseagull.com",
          redirectUri: Uri.parse(
            "https://outstanding-furry-hip.glitch.me/callbacks/sign_in_with_apple",
          ),
        ),
      );
    } catch (error) {
      print('error = $error');
    }
  }
}