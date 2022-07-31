import 'package:fakedata_api/blocs/user_bloc/user_bloc.dart';
import 'package:fakedata_api/pages/profile.dart';
import 'package:fakedata_api/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(InitialHome());

class InitialHome extends StatelessWidget {
  const InitialHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
        create: (context) => Repository(),
        child: MultiBlocProvider(providers: [
          BlocProvider(
              create: (context) => UserBloc(
                  repository: RepositoryProvider.of<Repository>(context))
                ..add(LoadListRequested()))
        ], child: Home()));
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fake Data API'),
        centerTitle: true,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is LoadListUsers) {
            return ListView.builder(
                itemCount: state.listUsers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Profile(
                                    profileData: state.listUsers[index])));
                      },
                      leading: CircleAvatar(
                          child: Text(
                              state.listUsers[index].name.substring(0, 1))),
                      title: Text(state.listUsers[index].name),
                      subtitle: Text('Email:${state.listUsers[index].email}',
                          style: const TextStyle(fontWeight: FontWeight.bold)));
                });
          }
          if (state is FailureLoadListUsers) {
            return const Center(child: Text('A error was ocurred'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is LoadListUsers) {
          return Scaffold(
            body: ListView.builder(
                itemCount: state.listUsers.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(state.listUsers[index].name));
                }),
          );
        }
        if (state is FailureLoadListUsers) {
          return const Center(child: Text('A error was ocurred'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
