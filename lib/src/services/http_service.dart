import 'dart:io';

import 'package:dio/dio.dart';

import 'package:shopme/src/constants/app_constants.dart';

enum Method { POST, GET, PUT, DELETE, PATCH }

const BASE_URL = "https://fakestoreapi.com/";

class HttpService {
  Dio? _dio;

  static header() => {"Content-Type": "application/json"};

  Future<HttpService> init() async {
    _dio = Dio(BaseOptions(baseUrl: BASE_URL, headers: header()));
    initInterceptors();
    return this;
  }

  void initInterceptors() {
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (requestOptions, handler) {
          logger.i(
              "REQUEST[${requestOptions.method}] => PATH: ${requestOptions.path}"
              "=> REQUEST VALUES: ${requestOptions.queryParameters} => HEADERS: ${requestOptions.headers}");
          return handler.next(requestOptions);
        },
        onResponse: (response, handler) {
          logger
              .i("RESPONSE[${response.statusCode}] => DATA: ${response.data}");
          return handler.next(response);
        },
        onError: (err, handler) {
          logger.i("Error[${err.response?.statusCode}]");
          return handler.next(err);
        },
      ),
    );
  }

  Future<dynamic> request(
      {required String url,
      required Method method,
      Map<String, dynamic>? params}) async {
    Response response;

    try {
      if (method == Method.POST) {
        response = await _dio!.post(url, data: params);
      } else if (method == Method.DELETE) {
        response = await _dio!.delete(url);
      } else if (method == Method.PATCH) {
        response = await _dio!.patch(url);
      } else {
        response = await _dio!.get(url, queryParameters: params);
      }

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized");
      } else if (response.statusCode == 500) {
        throw Exception("Server Error");
      } else {
        throw Exception("Something does wen't wrong");
      }
    } on SocketException catch (e) {
      logger.e(e);
      throw Exception("Not Internet Connection");
    } on FormatException catch (e) {
      logger.e(e);
      throw Exception("Bad response format");
    } on DioError catch (e) {
      logger.e(e);
      throw Exception(e);
    } catch (e) {
      logger.e(e);
      throw Exception("Something wen't wrong");
    }
  }
}
