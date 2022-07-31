part of 'user_bloc.dart';

@immutable
abstract class UserState extends Equatable {}

class UserInitial extends UserState {
  @override
  List<Object?> get props => [];
}

class LoadListUsers extends UserState {
  List<User> listUsers = [];
  LoadListUsers(this.listUsers);
  @override
  List<Object?> get props => [listUsers];
}

class FailureLoadListUsers extends UserState {
  String message;
  FailureLoadListUsers(this.message);
  @override
  List<Object?> get props => [message];
}
