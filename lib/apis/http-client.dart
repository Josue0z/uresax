import 'dart:io';
import 'package:dio/dio.dart';

final httpClient = Dio(BaseOptions(baseUrl: 'http://${Platform.environment['URESAX_HOSTNAME']}:8080',headers:{
   'Content-Type':'application/json',
   'Accept':'application/json',
   'user-token':'CURRENT_USER_TOKEN'
}));


