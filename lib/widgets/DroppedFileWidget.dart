import 'package:flutter/material.dart';
import 'package:wits_overflow/utils/DataModel.dart';

class DroppedFileWidget extends StatelessWidget {
  final DataModel? droppedFile;

  const DroppedFileWidget({
    Key? key,
    required this.droppedFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildImage(),
            if (droppedFile != null) buildFileDetails(droppedFile!),
          ],
        ),
      );

  Widget buildImage() {
    if (droppedFile == null) return buildEmptyFile('No File');

    return Image.network(
      droppedFile!.url,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (context, error, _) => buildEmptyFile('No preview'),
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

  buildFileDetails(DataModel dataModel) {
    final style = TextStyle(fontSize: 20);

    return Container(
      margin: EdgeInsets.only(left: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Selected Image',
              style: style.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(droppedFile!.mime, style: style),
          const SizedBox(height: 8),
          Text(droppedFile!.size, style: style),
        ],
      ),
    );
  }
}
