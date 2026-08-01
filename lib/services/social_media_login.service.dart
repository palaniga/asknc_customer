import 'dart:convert';
import 'dart:math';

import 'package:Asknc_user/view_models/login.view_model.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialMediaLoginService {
  //

  //Google login
  void googleLogin(LoginViewModel model) async {
    //
    model.setBusy(true);
    try {
      //
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      try {
        // Trigger the authentication flow
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.disconnect();
        }
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        //
        if (googleUser == null) {
          throw "Google login failed".tr();
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.signInWithCredential(credential);

        //Login to with firebase token
        //
        // Sign the user in (or link) with the credential
        try {
          final apiResponse = await model.authRequest.socialLogin(
            googleUser.email,
            googleAuth.idToken,
            "google",
          );
          //
          if (apiResponse != null) {
            await model.handleDeviceLogin(apiResponse);
          } else {
            model.openRegister(
              email: googleUser.email,
              name: googleUser.displayName,
            );
          }
        } catch (error) {
          model.toastError("$error");
        }
        //
      } on FirebaseAuthException catch (error) {
        model.toastError(
          "${error.message}",
          length: Toast.LENGTH_LONG,
        );
      } catch (error) {
        model.toastError("$error");
      }
    } catch (error) {
      model.toastError("$error");
    }
    model.setBusy(false);
  }

  //Facebook login
  // void facebookLogin(LoginViewModel model) async {
  //   //
  //   model.setBusy(true);
  //   //
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login(
  //       permissions: ["email", "public_profile"],
  //     );
  //     if (result.status == LoginStatus.success) {
  //       // you are logged
  //       final AccessToken? accessToken = result.accessToken;
  //       if (accessToken == null) {
  //         throw "Facebook login failed".tr();
  //       }
  //       try {
  //         // Create a credential from the access token
  //         final OAuthCredential facebookAuthCredential =
  //             FacebookAuthProvider.credential(
  //           accessToken.token,
  //         );
  //
  //         // Once signed in, return the UserCredential
  //         UserCredential userAccount =
  //             await FirebaseAuth.instance.signInWithCredential(
  //           facebookAuthCredential,
  //         );
  //
  //         //
  //         final apiResponse = await model.authRequest.socialLogin(
  //           userAccount.user!.email!,
  //           accessToken.token,
  //           "facebook",
  //         );
  //         //
  //         if (apiResponse != null) {
  //           await model.handleDeviceLogin(apiResponse);
  //         } else {
  //           model.openRegister(
  //             email: userAccount.user!.email!,
  //             name: userAccount.user!.displayName ?? "",
  //           );
  //         }
  //       } on FirebaseAuthException catch (error) {
  //         model.toastError(
  //           "${error.message}",
  //           length: Toast.LENGTH_LONG,
  //         );
  //       } catch (error) {
  //         model.toastError("$error");
  //       }
  //     } else {
  //       print(result.status);
  //       print(result.message);
  //       model.toastError("${result.message}");
  //     }
  //   } catch (error) {
  //     model.toastError("$error");
  //   }
  //   //
  //   model.setBusy(false);
  // }

  //apple login
  Future<void> appleLogin(LoginViewModel model) async {
    model.setBusy(true);
    try {
      // 1. Generate secure nonce
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // 2. Request Apple credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // 3. Create Firebase OAuth credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );

      // 4. Sign in with Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      final user = userCredential.user;
      if (user == null) {
        throw Exception("Apple sign-in failed. User is null.");
      }

      // 5. Get Firebase ID token (THIS is what backend needs)
      final firebaseIdToken = await user.getIdToken(true);

      // 6. Call backend social login
      final apiResponse = await model.authRequest.socialLogin(
        user.email ?? "",
        firebaseIdToken,
        "apple",
        nonce: nonce,
        uid: user.uid,
      );

      // 7. Handle login / registration
      if (apiResponse != null) {
        await model.handleDeviceLogin(apiResponse);
      } else {
        model.openRegister(
          email: user.email,
          name: user.displayName ??
              "${appleCredential.givenName ?? ""} ${appleCredential.familyName ?? ""}"
                  .trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      model.toastError(e.message ?? "Apple authentication failed");
    } catch (e) {
      model.toastError(e.toString());
    } finally {
      model.setBusy(false);
    }
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
