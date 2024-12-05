import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/State.dart';
import 'package:frontend/main.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class requests {
  static Future<void> sendLinks(
      List<String> urls, String title, BuildContext context) async {
    // Design Color Palette
    const Color _backgroundDark = Color(0xFF0A0A1A);
    const Color _softGreen = Color(0xFF00FF6C);

    try {
      var response =
          await http.post(Uri.parse("http://192.168.2.6:5000/generate_feed"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "urls": urls,
                "title": title // Use the actual title parameter
              }));

      final responseBody = jsonDecode(response.body);

      if (responseBody["msg"] == true) {
        // Null-safe access to feed_url
        final feedUrl = responseBody["feed_url"];
        if (feedUrl != null) {
          context.read<appbloc>().changeLink(feedUrl);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'RSS Feeds Synchronized!',
                style:
                    TextStyle(color: _softGreen, fontWeight: FontWeight.bold),
              ),
              backgroundColor: _backgroundDark,
            ),
          );
        }
      } else {
        // Handle case where message is false
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to synchronize RSS Feeds',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            backgroundColor: _backgroundDark,
          ),
        );
      }
    } catch (e) {
      print(e);
      // Handle network or parsing errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          backgroundColor: _backgroundDark,
        ),
      );
    }
  }
}
