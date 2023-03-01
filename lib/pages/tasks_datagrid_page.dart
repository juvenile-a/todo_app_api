import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/database/task_helper_db.dart';

class TasksGridviewPage extends StatefulWidget {
  const TasksGridviewPage(
      {Key? key, required this.tasks, required this.callback})
      : super(key: key);
  final List<Task> tasks;
  final Function callback;
  @override
  State<TasksGridviewPage> createState() => _TasksGridviewPageState();
}

class _TasksGridviewPageState extends State<TasksGridviewPage> {
  late Task task;

  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'Id',
      field: 'id',
      type: PlutoColumnType.number(),
      width: PlutoGridSettings.minColumnWidth,
      readOnly: true,
    ),
    PlutoColumn(
      title: 'Name',
      field: 'name',
      type: PlutoColumnType.text(),
      width: PlutoGridSettings.minColumnWidth,
    ),
    PlutoColumn(
      title: 'Memo',
      field: 'memo',
      type: PlutoColumnType.text(),
      width: PlutoGridSettings.minColumnWidth,
    ),
    PlutoColumn(
      title: 'Deadline',
      field: 'deadline',
      type: PlutoColumnType.date(),
      width: PlutoGridSettings.minColumnWidth,
    ),
    PlutoColumn(
      title: 'Priority',
      field: 'priority',
      type: PlutoColumnType.select(<int>[1, 2, 3, 4, 5]),
      width: PlutoGridSettings.minColumnWidth,
    ),
    PlutoColumn(
      title: 'Completed',
      field: 'completed',
      type: PlutoColumnType.select(<int>[0, 1]),
      width: PlutoGridSettings.minColumnWidth,
    ),
  ];

  /// columnGroups that can group columns can be omitted.
  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(title: 'Id', fields: ['id'], expandedColumn: true),
    PlutoColumnGroup(title: 'Name', fields: ['name'], expandedColumn: true),
    PlutoColumnGroup(title: 'Memo', fields: ['memo'], expandedColumn: true),
    PlutoColumnGroup(
        title: 'Deadline', fields: ['deadline'], expandedColumn: true),
    PlutoColumnGroup(title: 'Status', fields: ['priority', 'completed']),
  ];

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late final PlutoGridStateManager stateManager;

  @override
  Widget build(BuildContext context) {
    List<PlutoRow> rows = [];
    for (int i = 0; i < widget.tasks.length; i++) {
      rows.add(
        PlutoRow(
          cells: {
            'id': PlutoCell(value: widget.tasks[i].id),
            'name': PlutoCell(value: widget.tasks[i].name),
            'memo': PlutoCell(value: widget.tasks[i].memo),
            'deadline': PlutoCell(value: widget.tasks[i].deadline),
            'priority': PlutoCell(value: widget.tasks[i].priority),
            'completed': PlutoCell(value: widget.tasks[i].completed),
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo List DataGrid '),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          mode: PlutoGridMode.popup,
          columnGroups: columnGroups,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
          },
          onChanged: (PlutoGridOnChangedEvent event) {
            task = widget.tasks[event.rowIdx];
            task.id = event.row.cells[columns[0].field]!.value;
            task.name = event.row.cells[columns[1].field]!.value;
            task.memo = event.row.cells[columns[2].field]!.value;
            task.deadline =
                DateTime.parse(event.row.cells[columns[3].field]!.value);
            task.priority = event.row.cells[columns[4].field]!.value;
            task.completed = event.row.cells[columns[5].field]!.value;
            TaskHelper.instance.updateTask(task);
            widget.callback();
          },
          configuration: const PlutoGridConfiguration(),
        ),
      ),
    );
  }
}
