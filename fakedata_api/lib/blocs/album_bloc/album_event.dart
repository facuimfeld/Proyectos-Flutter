part of 'album_bloc.dart';

abstract class AlbumEvent {
  const AlbumEvent();

  @override
  List<Object> get props => [];
}

class LoadListAlbumsRequested extends AlbumEvent {
  LoadListAlbumsRequested(this.userId);
  int userId;
  @override
  List<Object> get props => [userId];
}
