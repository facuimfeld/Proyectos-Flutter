part of 'user_bloc.dart';

@immutable
abstract class UserEvent {
  @override
  List<Object> get props => [];
}

class LoadListRequested extends UserEvent {
  @override
  List<Object> get props => [];
}
