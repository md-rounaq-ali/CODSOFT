import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'todo.dart';
import 'todo_service.dart';

class HomeScreen extends StatefulWidget {
  final TodoService todoService;

  const HomeScreen({
    super.key,
    required this.todoService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filterStatus = 'All'; // All, Active, Completed

  void _showTaskEditorSheet({TodoTask? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return TaskEditorSheet(
          todoService: widget.todoService,
          task: task,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern off-white background
      body: AnimatedBuilder(
        animation: widget.todoService,
        builder: (context, child) {
          final allTasks = widget.todoService.tasks;
          final filteredTasks = allTasks.where((t) {
            if (_filterStatus == 'Active') return !t.isCompleted;
            if (_filterStatus == 'Completed') return t.isCompleted;
            return true;
          }).toList();

          // Sort tasks: Incomplete high-priority first, then completed last
          filteredTasks.sort((a, b) {
            if (a.isCompleted != b.isCompleted) {
              return a.isCompleted ? 1 : -1;
            }
            return b.priority.index.compareTo(a.priority.index);
          });

          final activeCount = allTasks.where((t) => !t.isCompleted).length;

          return Column(
            children: [
              // ── PREMIUM GRADIENT HEADER ──
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF0D9488)], // Elegant Teal gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'My Tasks',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activeCount == 0
                                      ? 'All tasks completed!'
                                      : '$activeCount tasks remaining',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Productivity stats badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Focus On',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── FILTER TABS ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Row(
                  children: ['All', 'Active', 'Completed'].map((status) {
                    final isSelected = _filterStatus == status;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _filterStatus = status);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF0F766E).withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            status,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── TASK LIST ──
              Expanded(
                child: filteredTasks.isEmpty
                    ? _emptyTasksState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return _taskListItem(task);
                        },
                      ),
              ),

              // ── ADD TASK FAB ──
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 12),
                child: FloatingActionButton.extended(
                  onPressed: () => _showTaskEditorSheet(),
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  icon: const Icon(Icons.add_task_rounded, size: 22),
                  label: const Text(
                    'Add New Task',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyTasksState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_turned_in_rounded,
              color: Color(0xFF94A3B8),
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _filterStatus == 'Completed'
                ? 'No completed tasks yet'
                : 'No tasks configured',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _filterStatus == 'Completed'
                ? 'Check off tasks to complete them.'
                : 'Tap add below to create tasks.',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskListItem(TodoTask task) {
    Color priorityColor;
    String priorityText;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = const Color(0xFFEF4444); // Red
        priorityText = 'High';
        break;
      case TaskPriority.medium:
        priorityColor = const Color(0xFFF59E0B); // Amber
        priorityText = 'Medium';
        break;
      case TaskPriority.low:
        priorityColor = const Color(0xFF3B82F6); // Blue
        priorityText = 'Low';
        break;
    }

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        widget.todoService.deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${task.title}" deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Checkbox Circle trigger
              GestureDetector(
                onTap: () {
                  widget.todoService.toggleTaskStatus(task.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: task.isCompleted ? const Color(0xFF0D9488) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted ? const Color(0xFF0D9488) : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),
              const SizedBox(width: 16),

              // Title & Description
              Expanded(
                child: GestureDetector(
                  onTap: () => _showTaskEditorSheet(task: task),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: task.isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: task.isCompleted ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 13,
                              color: _isOverdue(task) ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM dd, yyyy').format(task.dueDate!),
                              style: TextStyle(
                                color: _isOverdue(task) ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Edit & Priority indicator tag
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      priorityText.toUpperCase(),
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF94A3B8), size: 22),
                    onPressed: () => _showTaskEditorSheet(task: task),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isOverdue(TodoTask task) {
    if (task.isCompleted || task.dueDate == null) return false;
    final today = DateTime.now();
    final compareDate = DateTime(today.year, today.month, today.day);
    return task.dueDate!.isBefore(compareDate);
  }
}

// ── TASK EDITOR BOTTOM SHEET ──
class TaskEditorSheet extends StatefulWidget {
  final TodoService todoService;
  final TodoTask? task;

  const TaskEditorSheet({
    super.key,
    required this.todoService,
    this.task,
  });

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D9488),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (widget.task == null) {
      // Add mode
      final newTask = TodoTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: _descCtrl.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
      );
      widget.todoService.addTask(newTask);
    } else {
      // Edit mode
      final updatedTask = widget.task!.copyWith(
        title: title,
        description: _descCtrl.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
      );
      widget.todoService.updateTask(updatedTask);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.task != null;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sheet Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEditMode ? 'Edit Task' : 'Add New Task',
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Title Field
            const Text(
              'TASK TITLE',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                hintText: 'e.g., Clean my room, Submit code...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF0D9488)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Description Field
            const Text(
              'DESCRIPTION (OPTIONAL)',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                hintText: 'Add description or details here...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF0D9488)),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Priority & Due Date selectors Row
            Row(
              children: [
                // Priority Selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRIORITY',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<TaskPriority>(
                            value: _priority,
                            items: TaskPriority.values.map((p) {
                              String label;
                              switch (p) {
                                case TaskPriority.high:
                                  label = 'High';
                                  break;
                                case TaskPriority.medium:
                                  label = 'Medium';
                                  break;
                                case TaskPriority.low:
                                  label = 'Low';
                                  break;
                              }
                              return DropdownMenuItem<TaskPriority>(
                                value: p,
                                child: Text(label, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _priority = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Due Date selector card
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DUE DATE',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dueDate != null
                                    ? DateFormat('MMM dd, yyyy').format(_dueDate!)
                                    : 'Select Date',
                                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.calendar_month_rounded, color: Color(0xFF94A3B8), size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Actions row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isEditMode ? 'Update Task' : 'Save Task',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
