import 'dart:convert';
import 'dart:io';

import 'package:dox_core/dox_core.dart';

class DoxRequest {
  final HttpRequest httpRequest;
  final HttpResponse httpResponse;
  Map<String, dynamic> param = {};
  Map<String, dynamic> query = {};
  final HttpHeaders headers;
  String method = 'GET';
  Uri uri;
  Map body = {};
  dynamic bodyString;
  Map<String, dynamic> _allRequest = {};
  final Map<String, dynamic> _cookies = {};

  DoxRequest(this.httpRequest, this.httpResponse, this.uri, this.headers);

  static Future<DoxRequest> httpRequestToDoxRequest(
    HttpRequest request,
    RouteData route,
  ) async {
    DoxRequest i =
        DoxRequest(request, request.response, request.uri, request.headers);
    i.param = route.params;
    i.method = route.method;
    i.query = request.uri.queryParameters;
    var bodyString = await utf8.decoder.bind(request).join();
    if (request.headers.contentType.toString().contains('json')) {
      i.body = jsonDecode(bodyString);
    }
    i.bodyString = bodyString;
    i._allRequest = {...i.query, ...i.body};
    i._getCookies();
    return i;
  }

  /// Get all request from body and query
  /// ```
  /// req.all();
  /// ```
  Map<String, dynamic> all() {
    return _allRequest;
  }

  /// Get Only specific request from body and query
  /// ```
  /// req.only(['email', 'name']);
  /// ```
  Map<String, dynamic> only(List<String> keys) {
    Map<String, dynamic> ret = {};
    for (String key in keys) {
      ret[key] = _allRequest[key];
    }
    return ret;
  }

  /// Get user IP
  /// ```
  /// req.ip();
  /// ```
  String? ip() {
    return httpRequest.connectionInfo?.remoteAddress.address ?? 'unknown';
  }

  /// Get request value
  /// ```
  /// req.input('email');
  /// ```
  String? input(key) {
    return _allRequest[key];
  }

  /// Determining If Input Is Present
  /// ```
  /// if(req.has('email')) {
  ///   /// do something
  /// }
  /// ```
  bool has(String key) {
    String val = _allRequest[key].toString();
    return val != 'null' || val.isNotEmpty ? true : false;
  }

  /// Get header value
  /// ```
  /// req.header('X-Token');
  /// ```
  String? header(key) {
    return headers.value(key);
  }

  /// Add new request value
  /// ```
  /// req.add('foo', bar);
  /// ```
  void add(key, value) {
    _allRequest[key] = value;
    body[key] = value;
  }

  /// Merge request values
  /// ```
  /// req.merge({"foo" : bar});
  /// ```
  void merge(Map<String, dynamic> values) {
    _allRequest = {..._allRequest, ...values};
    body = {...body, ...values};
  }

  /// get cookie value from header
  /// ```
  /// req.cookie('authKey');
  /// ```
  String cookie(key, {bool decode = true}) {
    if (decode) {
      return AESEncryptor.decode(_cookies[key]);
    }
    return _cookies[key];
  }

  _getCookies() {
    List<String>? cookies = httpRequest.headers[HttpHeaders.cookieHeader];
    if (cookies == null) {
      return;
    }
    for (var cookie in cookies) {
      int equalsIndex = cookie.indexOf('=');
      String name = cookie.substring(0, equalsIndex);
      String value = cookie.substring(equalsIndex + 1);
      _cookies[name] = value;
    }
  }
}
