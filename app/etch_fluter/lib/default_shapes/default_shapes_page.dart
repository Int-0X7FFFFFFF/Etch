// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../common.dart';
import 'dart:convert';
import 'dart:io';

class DefaultShapesPage extends StatefulWidget {
  const DefaultShapesPage({super.key});

  @override
  State<DefaultShapesPage> createState() => _DefaultShapesPageState();
}

class _DefaultShapesPageState extends State<DefaultShapesPage> {
  String _selectedShape = 'square';
  @override
  Widget build(BuildContext context) {
    var server = Provider.of<API>(context).getAPI;
    return Scaffold(
      appBar: AppBar(title: const Text("Choose a default shape to draw")),
      body: Center(
        child: DropdownButton<String>(
          value: _selectedShape,
          style: Theme.of(context).textTheme.titleLarge,
          dropdownColor: Colors.white,
          focusColor: Colors.white,
          items: const[
            DropdownMenuItem(
              value: 'square',
              child: Text('Square'),
            ),
            DropdownMenuItem(
              value: 'circle',
              child: Text('Circle'),
            ),
            DropdownMenuItem(
              value: 'star',
              child: Text('Star'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedShape = value!;
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Provider.of<Load>(context, listen: false).onloading();
          try {
            var res = await server.draw_shape(_selectedShape); //need update api
            if (res['status']) {
             
            } else {
              throw Exception(res['msg']);
            }
            Provider.of<Load>(context, listen: false).outloading();
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
      return const Icon(Icons.check);
    }
  }
}
