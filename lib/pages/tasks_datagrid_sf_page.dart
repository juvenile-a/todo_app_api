import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import 'package:todo_app/models/task.dart';
import 'package:todo_app/database/task_helper_db.dart';

import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class TasksGridviewSfPage extends StatefulWidget {
  const TasksGridviewSfPage(
      {Key? key, required this.tasks, required this.callback})
      : super(key: key);
  final List<Task> tasks;
  final Function callback;

  @override
  State<TasksGridviewSfPage> createState() => _TasksGridviewPageState();
}

class _TasksGridviewPageState extends State<TasksGridviewSfPage> {
  late TaskDataSource _taskDataSource;
  final CustomColumnSizer _customColumnSizer = CustomColumnSizer();

  @override
  void initState() {
    super.initState();
    _taskDataSource =
        TaskDataSource(tasks: widget.tasks, callback: widget.callback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DataGrid Syncfusion')),
      body: SfDataGridTheme(
        data: SfDataGridThemeData(
          sortIconColor: Colors.white60,
          headerColor: Colors.indigo[400],
          selectionColor: Colors.yellowAccent[100],
          gridLineColor: Colors.grey[400],
        ),
        child: SfDataGrid(
          source: _taskDataSource,
          headerRowHeight: 40,
          rowHeight: 40,
          //showCheckboxColumn: true,
          checkboxColumnSettings: const DataGridCheckboxColumnSettings(
            showCheckboxOnHeader: false,
            backgroundColor: Colors.black12,
          ),
          //selectionMode: SelectionMode.multiple,
          allowEditing: true,
          selectionMode: SelectionMode.single,
          navigationMode: GridNavigationMode.cell,
          //editingGestureType: EditingGestureType.tap,
          columnWidthMode: ColumnWidthMode.auto,
          columnSizer: _customColumnSizer,
          //columnWidthMode: ColumnWidthMode.fitByCellValue,
          gridLinesVisibility: GridLinesVisibility.both,
          headerGridLinesVisibility: GridLinesVisibility.both,
          allowSorting: true,
          allowMultiColumnSorting: true,
          allowTriStateSorting: true,
          showSortNumbers: true,
          //allowColumnsResizing: true,
          allowPullToRefresh: true,
          /*onQueryRowHeight: (details) {
            return details.getIntrinsicRowHeight(details.rowIndex);
          },*/
          columns: [
            _gridColum(columnName: 'id', labelText: 'ID', allowEditing: false),
            _gridColum(columnName: 'name', labelText: 'Name'),
            _gridColum(columnName: 'memo', labelText: 'Memo'),
            _gridColum(columnName: 'deadline', labelText: 'Deadline'),
            _gridColum(columnName: 'priority', labelText: 'Priority'),
            _gridColum(columnName: 'completed', labelText: 'Completed')
          ],
        ),
      ),
    );
  }

  GridColumn _gridColum(
      {required String columnName,
      required String labelText,
      bool allowEditing = true}) {
    return GridColumn(
        columnName: columnName,
        allowEditing: allowEditing,
        label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerRight,
            child: Text(
              labelText,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            )));
  }
}

class CustomColumnSizer extends ColumnSizer {
  @override
  double computeCellWidth(GridColumn column, DataGridRow row, Object? cellValue,
      TextStyle textStyle) {
    if (column.columnName == 'deadline') {
      cellValue = DateFormat('yyyy/MM/dd').format(cellValue as DateTime);
    }
    return super.computeCellWidth(column, row, cellValue, textStyle);
  }
}

