import 'dart:convert';

import 'package:fakedata_api/models/album.dart';
import 'package:fakedata_api/models/user.dart';
import 'package:http/http.dart' as http;

class APIProvider {
  Future<List<User>> getUsers() async {
    List<User> users = [];
    var resp =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
    if (resp.statusCode == 200) {
      List<dynamic> data = json.decode(resp.body);
      for (int i = 0; i <= data.length - 1; i++) {
        Map<String, dynamic> jsonData = data[i];
        User user = User.fromJson(jsonData);
        users.add(user);
      }
    }
    return users;
  }

  Future<List<Album>> getAlbums(int id) async {
    List<Album> albums = [];
    var resp = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/albums'));
    if (resp.statusCode == 200) {
      List<dynamic> data = json.decode(resp.body);
      for (int i = 0; i <= data.length - 1; i++) {
        Map<String, dynamic> jsonData = data[i];
        if (jsonData["userId"] == id) {
          Album album = Album.fromJson(jsonData);
          albums.add(album);
        }
      }
    }
    return albums;
  }
}
