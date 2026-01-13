import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:task_manager/bloc/task_bloc.dart';
import 'package:task_manager/bloc/task_event.dart';
import 'package:task_manager/bloc/task_state.dart';
import 'package:task_manager/presentation/widgets/task_tile.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final RefreshController _refreshController = RefreshController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _addTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.dispose();
    _addTaskController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<TaskBloc>().add(SearchTasks(query: _searchController.text));
  }

  void _onRefresh() async {
    context.read<TaskBloc>().add(LoadTasks());
    _refreshController.refreshCompleted();
  }

  void _addTask() {
    if (_addTaskController.text.isNotEmpty) {
      context.read<TaskBloc>().add(
        AddTask(title: _addTaskController.text),
      );
      _addTaskController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: TextField(
          controller: _addTaskController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter task title',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _addTask(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addTask,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              return Row(
                children: [
                  if (state.hasPendingSync)
                    const Icon(
                      Icons.sync_problem,
                      color: Colors.orange,
                      size: 20,
                    ),
                  IconButton(
                    icon: Icon(
                      state.isOnline ? Icons.wifi : Icons.wifi_off,
                      color: state.isOnline ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {},
                    tooltip: state.isOnline ? 'Online' : 'Offline',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    return IconButton(
                      onPressed: state.status == TaskStatus.loading
                          ? null
                          : () => context.read<TaskBloc>().add(LoadTasks()),
                      icon: state.status == TaskStatus.loading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    );
                  },
                ),
              ],
            ),
          ),
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state.status == TaskStatus.loading &&
                  state.tasks.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state.filteredTasks.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          state.searchQuery.isEmpty
                              ? Icons.task_outlined
                              : Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.searchQuery.isEmpty
                              ? 'No tasks yet'
                              : 'No tasks found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (state.searchQuery.isEmpty)
                          TextButton(
                            onPressed: _showAddTaskDialog,
                            child: const Text('Add your first task'),
                          ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  header: const WaterDropHeader(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: state.filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = state.filteredTasks[index];
                      return TaskTile(
                        task: task,
                        onToggleComplete: (completed) {
                          context.read<TaskBloc>().add(
                            ToggleTaskCompletion(
                              task: task,
                              completed: completed,
                            ),
                          );
                        },
                        onDelete: () {
                          context.read<TaskBloc>().add(
                            DeleteTask(id: task.id),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}