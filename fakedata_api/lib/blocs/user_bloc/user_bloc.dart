import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fakedata_api/models/user.dart';
import 'package:fakedata_api/repository/repository.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  Repository repository;
  UserBloc({required this.repository}) : super(UserInitial()) {
    on<LoadListRequested>((event, emit) async {
      emit(UserInitial());
      try {
        List<User> users = await repository.apiProvider.getUsers();
        print(users.toString());
        emit(LoadListUsers(users));
      } catch (ex) {
        FailureLoadListUsers(ex.toString());
      }
    });
  }
}
