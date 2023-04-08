import 'package:flutter/material.dart';
import 'api.dart';

class Load extends ChangeNotifier {
  bool loading = false;

  void onloading() {
    loading = true;
    notifyListeners();
  }

  void outloading() {
    loading = false;
    notifyListeners();
  }

  bool get getLoading => loading;
}

class API extends ChangeNotifier {
  bool init = false;
  Server server = Server(api: "127.0.0.1:9333");

  void ini(Server server) {
    init = true;
    this.server = server;
    notifyListeners();
  }

  Server get getAPI => server;
  bool get getinit => init;
}
