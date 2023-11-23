import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'square_tile.dart';

Future<Map> fetchMarvelCharacters() async {
  const publicKey = 'a2a42f0cc38672182797084d10a452f9';
  const privateKey = '905bec3ea0c018344fa4c5b7e3868d994413ce40';
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final hash =
      md5.convert(utf8.encode(timestamp + privateKey + publicKey)).toString();

      print(                'https://gateway.marvel.com:443/v1/public/comics?ts=$timestamp&apikey=$publicKey&hash=$hash');

  final response = await http.get(
    Uri.parse(
        'https://gateway.marvel.com:443/v1/public/comics?ts=$timestamp&apikey=$publicKey&hash=$hash'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load comics');
  }
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Marvel Comics')),
        body: FutureBuilder<Map>(
          future: fetchMarvelCharacters(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data?['data']['results'].length,
                itemBuilder: (context, index) {
                  var comic = snapshot.data?['data']['results'][index];
                  return SquareTile(
                    name: comic['title'],
                    description: comic['description'],
                    imagePath: '${comic['thumbnail']['path']}.jpg', 
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
