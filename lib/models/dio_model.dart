import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class DioModel {
  Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://10.0.2.2:7087',
    ),
  );

  DioModel(){
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client){
      client.badCertificateCallback=(cert, host, port){
        return true;
      };
    };
  }
}
