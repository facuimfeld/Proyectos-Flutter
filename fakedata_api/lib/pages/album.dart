// ignore_for_file: sort_child_properties_last

import 'package:animate_do/animate_do.dart';
import 'package:fakedata_api/blocs/album_bloc/album_bloc.dart';
import 'package:fakedata_api/blocs/user_bloc/user_bloc.dart';
import 'package:fakedata_api/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

int? userId;
void main() => runApp(InitialAlbum(
      userId: userId,
    ));

class InitialAlbum extends StatelessWidget {
  int? userId;
  InitialAlbum({this.userId});
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
        create: (context) => Repository(),
        child: BlocProvider(
          create: (context) => AlbumBloc(
            repository: RepositoryProvider.of<Repository>(context),
          )..add(LoadListAlbumsRequested(userId!)),
          child: Album(),
        ));
  }
}

class Album extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      duration: Duration(milliseconds: 700),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text('Albums'),
        ),
        body: BlocBuilder<AlbumBloc, AlbumState>(
          builder: (context, state) {
            if (state is LoadListSuccesfully) {
              return ListView.builder(
                  itemCount: state.listAlbums.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.red,
                      ),
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        children: [
                          Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15)),
                                  color: Colors.blue,
                                ),
                              ),
                              flex: 2),
                          Expanded(
                              child: Container(
                                  color: Colors.white,
                                  child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 15, 0, 0),
                                      alignment: Alignment.topCenter,
                                      child: Text(state.listAlbums[index].title,
                                          style: const TextStyle(
                                              fontSize: 20.0))))),
                        ],
                      ),
                      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    );
                  });
            }
            if (state is LoadListFailure) {
              return const Center(child: Text('A error was ocurred'));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
