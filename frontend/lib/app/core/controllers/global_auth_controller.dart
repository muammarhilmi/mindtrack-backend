import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/providers/auth_provider.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/google_sign_in_service.dart';
import '../storage/token_storage.dart';
import '../../routes/app_pages.dart';

class GlobalAuthController
    extends GetxController {

  final AuthProvider
      _provider =
      AuthProvider();

  Rxn<UserModel>
      currentUser =
      Rxn<UserModel>();

  RxBool isDarkMode =
      false.obs;

  bool get isLoggedIn =>
      currentUser.value !=
      null;

  @override
  void onInit() {
    super.onInit();
    GoogleSignInService.init().then((_) {
      GoogleSignIn.instance.authenticationEvents.listen((event) async {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          final auth = await event.user.authentication;
          if (auth.idToken != null) {
            try {
              final response = await _provider.googleLogin(idToken: auth.idToken!);
              final token = response.data['access_token'];
              await TokenStorage.saveToken(token);
              await getCurrentUser();
              Get.offAllNamed(Routes.BERANDA);
            } catch (e) {
              Get.snackbar('Error', e.toString());
            }
          }
        }
      });
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {

    final response =
        await _provider.login(
      email: email,
      password: password,
    );

    final token =
        response.data[
            'access_token'];

    await TokenStorage
        .saveToken(token);

    await getCurrentUser();
  }

  Future<void> loginWithGoogle() async {
    final idToken =
        await GoogleSignInService.signInAndGetIdToken();

    if (idToken == null) {
      throw Exception('Login Google dibatalkan');
    }

    final response =
        await _provider.googleLogin(
      idToken: idToken,
    );

    final token =
        response.data['access_token'];

    await TokenStorage.saveToken(token);
    await getCurrentUser();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {

    await _provider.register(
      name: name,
      email: email,
      password: password,
    );
  }

  Future<void>
      getCurrentUser() async {

    final token =
        await TokenStorage
            .getToken();

    if (token == null)
      return;

    final response =
        await _provider.me(
      token,
    );

    currentUser.value =
        UserModel.fromJson(
      response.data,
    );

    isDarkMode.value =
        currentUser
                .value
                ?.theme ==
            "dark";

    Get.changeThemeMode(
      isDarkMode.value
          ? ThemeMode.dark
          : ThemeMode.light,
    );
  }

  Future<void>
      changeTheme(
    String theme,
  ) async {

    isDarkMode.value =
        theme == "dark";

    Get.changeThemeMode(
      isDarkMode.value
          ? ThemeMode.dark
          : ThemeMode.light,
    );

    currentUser.update(
      (user) {
        user?.theme =
            theme;
      },
    );

    await _provider
        .updateProfile(
      theme: theme,
    );
  }

  Future<void>
      updateProfile({
    required String name,
    required String email,
    required String gender,
    String? password,
  }) async {

    await _provider
        .updateProfile(
      name: name,
      email: email,
      gender: gender,
      password: password,
    );

    await getCurrentUser();
  }

  Future<void>
      logout() async {

    await TokenStorage
        .deleteToken();

    currentUser.value =
        null;

    isDarkMode.value =
        false;
  }
}