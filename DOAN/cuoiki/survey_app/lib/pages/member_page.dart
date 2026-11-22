import 'package:flutter/material.dart';

import '../models/member.dart';
import '../repositories/member_repository.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key, required this.currentMemberId});
  final int currentMemberId;
  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  List<Member> _members = [];
  List<String> _roles = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final members = await MemberRepository.getMembers();
      final roles = await MemberRepository.getRoles();
      if (mounted) {
        setState(() {
          _members = members;
          _roles = roles;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit(Member member) async {
    final form = GlobalKey<FormState>();
    final name = TextEditingController(text: member.fullName);
    var role = member.roleName;
    var active = member.isActive;
    var saving = false;
    String? error;
    final route = DialogRoute<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => PopScope(
          canPop: !saving,
          child: AlertDialog(
            title: const Text('Sửa thành viên'),
            content: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(member.email),
                    TextFormField(
                      controller: name,
                      enabled: !saving,
                      maxLength: 100,
                      decoration: const InputDecoration(labelText: 'Họ tên'),
                      validator: (v) => (v ?? '').trim().length < 2
                          ? 'Họ tên ít nhất 2 ký tự'
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: role,
                      decoration: const InputDecoration(labelText: 'Vai trò'),
                      items: _roles
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                      onChanged: saving ? null : (v) => update(() => role = v!),
                    ),
                    SwitchListTile(
                      title: const Text('Cho phép đăng nhập'),
                      value: active,
                      onChanged: saving
                          ? null
                          : (v) => update(() => active = v),
                    ),
                    if (error != null) Text(error!),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.pop(dialogContext, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!form.currentState!.validate()) return;
                        update(() {
                          saving = true;
                          error = null;
                        });
                        try {
                          await MemberRepository.updateMember(
                            member,
                            name.text.trim(),
                            role,
                            active,
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, true);
                          }
                        } catch (e) {
                          if (dialogContext.mounted) {
                            update(() {
                              saving = false;
                              error = e.toString().replaceFirst(
                                'Exception: ',
                                '',
                              );
                            });
                          }
                        }
                      },
                child: Text(saving ? 'Đang lưu...' : 'Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
    final changed = await Navigator.of(context).push(route);
    await route.completed;
    name.dispose();
    if (changed == true && mounted) await _load();
  }

  Future<void> _delete(Member member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thành viên?'),
        content: Text(
          'Xóa tài khoản ${member.email}? Có thể khóa thay vì xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loading = true);
    try {
      await MemberRepository.deleteMember(member.memberId);
      await _load();
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Thành viên và vai trò'),
      actions: [
        IconButton(
          onPressed: _loading ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Vai trò hệ thống: ${_roles.join(', ')}'),
              const Text(
                'Thành viên mới tạo bằng chức năng Đăng ký. Admin sửa thông tin, khóa và phân quyền tại đây.',
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!),
                ),
              if (_members.isEmpty && _error == null)
                const Text('Chưa có thành viên.'),
              ..._members.map(
                (m) => Card(
                  child: ListTile(
                    title: Text(m.fullName),
                    subtitle: Text(
                      '${m.email}\n${m.roleName} • ${m.isActive ? 'Hoạt động' : 'Đã khóa'}',
                    ),
                    isThreeLine: true,
                    trailing: m.memberId == widget.currentMemberId
                        ? const Text('Bạn')
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Sửa / phân quyền',
                                onPressed: () => _edit(m),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Xóa',
                                onPressed: () => _delete(m),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
  );
}
