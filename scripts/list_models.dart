import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'AIzaSyCv5HFQzjcVFLxlqh06ocgYvSK5_cYyerg';
  final url = 'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));
    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
