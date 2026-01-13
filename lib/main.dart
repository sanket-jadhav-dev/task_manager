import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/bloc/task_bloc.dart';
import 'package:task_manager/bloc/task_event.dart';
import 'package:task_manager/core/storage/local_storage.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/presentation/screens/login_screen.dart';
import 'package:task_manager/presentation/screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapter
  Hive.registerAdapter(TaskModelAdapter());

  // Open boxes
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox('app_data');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const LoginScreen(),
      routes: {
        '/tasks': (context) => BlocProvider(
          create: (context) => TaskBloc(
            taskRepository: TaskRepository(
              localStorage: LocalStorage(),
            ),
          )..add(LoadTasks()),
          child: const TaskListScreen(),
        ),
      },
    );
  }
}