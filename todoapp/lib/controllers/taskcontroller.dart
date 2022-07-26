import 'package:get/get_state_manager/get_state_manager.dart';

class TaskController extends GetxController {
  List<String> listTasks = [
    'Task 1',
    'Task 2',
    'Task 3',
  ];

  void addTask(String task) {
    listTasks.add(task);

    update();
  }

  void removeTask(int index) {
    listTasks.removeAt(index);
    update();
  }

  void editTask(int index, String newTask) {
    listTasks[index] = newTask;
    update();
  }
}
