import 'package:flutter/material.dart';
import 'google_sign_in_button_stub.dart'
    if (dart.library.html) 'google_sign_in_button_web.dart';

class CustomGoogleSignInButton extends StatelessWidget {
  final VoidCallback onTap;
  
  const CustomGoogleSignInButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return buildGoogleSignInButton(onTap: onTap);
  }
}
