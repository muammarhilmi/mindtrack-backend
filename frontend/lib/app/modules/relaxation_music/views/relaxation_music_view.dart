import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RelaxationMusicView extends StatelessWidget {
  const RelaxationMusicView({super.key});

  @override
  Widget build(BuildContext context) {

    final musics = [

      {
        "title": "Rain Sounds",
        "url":
            "https://www.youtube.com/watch?v=mPZkdNFkNps"
      },

      {
        "title": "Ocean Waves",
        "url":
            "https://www.youtube.com/watch?v=V1bFr2SWP1I"
      },

      {
        "title": "Deep Focus",
        "url":
            "https://www.youtube.com/watch?v=lFcSrYw-ARY"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Musik Relaksasi",
        ),
      ),

      body: ListView.builder(
        itemCount: musics.length,

        itemBuilder: (context, index) {

          final item = musics[index];

          return ListTile(
            leading: const Icon(
              Icons.music_note,
            ),

            title: Text(
              item["title"]!,
            ),

            trailing: IconButton(
              icon: const Icon(
                Icons.play_arrow,
              ),

              onPressed: () async {

                await launchUrl(
                  Uri.parse(
                    item["url"]!,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}