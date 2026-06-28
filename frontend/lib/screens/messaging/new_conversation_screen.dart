import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../models/user_model.dart';

class NewConversationScreen extends ConsumerStatefulWidget {
  const NewConversationScreen({super.key});

  @override
  ConsumerState<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends ConsumerState<NewConversationScreen> {
  bool _isPublic = false;
  final _nameController = TextEditingController();
  String _publicAudience = 'all';
  final _searchController = TextEditingController();
  final List<UserModel> _selectedUsers = [];
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    final students = ref.read(studentProvider).students;
    final teachers = ref.read(teacherProvider).teachers;

    final results = <UserModel>[];
    for (final s in students) {
      if ((s.firstName ?? '').toLowerCase().contains(query.toLowerCase()) ||
          (s.lastName ?? '').toLowerCase().contains(query.toLowerCase()) ||
          (s.email ?? '').toLowerCase().contains(query.toLowerCase())) {
        results.add(UserModel(
          id: s.userId,
          name: s.fullName,
          email: s.email ?? '',
          status: 'active',
          role: 'student',
        ));
      }
    }
    for (final t in teachers) {
      if ((t.firstName ?? '').toLowerCase().contains(query.toLowerCase()) ||
          (t.lastName ?? '').toLowerCase().contains(query.toLowerCase()) ||
          (t.email ?? '').toLowerCase().contains(query.toLowerCase())) {
        results.add(UserModel(
          id: t.userId,
          name: t.fullName,
          email: t.email ?? '',
          status: 'active',
          role: 'teacher',
        ));
      }
    }

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  bool _isSelected(int userId) {
    return _selectedUsers.any((u) => u.id == userId);
  }

  void _toggleUser(UserModel user) {
    setState(() {
      if (_isSelected(user.id)) {
        _selectedUsers.removeWhere((u) => u.id == user.id);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _createConversation() async {
    if (_isPublic) {
      final name = _nameController.text.trim();
      final conv = await ref.read(conversationProvider.notifier).createPublicConversation(
        name: name.isNotEmpty ? name : null,
        publicAudience: _publicAudience,
      );
      if (conv != null && mounted) {
        context.pop();
        context.push('/messaging/chat/${conv.id}', extra: conv);
      }
    } else {
      if (_selectedUsers.isEmpty) return;
      final userIds = _selectedUsers.map((u) => u.id).toList();
      final conv = await ref.read(conversationProvider.notifier).createConversation(userIds);
      if (conv != null && mounted) {
        context.pop();
        context.push('/messaging/chat/${conv.id}', extra: conv);
      }
    }
  }

  bool get _canCreate => _isPublic
      ? _nameController.text.trim().isNotEmpty
      : _selectedUsers.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle conversation'),
        actions: [
          if (_canCreate)
            TextButton(
              onPressed: _createConversation,
              child: const Text('Créer'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Privée'),
                  icon: Icon(Icons.lock_outline, size: 18),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Publique'),
                  icon: Icon(Icons.public_outlined, size: 18),
                ),
              ],
              selected: {_isPublic},
              onSelectionChanged: (v) => setState(() {
                _isPublic = v.first;
                _nameController.clear();
                _selectedUsers.clear();
                _searchResults.clear();
                _searchController.clear();
              }),
            ),
          ),
          if (_isPublic) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Titre de l\'annonce',
                  hintText: 'Ex: Réunion importante',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: DropdownButtonFormField<String>(
                key: ValueKey(_publicAudience),
                initialValue: _publicAudience,
                decoration: const InputDecoration(
                  labelText: 'Visible par',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tout le monde')),
                  DropdownMenuItem(value: 'students', child: Text('Étudiants')),
                  DropdownMenuItem(value: 'teachers', child: Text('Enseignants')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrateurs')),
                ],
                onChanged: (v) => setState(() => _publicAudience = v ?? 'all'),
              ),
            ),
          ] else ...[
            if (_selectedUsers.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _selectedUsers.map((u) => Chip(
                    label: Text(u.name, style: const TextStyle(fontSize: 13)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _toggleUser(u),
                  )).toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un utilisateur...',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: _search,
              ),
            ),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty && _searchController.text.isNotEmpty
                      ? Center(
                          child: Text('Aucun résultat',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            final selected = _isSelected(user.id);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceContainerHighest,
                                child: Text(
                                  (user.name.isNotEmpty ? user.name[0] : '?')
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: selected
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              title: Text(user.name),
                              subtitle: Text(user.email),
                              trailing: selected
                                  ? Icon(Icons.check_circle_rounded,
                                      color: theme.colorScheme.primary)
                                  : null,
                              onTap: () => _toggleUser(user),
                            );
                          },
                        ),
            ),
          ],
        ],
      ),
    );
  }
}
