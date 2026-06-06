import 'package:flutter/material.dart';

class AffirmationView extends StatefulWidget {
  const AffirmationView({super.key});

  @override
  State<AffirmationView> createState()
      => _AffirmationViewState();
}

class _AffirmationViewState
    extends State<AffirmationView> {

  final affirmations = [

    "Saya kuat menghadapi hari ini",

    "Saya layak untuk bahagia",

    "Perasaan saya valid",

    "Saya berkembang setiap hari",
  ];

  int index = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Afirmasi Positif",
        ),
      ),

      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Text(
                affirmations[index],

                textAlign:
                    TextAlign.center,

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {

                  setState(() {

                    index =
                        (index + 1) %
                            affirmations
                                .length;
                  });
                },

                child: const Text(
                  "Afirmasi Baru",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}