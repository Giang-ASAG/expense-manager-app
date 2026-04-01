import 'package:expense_manager_app/core/services/rtdb_service.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:expense_manager_app/features/expense/data/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key,required this.isExpense});
  final bool isExpense;
  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _previewAnimController;
  late Animation<double> _previewScaleAnim;

  late bool isExpense = widget.isExpense;
  bool _isIconExpanded = true;
  bool _isColorExpanded = false;

  String selectedIcon = 'restaurant';
  int selectedColor = 0xFF2196F3;
  String? userId;

  final List<int> colorPalette = [
    0xFF2196F3,
    0xFFF44336,
    0xFF4CAF50,
    0xFFFF9800,
    0xFF9C27B0,
    0xFFE91E63,
    0xFF00BCD4,
    0xFF795548,
    0xFF607D8B,
    0xFF000000,
    0xFF673AB7,
    0xFFFFEB3B,
  ];

  final List<Map<String, dynamic>> icons = [
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'coffee', 'icon': Icons.coffee},
    {'name': 'pizza', 'icon': Icons.local_pizza},
    {'name': 'movie', 'icon': Icons.movie},
    {'name': 'car', 'icon': Icons.directions_car},
    {'name': 'gas', 'icon': Icons.local_gas_station},
    {'name': 'bike', 'icon': Icons.directions_bike},
    {'name': 'bus', 'icon': Icons.directions_bus},
    {'name': 'shopping', 'icon': Icons.shopping_bag},
    {'name': 'bill', 'icon': Icons.receipt_long},
    {'name': 'medical', 'icon': Icons.medical_services},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'bank', 'icon': Icons.account_balance},
    {'name': 'money', 'icon': Icons.attach_money},
  ];

  @override
  void initState() {
    super.initState();
    _loadUid();
    _nameController.addListener(() => setState(() {}));

    _previewAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _previewScaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _previewAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _previewAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => userId = prefs.getString('user_uid'));
  }

  void _onSelectionChanged() {
    _previewAnimController.forward().then(
      (_) => _previewAnimController.reverse(),
    );
  }

  void _saveCategory() async {
    final name = _nameController.text.trim();
    if (userId == null || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập tên danh mục'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    // Gọi bên trong hàm _saveCategory()
    await RTDBService().addNewCategory(
      userId!,
      CategoryModel(
        id: '',
        // ID sẽ do Firebase tự tạo khi .push()
        name: _nameController.text.trim(),
        icon: selectedIcon,
        // String từ biến state
        colorValue: selectedColor,
        // int từ biến state
        isExpense: isExpense, // bool từ Toggle Button
      ),
    );
    // TODO: Gọi RTDBService().addNewCategory(...)
    Navigator.pop(context);
  }

  IconData get _currentIconData =>
      icons.firstWhere((e) => e['name'] == selectedIcon)['icon'] as IconData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeToggle(),
                  const SizedBox(height: 24),
                  _buildPreviewCard(),
                  const SizedBox(height: 24),
                  _buildNameInput(),
                  const SizedBox(height: 16),
                  _buildSelectionContainer(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: _circleButton(
        icon: Icons.close,
        onTap: () => Navigator.pop(context),
      ),
      title: const Text(
        'Tạo Danh mục',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }

  // ── Type Toggle ──────────────────────────────────────────────────────────

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _toggleItem('Chi phí', isExpense, AppColors.danger),
          _toggleItem('Thu nhập', !isExpense, AppColors.success),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool isActive, Color activeColor) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isExpense = (label == 'Chi phí')),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Live Preview Card ────────────────────────────────────────────────────

  Widget _buildPreviewCard() {
    final displayName = _nameController.text.trim().isEmpty
        ? 'Tên danh mục'
        : _nameController.text.trim();
    final accentColor = Color(selectedColor);

    return ScaleTransition(
      scale: _previewScaleAnim,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    accentColor.withOpacity(0.25),
                    accentColor.withOpacity(0.08),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(_currentIconData, color: accentColor, size: 26),
            ),
            const SizedBox(width: 16),
            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: _nameController.text.trim().isEmpty
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isExpense
                          ? AppColors.danger.withOpacity(0.1)
                          : AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isExpense ? 'Chi phí' : 'Thu nhập',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isExpense ? AppColors.danger : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Color dot
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Name Input ───────────────────────────────────────────────────────────

  Widget _buildNameInput() {
    return _buildCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.label_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tên danh mục',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Tên hiển thị cho danh mục',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameController,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập tên danh mục...',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(selectedColor), width: 1.5),
              ),
              suffixIcon: _nameController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () => _nameController.clear(),
                      child: const Icon(
                        Icons.cancel,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── Selection Container ──────────────────────────────────────────────────

  Widget _buildSelectionContainer() {
    return _buildCardWrapper(
      child: Column(
        children: [
          // Icon section
          _buildExpandableHeader(
            icon: Icons.emoji_emotions_outlined,
            title: 'Biểu tượng',
            subtitle: 'Chọn biểu tượng đại diện',
            isExpanded: _isIconExpanded,
            onTap: () => setState(() => _isIconExpanded = !_isIconExpanded),
          ),
          _buildAnimatedSection(
            isExpanded: _isIconExpanded,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  final item = icons[index];
                  final isSelected = selectedIcon == item['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedIcon = item['name']);
                      _onSelectionChanged();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(selectedColor).withOpacity(0.12)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? Color(selectedColor)
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(selectedColor).withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        item['icon'],
                        color: isSelected
                            ? Color(selectedColor)
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(child: Divider(color: AppColors.border, height: 1)),
              ],
            ),
          ),

          // Color section
          _buildExpandableHeader(
            icon: Icons.palette_outlined,
            title: 'Màu sắc',
            subtitle: 'Màu chủ đạo cho danh mục',
            isExpanded: _isColorExpanded,
            onTap: () => setState(() => _isColorExpanded = !_isColorExpanded),
          ),
          _buildAnimatedSection(
            isExpanded: _isColorExpanded,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: colorPalette.length,
                itemBuilder: (context, index) {
                  final colorHex = colorPalette[index];
                  final isSelected = selectedColor == colorHex;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedColor = colorHex);
                      _onSelectionChanged();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Color(colorHex),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2.5)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(colorHex).withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _buildExpandableHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Color(selectedColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Color(selectedColor)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AnimatedRotation(
            turns: isExpanded ? 0.0 : 0.5,
            duration: const Duration(milliseconds: 250),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.keyboard_arrow_up,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({
    required bool isExpanded,
    required Widget child,
  }) {
    return AnimatedCrossFade(
      firstChild: child,
      secondChild: const SizedBox.shrink(),
      crossFadeState: isExpanded
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 300),
      firstCurve: Curves.easeOut,
      secondCurve: Curves.easeIn,
    );
  }

  // ── Bottom Buttons ───────────────────────────────────────────────────────

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: const BorderSide(color: AppColors.border, width: 1.5),
              ),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _saveCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(selectedColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                shadowColor: Color(selectedColor).withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Lưu danh mục',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
