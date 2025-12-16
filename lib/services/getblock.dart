import 'dart:convert';
import 'package:http/http.dart' as http;

final getblockURL = 'https://go.getblock.io/';

Future<Map<String, dynamic>> fetchFromGetBlock(String token,
  String method, List<dynamic> params) async {
  final url = '$getblockURL$token';
  final headers = {'Content-Type': 'application/json'};
  final dataRaw = {
    "jsonrpc": "2.0",
    "method": method,
    "params": params,
    "id": "getblock.io"
  };
  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: json.encode(dataRaw),
  );
  if (response.statusCode == 200) {
    return json.decode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('${response.statusCode} ${response.reasonPhrase}, ${response.body}');    
  }
}