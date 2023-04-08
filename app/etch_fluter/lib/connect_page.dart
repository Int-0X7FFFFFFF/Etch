// ignore_for_file: use_build_context_synchronously

import 'package:etch_fluter/common.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'api.dart';

final TextEditingController _serverAddresController = TextEditingController();

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  @override
  Widget build(BuildContext context) {
    _serverAddresController.text = '127.0.0.1:9333';
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect to server"),
      ),
      body: connectBody(),
      floatingActionButton: floatingActionButton(),
    );
  }

  floatingActionButton() {
    var button = FloatingActionButton(
      onPressed: () async {
        var input = _serverAddresController.text;
        Provider.of<Load>(context, listen: false).onloading();
        onButtonPressed(input);
      },
      child: getButton(),
    );
    return button;
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

  onButtonPressed(String input) async {
    try {
      Server server = Server(api: input);
      var data = await server.is_server_online();
      Provider.of<API>(context, listen: false).ini(server);
      Provider.of<Load>(context, listen: false).outloading();
      if (data['status']) {
        var data = await server.get_devices();
        if (data['status']) {
          Navigator.pushNamed(context, '/dev', arguments: {'data': data});
        } else {
          throw Exception(data['msg']);
        }
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
  }

  connectBody() {
    var view = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: TextField(
        decoration: const InputDecoration(
            labelText: "Server addres with port",
            hintText: "127.0.0.1:5000",
            prefixIcon: Icon(Icons.cloud)),
        autofocus: true,
        controller: _serverAddresController,
      ),
    );
    return view;
  }
}
