import 'package:flutter/material.dart';
import 'dart:io';
import 'utils.dart';
import 'package:image_picker/image_picker.dart' as imgPicker;

class ImagePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              'Edit profile picture',
              style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          optionCard(
            context,
            'Take a new picture',
            size,
            Icons.camera_alt_outlined,
            () async {
              final file = await getImage(camera: true);
              Navigator.of(context).pop(file);
            },
          ),
          optionCard(
            context,
            'Select from gallery',
            size,
            Icons.photo_library_outlined,
            () async {
              final file = await getImage();
              Navigator.of(context).pop(file);
            },
          ),
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).accentColor,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<File?> getImage({bool camera = false}) async {
    final picker = imgPicker.ImagePicker();
    final pickedFile =
        await picker.pickImage(source: camera ? imgPicker.ImageSource.camera : imgPicker.ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }
}
