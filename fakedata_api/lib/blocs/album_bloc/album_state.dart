part of 'album_bloc.dart';

abstract class AlbumState extends Equatable {
  const AlbumState();

  @override
  List<Object> get props => [];
}

class AlbumInitial extends AlbumState {
  @override
  List<Object> get props => [];
}

class LoadListSuccesfully extends AlbumState {
  List<Album> listAlbums;
  LoadListSuccesfully(this.listAlbums);

  @override
  List<Object> get props => [listAlbums];
}

class LoadListFailure extends AlbumState {
  String errorMessage;
  LoadListFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
