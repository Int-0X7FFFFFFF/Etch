// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../common.dart';
import 'dart:convert';
import 'dart:io';

class DrawPage extends StatefulWidget {
  const DrawPage({super.key});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  @override
  Widget build(BuildContext context) {
    var server = Provider.of<API>(context).getAPI;
    return Scaffold(
      appBar: AppBar(title: const Text("Select a image to start")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            Provider.of<Load>(context, listen: false).onloading();
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.image,
              allowMultiple: false,
            );
            if (result != null && result.files.isNotEmpty) {
              File pickedImage = File(result.files.single.path!);
              // Do something with the picked image file
              // Load an image from file
              List<int> imageBytes = await pickedImage.readAsBytes();
              // Convert the image bytes to base64
              String base64Image = base64Encode(imageBytes);
              var data = await server.post_image(base64Image);
              if (data['status']) {
                // print(data['img']);
                String base64Output = data['img'];
                Provider.of<Load>(context, listen: false).outloading();
                Navigator.pushNamed(context, '/prview',
                    arguments: {'img': base64Image, 'output': base64Output});
              } else {
                throw Exception(data['msg']);
              }
            } else {
              Provider.of<Load>(context, listen: false).outloading();
              // No image picked
            }
          } catch (e) {
            Provider.of<Load>(context, listen: false).outloading();
            final snackBar = SnackBar(
              content: Text(e.toString()),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: getButton(),
      ),
    );
  }

  getButton() {
    var loadStat = Provider.of<Load>(context).getLoading;
    if (loadStat == true) {
      return LoadingAnimationWidget.newtonCradle(color: Colors.white, size: 50);
    }
    if (loadStat == false) {
      return const Icon(Icons.upload_file);
    }
  }
}
