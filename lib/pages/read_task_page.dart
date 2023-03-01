import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:todo_app/database/task_helper_db.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/pages/edit_task_page.dart';

class ReadTaskPage extends StatefulWidget {
  final int taskId;

  const ReadTaskPage({
    Key? key,
    required this.taskId,
  }) : super(key: key);

  @override
  _ReadTaskPageState createState() => _ReadTaskPageState();
}

class _ReadTaskPageState extends State<ReadTaskPage> {
  late Task task;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadTask();
  }

  Future loadTask() async {
    setState(() => isLoading = true);
    task = await TaskHelper.instance.readTask(widget.taskId);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.edit,
              //color: Colors.white,
            ),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditTaskPage(
                    task: task,
                  ),
                ),
              );
              loadTask();
            },
            tooltip: '編集',
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
            ),
            onPressed: isLoading
                ? null
                : (task.completed == 0)
                    ? null
                    : () {
                        showDialog<void>(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => _showDialog(context),
                        );
                      },
            tooltip: 'タスク消去',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Scrollbar(
              thumbVisibility: true,
              thickness: 8,
              //hoverThickness: 16,
              radius: const Radius.circular(16),
              child: SizedBox(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                '${task.priority}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Text(
                                task.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: const Text('  期限'),
                        color: Colors.grey[300],
                        height: 22,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                      ),
                      Container(
                        child: Text(
                          DateFormat('yyyy/MM/dd E')
                              .format(task.deadline), //yyyy/MM/dd HH:mm
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        padding: const EdgeInsets.all(5.0),
                      ),
                      Container(
                        child: const Text('  進捗'),
                        color: Colors.grey[300],
                        height: 22,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          (task.completed == 0) ? '未完了' : '完了',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          //maxLines: 5,
                        ),
                      ),
                      Container(
                        child: const Text('  メモ'),
                        color: Colors.grey[300],
                        height: 22,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          task.memo,
                          //maxLines: 5,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _showDialog(context) {
    const _buttonSize = 32.0;
    final _dialogWidth = MediaQuery.of(context).size.width * 3 / 4;
    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: _dialogWidth,
        height: _dialogWidth * 3 / 4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                  width: constraints.maxWidth - _buttonSize * 3 / 4,
                  height: constraints.maxHeight - _buttonSize * 3 / 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const Text(
                        '確認',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                        child: Center(
                          child: Text(
                            'タスクを消去しますか？',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                        ),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () async {
                          await TaskHelper.instance.deleteTask(widget.taskId);
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.topRight,
              child: closeButton(
                context,
                _buttonSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget closeButton(
    BuildContext context,
    double buttonSize,
  ) {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: FloatingActionButton(
        child: Container(
          child: Icon(
            Icons.clear,
            size: buttonSize,
            color: Colors.white,
          ),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
