import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _isLoggingOut = false;

  // ─── Actions ────────────────────────────────────────────────────────────────

  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutDialog();
    if (!confirmed || !mounted) return;

    setState(() => _isLoggingOut = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
    );
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surface,
        title: const Text(
          'Đăng xuất?',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        content: const Text(
          'Bạn có chắc muốn đăng xuất khỏi tài khoản không?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature sẽ sớm ra mắt! 🚀'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 28),
            _buildSection(
              title: 'Tài khoản & Gói cước',
              items: [
                _SettingItem(
                  icon: Icons.star_rounded,
                  iconColor: Colors.orange,
                  title: 'Gói Premium',
                  subtitle: 'Mở khoá tính năng nâng cao',
                  badge: 'HOT',
                  onTap: () => _showComingSoon('Tính năng Premium'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Ứng dụng',
              items: [
                _SettingItem(
                  icon: Icons.language_rounded,
                  iconColor: Colors.blue,
                  title: 'Ngôn ngữ',
                  subtitle: 'Tiếng Việt',
                  onTap: () => _showComingSoon('Đổi ngôn ngữ'),
                ),
                _SettingItem(
                  icon: Icons.dark_mode_rounded,
                  iconColor: Colors.deepPurple,
                  title: 'Chế độ tối',
                  trailing: Switch(
                    value: _isDarkMode,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isDarkMode = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Hỗ trợ',
              items: [
                _SettingItem(
                  icon: Icons.headset_mic_rounded,
                  iconColor: Colors.green,
                  title: 'Liên hệ hỗ trợ',
                  subtitle: 'Gửi yêu cầu hoặc báo lỗi',
                  onTap: () => _showComingSoon('Liên hệ'),
                ),
                _SettingItem(
                  icon: Icons.info_outline_rounded,
                  iconColor: Colors.blueGrey,
                  title: 'Phiên bản',
                  subtitle: '1.0.0 (Build 2026)',
                ),
              ],
            ),
            const SizedBox(height: 36),
            _buildLogoutButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'Cài đặt',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Avatar + tên người dùng placeholder ở đầu trang
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.15), AppColors.primary.withOpacity(0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xin chào 👋',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Người dùng',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Free',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<_SettingItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.4,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.4)),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return _buildSettingTile(e.value, showDivider: !isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(_SettingItem item, {bool showDivider = false}) {
    return Column(
      children: [
        ListTile(
          onTap: item.onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 21),
          ),
          title: Row(
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
              if (item.badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: item.subtitle != null
              ? Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              item.subtitle!,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          )
              : null,
          trailing: item.trailing ??
              (item.onTap != null
                  ? const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20)
                  : null),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
            color: AppColors.border.withOpacity(0.4),
          ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isLoggingOut ? null : _handleLogout,
        icon: _isLoggingOut
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger),
        )
            : const Icon(Icons.logout_rounded, size: 20),
        label: Text(_isLoggingOut ? 'Đang đăng xuất...' : 'Đăng xuất'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.danger.withOpacity(0.1),
          foregroundColor: AppColors.danger,
          disabledBackgroundColor: AppColors.danger.withOpacity(0.06),
          disabledForegroundColor: AppColors.danger.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─── Data model nội bộ ───────────────────────────────────────────────────────

class _SettingItem {
  const _SettingItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? badge;
  final VoidCallback? onTap;
}