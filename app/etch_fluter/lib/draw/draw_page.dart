import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
            XFile? img =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            // Load an image from file
            File imageFile = File(img!.path);
            List<int> imageBytes = await imageFile.readAsBytes();
            // Convert the image bytes to base64
            String base64Image = base64Encode(imageBytes);
            var data = await server.get_image(base64Image);
            if (data['status']) {
              print(data['img']);
            } else {
              throw Exception(data['msg']);
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
      return const Icon(Icons.cloud_sync);
    }
  }
}
