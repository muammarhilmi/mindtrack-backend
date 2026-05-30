import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

Widget buildGoogleSignInButton({required VoidCallback onTap}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 0), // GIS button has its own padding
    height: 48,
    child: web.renderButton(),
  );
}
