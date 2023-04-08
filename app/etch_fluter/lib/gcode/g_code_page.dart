// ignore_for_file: use_build_context_synchronously

import 'package:etch_fluter/api.dart';
import 'package:etch_fluter/common.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class GcodePage extends StatefulWidget {
  const GcodePage({Key? key}) : super(key: key);

  @override
  State<GcodePage> createState() => _GcodePageState();
}

class _GcodePageState extends State<GcodePage> {
  final TextEditingController _GcodeInputController = TextEditingController();
  final globalKey = GlobalKey<AnimatedListState>();
  var data = <String>[];

  @override
  Widget build(BuildContext context) {
    var server = Provider.of<API>(context).getAPI;
    return Scaffold(
      floatingActionButton: floatingActionButton(server),
      appBar: AppBar(
        title: const Text("Send a Gcode"),
      ),
      body: AnimatedList(
        padding: const EdgeInsets.all(20.0),
        key: globalKey,
        initialItemCount: data.length,
        itemBuilder: (
          BuildContext context,
          int index,
          Animation<double> animation,
        ) {
          return FadeTransition(
            opacity: animation,
            child: buildItem(context, index),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
        child: TextField(
          decoration: const InputDecoration(
              labelText: "Input Gcode",
              hintText: "G 00",
              prefixIcon: Icon(Icons.code)),
          autofocus: true,
          controller: _GcodeInputController,
        ),
      )),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    String char = data[index];
    Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        key: ValueKey(char),
        title: Text(char),
      ),
    );
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.code),
        key: ValueKey(char),
        title: Text(char),
      ),
    );
  }

  Widget floatingActionButton(Server server) {
    return FloatingActionButton(
      onPressed: () async {
        Provider.of<Load>(context, listen: false).onloading();
        String input = _GcodeInputController.text;
        try {
          var res = await server.send_gcode(input);
          data.add(input);
          if (res['status']) {
            globalKey.currentState!.insertItem(data.length - 1);
            Provider.of<Load>(context, listen: false).outloading();
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
    );
  }

  getButton() {
    var loadStat = Provider.of<Load>(context).getLoading;
    if (loadStat == true) {
      return LoadingAnimationWidget.newtonCradle(color: Colors.white, size: 50);
    }
    if (loadStat == false) {
      return const Icon(Icons.send);
    }
  }
}
