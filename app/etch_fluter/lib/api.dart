// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';

class Server {
  final String api;

  Server({required this.api});

  Future is_server_online() async {
    var dio = Dio();
    Response response;
    String API = "http://$api/";
    response = await dio.get(API, queryParameters: {});
    return response.data;
  }

  Future get_devices() async {
    var dio = Dio();
    Response response;
    String API = "http://$api/devices";
    response = await dio.get(API, queryParameters: {});
    return response.data;
  }

  Future connect_device(String dev) async {
    var dio = Dio();
    Response response;
    String API = "http://$api/connect";
    response = await dio.get(API, queryParameters: {'device': dev});
    return response.data;
  }

  Future send_gcode(String gCode) async {
    var dio = Dio();
    Response response;
    String API = "http://$api/api/gcode";
    response = await dio.get(API, queryParameters: {'code': gCode});
    return response.data;
  }

  Future get_image(String imgB64) async {
    var dio = Dio();
    Response response;
    String API = "http://$api/api/image/upload";
    response = await dio.get(API, queryParameters: {'img': imgB64});
    return response.data;
  }

  Future etch_start() async {
    var dio = Dio();
    Response response;
    String API = "http://$api/api/start";
    response = await dio.get(API, queryParameters: {});
    return response.data;
  }

  Future post_image(String imgB64) async {
    var dio = Dio();
    Response response;
    String API = "http://$api/api/image/post";
    response = await dio.post(API, data: FormData.fromMap({'img': imgB64}));
    return response.data;
  }
}
