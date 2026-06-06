import 'package:flutter/material.dart';

class BreathingView extends StatelessWidget {
  const BreathingView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Latihan Pernapasan",
        ),
      ),

      body: const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              Icons.air,
              size: 120,
              color: Colors.blue,
            ),

            SizedBox(height: 20),

            Text(
              "Tarik napas perlahan\n4 detik",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}