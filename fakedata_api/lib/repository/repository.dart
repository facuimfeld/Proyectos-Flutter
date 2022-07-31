import 'package:fakedata_api/models/album.dart';
import 'package:fakedata_api/models/user.dart';
import 'package:fakedata_api/provider/api_provider.dart';

class Repository {
  final APIProvider apiProvider = APIProvider();

  Future<List<User>> getUsers() => apiProvider.getUsers();

  Future<List<Album>> getAlbums(int id) => apiProvider.getAlbums(id);
}
