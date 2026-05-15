import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const NotificationsScreen({super.key, this.scrollController});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotificationService(),
      builder: (context, child) {
        final allNotifications = NotificationService().notifications;
        final unreadNotifications = allNotifications.where((n) => !n.isRead).toList();
        final readNotifications = allNotifications.where((n) => n.isRead).toList();
        final unreadCount = unreadNotifications.length;
        
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Premium Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Notifikasi',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$unreadCount Baru',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        if (allNotifications.isNotEmpty)
                          IconButton(
                            onPressed: () => _confirmClearAll(context),
                            icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.expenseColor, size: 22),
                            tooltip: 'Hapus semua',
                          ),
                        if (unreadCount > 0)
                          IconButton(
                            onPressed: () => NotificationService().markAllAsRead(),
                            icon: const Icon(Icons.done_all_rounded, color: AppTheme.primaryColor, size: 22),
                            tooltip: 'Tandai semua dibaca',
                          ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppTheme.textPrimary, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tab Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.all(4),
                    tabs: const [
                      Tab(text: 'Semua'),
                      Tab(text: 'Belum Dibaca'),
                      Tab(text: 'Sudah Dibaca'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotificationList(context, allNotifications),
                    _buildNotificationList(context, unreadNotifications),
                    _buildNotificationList(context, readNotifications),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationList(BuildContext context, List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      controller: widget.scrollController,
      physics: widget.scrollController == null 
          ? const BouncingScrollPhysics() 
          : null,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Dismissible(
          key: Key(notification.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.expenseColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
          ),
          confirmDismiss: (direction) => _confirmDelete(context, notification),
          onDismissed: (direction) {
            NotificationService().deleteNotification(notification.id);
            _showDeletedSnackbar(context);
          },
          child: FadeInUp(
            duration: Duration(milliseconds: 300 + (index * 50)),
            child: _buildNotificationItem(context, notification),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(BuildContext context, AppNotification notification) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    // Kategori mapping untuk UI Premium
    switch (notification.type) {
      case 'transaction':
        final isIncome = notification.title.toLowerCase().contains('pemasukan');
        icon = isIncome ? Icons.add_chart_rounded : Icons.shopping_cart_checkout_rounded;
        iconColor = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
        bgColor = iconColor.withOpacity(0.12);
        break;
      case 'alert':
        icon = Icons.warning_rounded;
        iconColor = AppTheme.expenseColor;
        bgColor = iconColor.withOpacity(0.12);
        break;
      case 'budget':
        icon = Icons.account_balance_wallet_rounded;
        iconColor = Colors.orange;
        bgColor = iconColor.withOpacity(0.12);
        break;
      case 'saving':
        icon = Icons.stars_rounded;
        iconColor = const Color(0xFF6366F1); // Indigo premium
        bgColor = iconColor.withOpacity(0.12);
        break;
      case 'report':
        icon = Icons.bar_chart_rounded;
        iconColor = Colors.teal;
        bgColor = iconColor.withOpacity(0.12);
        break;
      default:
        icon = Icons.notifications_active_rounded;
        iconColor = AppTheme.textSecondary;
        bgColor = Colors.grey.withOpacity(0.12);
    }

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          NotificationService().markAsRead(notification.id);
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailScreen(notification: notification),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: notification.isRead 
            ? null 
            : Border.all(color: AppTheme.primaryColor.withOpacity(0.15), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981), // Emerald/Green Dot
                              shape: BoxShape.circle,
                            ),
                          ),
                        const SizedBox(width: 4),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () => _confirmDelete(context, notification),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.expenseColor.withOpacity(0.6)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        fontSize: 11, 
                        color: AppTheme.textSecondary.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, AppNotification notification) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Notifikasi?'),
        content: const Text('Apakah Anda yakin ingin menghapus notifikasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              // Jika dipanggil dari tombol (bukan swipe), hapus manual
              if (Navigator.canPop(context)) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: AppTheme.expenseColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Semua?'),
        content: const Text('Semua riwayat notifikasi Anda akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              NotificationService().clearAll();
              Navigator.pop(context);
              _showDeletedSnackbar(context, message: 'Semua notifikasi berhasil dihapus');
            },
            child: const Text('Hapus Semua', style: TextStyle(color: AppTheme.expenseColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeletedSnackbar(BuildContext context, {String message = 'Notifikasi berhasil dihapus'}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppTheme.textPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit yang lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam yang lalu';
    return DateFormat('dd MMM, HH:mm', 'id').format(timestamp);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 80,
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: const Text(
              'Belum Ada Notifikasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Aktivitas transaksi dan pengingat finansial Anda akan muncul di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
