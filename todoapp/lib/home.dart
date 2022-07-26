import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todoapp/controllers/taskcontroller.dart';

void main() => runApp(Home());

class Home extends StatelessWidget {
  TaskController taskController = Get.put(TaskController());
  TextEditingController task = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GetBuilder(builder: (TaskController taskController) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('TodoApp',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: taskController.listTasks.isEmpty
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('No Tasks added',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0)),
                  const SizedBox(height: 15.0),
                  ElevatedButton(
                      onPressed: () {
                        showWindowTask(context, taskController);
                      },
                      child: const Text('Add Task')),
                ],
              ))
            : ListView.builder(
                itemCount: taskController.listTasks.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(color: Colors.red),
                    direction: DismissDirection.horizontal,
                    onDismissed: (val) {
                      taskController.removeTask(index);
                    },
                    child: ListTile(
                        trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return SizedBox(
                                      height: 25.0,
                                      width: 200,
                                      child: AlertDialog(
                                        title: const Text('Edit Task'),
                                        content: Container(
                                          // ignore: sort_child_properties_last
                                          child: TextField(
                                            decoration: InputDecoration(
                                                hintText: taskController
                                                    .listTasks[index]),
                                            controller: task,
                                          ),
                                          margin: const EdgeInsets.fromLTRB(
                                              25, 10, 25, 0),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                taskController.editTask(
                                                    index, task.text);
                                                task.text = '';
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Update Task')),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            icon: const Icon(Icons.edit, color: Colors.red)),
                        leading: CircleAvatar(
                            child: Text(taskController.listTasks[index]
                                .substring(0, 1))),
                        title: Text(taskController.listTasks[index])),
                  );
                }),
        floatingActionButton: taskController.listTasks.isEmpty
            ? Container()
            : FloatingActionButton(
                onPressed: () {
                  showWindowTask(context, taskController);
                },
                child: const Icon(Icons.add, color: Colors.white)),
      );
    });
  }

  Future<dynamic> showWindowTask(
      BuildContext context, TaskController taskController) {
    return showDialog(
        context: (context),
        builder: (ctx) {
          return SizedBox(
            height: 25.0,
            width: 200,
            child: AlertDialog(
              title: const Text('Add Task'),
              content: Container(
                // ignore: sort_child_properties_last
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'New Task',
                  ),
                  controller: task,
                ),
                margin: const EdgeInsets.fromLTRB(25, 10, 25, 0),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      taskController.addTask(task.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Add Task')),
              ],
            ),
          );
        });
  }
}
