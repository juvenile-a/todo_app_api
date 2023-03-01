import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'package:todo_app/models/task.dart';

const String apiPath = 'http://192.168.1.16:3000/tasks';

const String columnId = 'id';
const String columnName = 'name';
const String columnPriority = 'priority';
const String columnDeadline = 'deadline';
const String columnMemo = 'memo';
const String columnCompleted = 'completed';

const List<String> columns = [
  columnId,
  columnName,
  columnPriority,
  columnDeadline,
  columnMemo,
  columnCompleted,
];

class TaskHelper {
  static final TaskHelper instance = TaskHelper._createInstance();

  TaskHelper._createInstance();

  Future createTask(Task task) async {
    final String body = jsonEncode(task);
    http.Response response = await http.post(Uri.parse(apiPath),
        body: utf8.encode(body)); // UTF-16 → UTF-8
    statusToast(response.statusCode);
  }

  Future<Task> readTask(int id) async {
    http.Response response = await http.get(Uri.parse(apiPath + '/$id'));
    final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8 → UTF-16
    statusToast(response.statusCode);
    return Task.fromJson(jsonResponse);
  }

  Future<List<Task>> readAllTasks() async {
    http.Response response = await http.get(Uri.parse(apiPath));
    final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8 → UTF-16
    statusToast(response.statusCode);
    return jsonResponse.map<Task>((json) => Task.fromJson(json)).toList();
  }

  Future updateTask(Task task) async {
    final body = jsonEncode(task);
    http.Response response = await http.put(Uri.parse(apiPath + '/${task.id}'),
        body: utf8.encode(body));
    statusToast(response.statusCode);
  }

  Future deleteTask(int id) async {
    http.Response response = await http.delete(Uri.parse(apiPath + '/$id'));
    statusToast(response.statusCode);
  }
}

statusToast(int statusCode) {
  String msg = "";
  Color backgroundColor = Colors.green;
  switch (statusCode) {
    case 200:
      msg = '200 OK';
      break;
    case 201:
      msg = '201 CREATED';
      break;
    case 204:
      msg = '204 NO_CONTENT';
      break;
    case 404:
      msg = '404 NOT_FOUND';
      backgroundColor = Colors.redAccent;
      break;
  }
  return Fluttertoast.showToast(
    msg: msg,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 5,
    toastLength: Toast.LENGTH_SHORT,
    backgroundColor: backgroundColor,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
