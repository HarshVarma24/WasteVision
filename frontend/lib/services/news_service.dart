import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  static const String api = '834acd91de444fc093a225954f1e3b54';
  static const String baseUrl = 'https://newsapi.org/v2';

  static Future<List<Map<String, String>>> getEnvironmentalNews() async {
    try {
      final Uri url = Uri.parse(
        '$baseUrl/everything'
        '?q=environment recycling waste sustainability climate'
        '&language=en'
        '&sortBy=publishedAt'
        '&pageSize=10'
        '&apiKey=$api',
      );

      final response = await http.get(url);

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'ok') {
          List<Map<String, String>> newsList = [];

          for (var article in data['articles']) {
            newsList.add({
              'title': (article['title'] ?? '').toString(),
              'description': (article['description'] ?? '').toString(),
              'url': (article['url'] ?? '').toString(),
              'source': (article['source']['name'] ?? '').toString(),
            });
          }

          return newsList;
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
}
