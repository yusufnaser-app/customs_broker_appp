import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const _DashboardHomeTab(),
    const Center(child: Text('الإقرارات', style: TextStyle(fontSize: 24))),
    const Center(child: Text('العملاء', style: TextStyle(fontSize: 24))),
    const Center(child: Text('المالية', style: TextStyle(fontSize: 24))),
    const Center(child: Text('المزيد', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.cairo(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'الإقرارات'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'العملاء'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'المالية'),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'المزيد'),
          ],
        ),
      ),
    );
  }
}

class _DashboardHomeTab extends StatelessWidget {
  const _DashboardHomeTab();

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy/MM/dd');
    final today = dateFormatter.format(DateTime.now());
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لوحة التحكم',
                      style: GoogleFonts.cairo(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headlineLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      today,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 25),
            
            // بطاقات الإحصائيات
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  context,
                  title: 'الإقرارات',
                  value: '24',
                  icon: Icons.description_outlined,
                  color: AppColors.info,
                  subtitle: '+3 هذا الأسبوع',
                ),
                _buildStatCard(
                  context,
                  title: 'العملاء',
                  value: '45',
                  icon: Icons.people_outline,
                  color: AppColors.success,
                  subtitle: '+5 هذا الشهر',
                ),
                _buildStatCard(
                  context,
                  title: 'الإيرادات',
                  value: '2.5M ر.ي',
                  icon: Icons.trending_up,
                  color: AppColors.accent,
                  subtitle: 'هذا الشهر',
                ),
                _buildStatCard(
                  context,
                  title: 'الرصيد',
                  value: '850K ر.ي',
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  subtitle: 'الصندوق والبنوك',
                ),
              ],
            ),
            const SizedBox(height: 25),
            
            // الإقرارات الجارية
            Text(
              'الإقرارات الجارية',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            
            // قائمة الإقرارات
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.description, color: AppColors.primary, size: 22),
                    ),
                    title: Text(
                      'إقرار جمركي #${2024001 + index}',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'العميل: شركة النجاح للتجارة',
                      style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: index < 3 ? AppColors.warning.withOpacity(0.2) : AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        index < 3 ? 'قيد المعالجة' : 'مكتمل',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: index < 3 ? AppColors.warning : AppColors.success,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