class TaskDataSource extends DataGridSource {
  TaskDataSource(
      {Key? key, required List<Task> tasks, required this.callback}) {
    dataGridRows = tasks
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: dataGridRow.id),
              DataGridCell<String>(columnName: 'name', value: dataGridRow.name),
              DataGridCell<String>(columnName: 'memo', value: dataGridRow.memo),
              DataGridCell<DateTime>(
                  columnName: 'deadline', value: dataGridRow.deadline),
              DataGridCell<int>(
                  columnName: 'priority', value: dataGridRow.priority),
              DataGridCell<int>(
                  columnName: 'completed', value: dataGridRow.completed),
            ]))
        .toList();
  }
  //List<DataGridRow> dataGridRows = [];
  late List<DataGridRow> dataGridRows;
  late Task task;
  final Function callback;

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      final int index = effectiveRows.indexOf(row);
      late String cellValue;
      if (dataGridCell.columnName == 'deadline') {
        cellValue = DateFormat('yyyy/MM/dd').format(dataGridCell.value);
      } else {
        cellValue = dataGridCell.value.toString();
      }
      return Container(
          color: (index % 2 != 0)
              ? Colors.indigo.withOpacity(0.15)
              : Colors.indigo.withOpacity(0.05),
          alignment: (dataGridCell.columnName == 'id' ||
                  dataGridCell.columnName == 'priority' ||
                  dataGridCell.columnName == 'completed')
              ? Alignment.centerRight
              : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            cellValue,
            overflow: TextOverflow.ellipsis,
            style: (dataGridCell.columnName != 'priority')
                ? null
                : TextStyle(
                    color: _getPriorityColor(priority: cellValue),
                    shadows: const [
                        Shadow(blurRadius: 1.0, color: Colors.black)
                      ]),
          ));
    }).toList());
  }

  Color _getPriorityColor({
    required String priority,
  }) {
    Color color = Colors.white;
    switch (priority) {
      case '1':
        color = Colors.blue;
        break;
      case '2':
        color = Colors.green;
        break;
      case '3':
        color = Colors.orange;
        break;
      case '4':
        color = Colors.red;
        break;
      case '5':
        color = Colors.purple;
        break;
    }
    return color;
  }

  dynamic newCellValue;
  TextEditingController editingController = TextEditingController();

  @override
  void onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex,
      GridColumn column) {
    final dynamic oldValue = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value ??
        '';
    /*
    if (column.columnName == 'memo') {
      newCellValue ??= '';
    } else if (newCellValue == null) {
      return;
    }
    */
    if (newCellValue == null || oldValue == newCellValue) {
      return;
    }

    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);

    if (column.columnName == 'id') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<int>(columnName: 'id', value: newCellValue);
    } else if (column.columnName == 'name') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'name', value: newCellValue);
    } else if (column.columnName == 'memo') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'memo', value: newCellValue);
    } else if (column.columnName == 'deadline') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<DateTime>(columnName: 'deadline', value: newCellValue);
    } else if (column.columnName == 'priority') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<int>(columnName: 'priority', value: newCellValue);
    } else {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<int>(columnName: 'completed', value: newCellValue);
    }

    task = Task(
      id: dataGridRows[dataRowIndex].getCells()[0].value,
      name: dataGridRows[dataRowIndex].getCells()[1].value,
      memo: dataGridRows[dataRowIndex].getCells()[2].value,
      deadline: dataGridRows[dataRowIndex].getCells()[3].value,
      priority: dataGridRows[dataRowIndex].getCells()[4].value,
      completed: dataGridRows[dataRowIndex].getCells()[5].value,
    );
    TaskHelper.instance.updateTask(task);
    callback();
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    final String displayText = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value
            ?.toString() ??
        '';
    newCellValue = null;

    if (column.columnName == 'deadline') {
      return _buildDateTimePicker(displayText, submitCell);
    } else if (column.columnName == 'priority') {
      return _buildDropDownWidget(displayText, submitCell, priorityDropDown);
    } else if (column.columnName == 'completed') {
      return _buildDropDownWidget(displayText, submitCell, completedDropDown);
    } else {
      return _buildTextFieldWidget(displayText, column, submitCell);
    }

    /*
    final bool isNumericType =
        column.columnName == 'priority' || column.columnName == 'completed';

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: isNumericType ? Alignment.centerRight : Alignment.centerLeft,
      child: TextField(
        autofocus: true,
        controller: editingController..text = displayText,
        textAlign: isNumericType ? TextAlign.right : TextAlign.left,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 16.0),
        ),
        keyboardType: isNumericType ? TextInputType.number : TextInputType.text,
        onChanged: (String value) {
          if (value.isNotEmpty) {
            if (isNumericType) {
              newCellValue = int.parse(value);
            } else {
              newCellValue = value;
            }
          } else {
            newCellValue = null;
          }
        },
        onSubmitted: (String value) => submitCell(),
      ),
    );
    */
  }

  bool isDatePickerVisible = false;

  Widget _buildDateTimePicker(String displayText, CellSubmit submitCell) {
    final DateTime selectedDate = DateTime.parse(displayText);
    final DateTime firstDate =
        DateTime.now().add(const Duration(days: 365) * -1);
    final DateTime lastDate = DateTime.now().add(const Duration(days: 365) * 3);

    displayText = DateFormat('yyyy/MM/dd').format(DateTime.parse(displayText));
    return Builder(
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Focus(
            autofocus: true,
            focusNode: FocusNode()
              ..addListener(() async {
                if (!isDatePickerVisible) {
                  isDatePickerVisible = true;
                  await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: firstDate,
                    lastDate: lastDate,
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light().copyWith(
                            primary: Colors.red,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  ).then((DateTime? value) {
                    newCellValue = value;
                    submitCell();
                    isDatePickerVisible = false;
                  });
                }
              }),
            child: Text(
              displayText,
              textAlign: TextAlign.right,
              //style: textStyle,
            ),
          ),
        );
      },
    );
  }

  RegExp _getRegExp(bool isNumericKeyBoard, String columnName) {
    return isNumericKeyBoard
        ? columnName == 'Price'
            ? RegExp('[0-9.]')
            : RegExp('[0-9]')
        : RegExp('[a-zA-Z ]');
  }

  /// Building a [TextField] for numeric and text column.
  Widget _buildTextFieldWidget(
      String displayText, GridColumn column, CellSubmit submitCell) {
    final bool isNumericKeyBoardType =
        column.columnName == 'Product No' || column.columnName == 'Price';

    // Holds regular expression pattern based on the column type.
    final RegExp regExp = _getRegExp(isNumericKeyBoardType, column.columnName);

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: TextField(
        autofocus: true,
        controller: editingController..text = displayText,
        textAlign: TextAlign.left,
        autocorrect: false,
        //keyboardAppearance: sampleModel.themeData.colorScheme.brightness,
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 14.0),
            focusedBorder: UnderlineInputBorder(
                //borderSide: BorderSide(color: sampleModel.backgroundColor),
                )),
        //style: textStyle,
        //cursorColor: sampleModel.backgroundColor,
        //inputFormatters: <TextInputFormatter>[
        //  FilteringTextInputFormatter.allow(regExp)
        //],
        keyboardType: TextInputType.text,
        onChanged: (String value) {
          if (value.isNotEmpty) {
            newCellValue = value;
          } else {
            newCellValue = null;
          }
        },
        onSubmitted: (String value) {
          /// Call [CellSubmit] callback to fire the canSubmitCell and
          /// onCellSubmit to commit the new value in single place.
          submitCell();
        },
      ),
    );
  }

  final List<int> priorityDropDown = List.generate(5, (i) => i + 1);
  final List<int> completedDropDown = List.generate(2, (i) => i);

  Widget _buildDropDownWidget(
      String displayText, CellSubmit submitCell, List<int> dropDownMenuItems) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: DropdownButton<int>(
          value: int.parse(displayText),
          autofocus: true,
          focusColor: Colors.transparent,
          underline: const SizedBox.shrink(),
          icon: const Icon(Icons.arrow_drop_down_sharp),
          isExpanded: true,
          //style: textStyle,
          onChanged: (int? value) {
            newCellValue = value;

            /// Call [CellSubmit] callback to fire the canSubmitCell and
            /// onCellSubmit to commit the new value in single place.
            submitCell();
          },
          items: dropDownMenuItems.map<DropdownMenuItem<int>>((value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(value.toString()),
            );
          }).toList()),
    );
  }
}
