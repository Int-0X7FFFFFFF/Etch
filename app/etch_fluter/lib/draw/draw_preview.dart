// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../common.dart';

class PrviewPage extends StatefulWidget {
  const PrviewPage({super.key});

  @override
  State<PrviewPage> createState() => _PrviewPageState();
}

class _PrviewPageState extends State<PrviewPage> {
  @override
  Widget build(BuildContext context) {
    var server = Provider.of<API>(context).getAPI;
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    String b64Img = arguments['img'];
    String b64Output = arguments['output'];
    return Scaffold(
        appBar: AppBar(
          title: const Text('PreView of etch draw'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Provider.of<Load>(context, listen: false).onloading();
            try {
              var data = await server.etch_start();
              if (data['status']) {
                Provider.of<Load>(context, listen: false).outloading();
                Provider.of<Load>(context, listen: false).outloading();
                final snackBar = SnackBar(
                  content: Text(data['msg']),
                  action: SnackBarAction(
                    label: 'OK',
                    onPressed: () {},
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.pop(context);
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
        body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Text("Seclect image"),
                      Image.memory(
                        base64Decode(b64Img),
                        fit: BoxFit
                            .contain, // Set fit property to control image size
                        width: 500, // Set maximum width for the image
                        height: 500,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('expect image'),
                      Image.memory(
                        base64Decode(b64Output),
                        fit: BoxFit
                            .contain, // Set fit property to control image size
                        width: 500, // Set maximum width for the image
                        height: 500,
                      )
                    ],
                  )
                ],
              ),
            )));
  }

  getButton() {
    var loadStat = Provider.of<Load>(context).getLoading;
    if (loadStat == true) {
      return LoadingAnimationWidget.newtonCradle(color: Colors.white, size: 50);
    }
    if (loadStat == false) {
      return const Icon(Icons.draw);
    }
  }
}
