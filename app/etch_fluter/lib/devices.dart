// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import 'common.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    var server = Provider.of<API>(context).getAPI;
    var devices = arguments['data']['devices'];
    List<String> dev = [];
    for (var i in devices) {
      dev.add(i.toString());
    }
    String dropdownvalue = dev[0];

    return Scaffold(
      appBar: AppBar(title: const Text("Select a device")),
      body: Center(
        child: DropdownButton(
          value: dropdownvalue,
          style: Theme.of(context).textTheme.titleLarge,
          items: dev.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(items),
            );
          }).toList(),
          onChanged: ((value) {
            setState(() {
              dropdownvalue = value!;
            });
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Provider.of<Load>(context, listen: false).onloading();
          try {
            var res = await server.connect_device(dropdownvalue);
            if (res['status']) {
              Navigator.pushNamed(context, '/home');
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
      ),
    );
  }

  getButton() {
    var loadStat = Provider.of<Load>(context).getLoading;
    if (loadStat == true) {
      return LoadingAnimationWidget.newtonCradle(color: Colors.white, size: 50);
    }
    if (loadStat == false) {
      return const Icon(Icons.arrow_forward_ios);
    }
  }
}
