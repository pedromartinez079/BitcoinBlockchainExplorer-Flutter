import 'package:http/http.dart' as http;

final baseURL = 'https://blockchain.info/';

Future<Map<String, dynamic>> fetchFromBlockchainInfo(String url) async {
  final headers = {'Content-Type': 'application/json'};
  final response = await http.get(
    Uri.parse('$baseURL$url'),
    headers: headers,
  );
  if (response.statusCode == 200) {
    return {'data' : response.body} as Map<String, dynamic>;
  } else {
    throw Exception('${response.statusCode} ${response.reasonPhrase} ${response.body}');    
  }
}

Future<Map<String, dynamic>> fetchFromURL(String url) async {
  final headers = {'Content-Type': 'application/json'};
  final response = await http.get(
    Uri.parse(url),
    headers: headers,
  );
  if (response.statusCode == 200) {
    return {'data' : response.body} as Map<String, dynamic>;
  } else {
    throw Exception('${response.statusCode} ${response.reasonPhrase} ${response.body}');    
  }
}