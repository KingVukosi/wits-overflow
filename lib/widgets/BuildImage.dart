import 'package:flutter/material.dart';
import 'package:wits_overflow/utils/DataModel.dart';

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
          // if (imageFile != 'NULL') buildFileDetails(imageFile!),
        ],
      );

  Widget buildImage() {
    if (imageFile == 'NULL') return SizedBox(height: 1);

    // return HtmlElementView(viewType: )

    return Image.network(
      imageFile!,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (context, error, _) => buildEmptyFile(error.toString()),
    );
  }

  Widget buildEmptyFile(String text) => Container(
        width: 120,
        height: 120,
        color: Colors.blue.shade300,
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
}

// buildFileDetails(String imageFile) {
//   final style = TextStyle(fontSize: 20);

//   return Container(
//     margin: EdgeInsets.only(left: 24),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Text(imageFile, style: style.copyWith(fontWeight: FontWeight.bold)),
//       ],
//     ),
//   );
// }
