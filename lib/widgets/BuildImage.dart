import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:universal_html/html.dart';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';

class MyImage extends StatelessWidget {
  final String? imageFile;

  const MyImage({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = imageFile!;
    // https://github.com/flutter/flutter/issues/41563
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      imageUrl,
      (int _) => ImageElement()..src = imageUrl,
    );
    return Container(
      height: 160,
      width: 160,
      child: HtmlElementView(
        viewType: imageUrl,
      ),
    );
  }
}

class ImageBuilder extends StatelessWidget {
  final String? imageFile;

  const ImageBuilder({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildImage(),
          if (imageFile != 'NULL') buildFileDetails(imageFile!),
        ],
      );

  Widget buildImage() {
    if (imageFile == 'NULL') return SizedBox(height: 1);

    return MyImage(imageFile: imageFile);

    // return Image.network(
    //   imageFile!,
    //   width: 120,
    //   height: 120,
    //   fit: BoxFit.cover,
    //   errorBuilder: (context, error, _) => buildEmptyFile(error.toString()),
    // );
  }

  Widget buildEmptyFile(String text) => Container(
        width: 150,
        height: 150,
        color: Colors.blue.shade300,
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
}

buildFileDetails(String imageFile) {
  return Container(
    margin: EdgeInsets.only(left: 24),
    child: new Center(
      child: new RichText(
        text: new TextSpan(
          children: [
            new TextSpan(
              text: 'Click To Open Image',
              style: new TextStyle(color: Colors.blue, fontSize: 20),
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  launch(imageFile);
                },
            ),
          ],
        ),
      ),
    ),
  );
}
