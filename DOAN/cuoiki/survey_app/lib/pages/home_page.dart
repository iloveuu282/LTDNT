import 'package:flutter/material.dart';

import '../local/local_database.dart';
import '../models/member.dart';
import '../repositories/member_repository.dart';
import '../repositories/campaign_repository.dart';
import 'login_page.dart';
import 'change_password_page.dart';
import 'member_page.dart';
import 'category_page.dart';
import 'survey_list_view.dart';
import 'plan_page.dart';
import 'campaign_list_page.dart';
import 'drafts_page.dart';
import 'server_settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.member});
  final Member member;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _busy = false;
  int _planCount = 0;
  int _revision = 0;
  bool get _admin => widget.member.roleName == 'Admin';
  @override
  void initState() {
    super.initState();
    _refreshPlan();
  }

  Future<void> _refreshPlan() async {
    try {
      final plan = await CampaignRepository.plan();
      if (mounted) setState(() => _planCount = plan.length);
    } catch (_) {
      /* Trang danh sách hiển thị lỗi kết nối. */
    }
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) {
      setState(() => _revision++);
      await _refreshPlan();
    }
  }

  Future<void> _logout() async {
    if (!await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Đăng xuất?'),
            content: const Text('Các nháp chưa gửi trên điện thoại sẽ bị xóa.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
        ).then((v) => v ?? false) ||
        !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      final revoked = await MemberRepository.logout();
      await LocalDatabase.clearDrafts(widget.member.memberId);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
      if (!revoked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã đăng xuất trên thiết bị. Chưa kết nối máy chủ để đăng xuất các phiên khác.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Chưa hoàn tất đăng xuất. Kiểm tra kết nối và thử lại.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Khảo sát doanh nghiệp',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Badge(
          label: Text('$_planCount'),
          isLabelVisible: _planCount > 0,
          child: IconButton(
            onPressed: _busy
                ? null
                : () => _open(
                    PlanPage(admin: _admin, memberId: widget.member.memberId),
                  ),
            tooltip: 'Kế hoạch triển khai',
            icon: const Icon(Icons.assignment_outlined),
          ),
        ),
        IconButton(
          onPressed: _busy ? null : () => _open(const ServerSettingsPage()),
          tooltip: 'Kết nối máy chủ',
          icon: const Icon(Icons.settings_outlined),
        ),
        IconButton(
          onPressed: _busy ? null : _logout,
          tooltip: 'Đăng xuất',
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: SurveyListView(
      key: ValueKey(_revision),
      admin: _admin,
      onPlanChanged: _refreshPlan,
      header: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.member.fullName} • ${widget.member.roleName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Wrap(
                  spacing: 6,
                  children: [
                    TextButton(
                      onPressed: () => _open(
                        CampaignListPage(
                          memberId: widget.member.memberId,
                          admin: _admin,
                        ),
                      ),
                      child: Text(
                        _admin ? 'Quản lý chiến dịch' : 'Chiến dịch của tôi',
                      ),
                    ),
                    TextButton(
                      onPressed: () => _open(
                        CampaignListPage(
                          memberId: widget.member.memberId,
                          admin: _admin,
                          open: true,
                        ),
                      ),
                      child: const Text('Khảo sát đang mở'),
                    ),
                    TextButton(
                      onPressed: () =>
                          _open(DraftsPage(memberId: widget.member.memberId)),
                      child: const Text('Bản nháp'),
                    ),
                    TextButton(
                      onPressed: () => _open(
                        ChangePasswordPage(memberId: widget.member.memberId),
                      ),
                      child: const Text('Đổi mật khẩu'),
                    ),
                    if (_admin) ...[
                      TextButton(
                        onPressed: () => _open(const CategoryPage()),
                        child: const Text('Danh mục'),
                      ),
                      TextButton(
                        onPressed: () => _open(
                          MemberPage(currentMemberId: widget.member.memberId),
                        ),
                        child: const Text('Thành viên và vai trò'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    ),
  );
}
