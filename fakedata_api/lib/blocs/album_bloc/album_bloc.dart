import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fakedata_api/models/album.dart';
import 'package:fakedata_api/repository/repository.dart';

part 'album_event.dart';
part 'album_state.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  Repository repository;

  AlbumBloc({required this.repository}) : super(AlbumInitial()) {
    on<LoadListAlbumsRequested>((event, emit) async {
      try {
        List<Album> albums =
            await repository.apiProvider.getAlbums(event.userId);
        emit(LoadListSuccesfully(albums));
      } catch (ex) {
        emit(LoadListFailure(ex.toString()));
      }
    });
  }
}
