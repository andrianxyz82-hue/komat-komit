import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';
import '../../core/widgets/neon_background_painter.dart';
import 'edit_profile_screen.dart';
import '../about/about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<NeonDot> _neonDots = [];
  String? _fullName;
  String? _email;
  String? _class;
  String? _dailyQuote;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generateNeonDots();
    _loadProfile();
  }

  void _generateNeonDots() {
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _neonDots.add(NeonDot(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.5, // Top half
        radius: random.nextDouble() * 4 + 1,
        color: i % 2 == 0 ? const Color(0xFFB042FF) : const Color(0xFF42E0FF),
        opacity: random.nextDouble() * 0.5,
      ));
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      setState(() {
        _fullName = profile['full_name'];
        _email = profile['email'];
        _class = profile['class'];
        _dailyQuote = profile['daily_quote'];
      });
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1d1d2b),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: NeonBackgroundPainter(dots: _neonDots),
            ),
          ),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Header
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        // Profile Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D44),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFF7C7CFF),
                                child: Text(
                                  _fullName != null && _fullName!.isNotEmpty
                                      ? _fullName![0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _fullName ?? 'Belum diatur',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _email ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textGrey,
                                ),
                              ),
                              if (_class != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7C7CFF).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _class!,
                                    style: const TextStyle(
                                      color: Color(0xFF7C7CFF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                              if (_dailyQuote != null && _dailyQuote!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E2C),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.format_quote,
                                        color: Color(0xFF7C7CFF),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _dailyQuote!,
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Menu Items
                        _buildMenuItem(
                          context,
                          Icons.edit,
                          'Edit Profile',
                          () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                            if (result == true) {
                              _loadProfile(); // Reload profile
                            }
                          },
                        ),
                        _buildMenuItem(
                          context,
                          Icons.info_outline,
                          'Tentang Aplikasi',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AboutScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildMenuItem(
                          context,
                          Icons.logout,
                          'Logout',
                          () {
                            context.go('/');
                          },
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF7C7CFF),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.white,
          ),
        ),
        trailing: trailing ??
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textGrey,
            ),
      ),
    );
  }
}
