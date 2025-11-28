import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _quoteController = TextEditingController();
  
  bool _loading = false;
  String? _email;
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
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
        _nameController.text = profile['full_name'] ?? '';
        _classController.text = profile['class'] ?? '';
        _quoteController.text = profile['daily_quote'] ?? '';
        _email = profile['email'];
      });
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() => _loading = false);
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      
      await Supabase.instance.client
          .from('profiles')
          .update({
            'full_name': _nameController.text,
            'class': _classController.text,
            'daily_quote': _quoteController.text,
          })
          .eq('id', userId!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _quoteController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF7C7CFF),
      ),
      body: _loading && _email == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Avatar
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF7C7CFF),
                      child: Text(
                        _nameController.text.isNotEmpty 
                            ? _nameController.text[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Nama Lengkap
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      hintText: 'Masukkan nama lengkap',
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2D2D44) : Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {}); // Update avatar
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Kelas
                  TextFormField(
                    controller: _classController,
                    decoration: InputDecoration(
                      labelText: 'Kelas',
                      hintText: 'Contoh: XII IPA 1',
                      prefixIcon: const Icon(Icons.class_),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2D2D44) : Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kelas tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Kata-kata Hari Ini
                  TextFormField(
                    controller: _quoteController,
                    decoration: InputDecoration(
                      labelText: 'Kata-kata Hari Ini',
                      hintText: 'Motivasi untuk hari ini',
                      prefixIcon: const Icon(Icons.format_quote),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2D2D44) : Colors.grey[100],
                    ),
                    maxLength: 100,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  
                  // Email (read-only)
                  TextFormField(
                    initialValue: _email ?? '',
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2D2D44) : Colors.grey[100],
                      enabled: false,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Save Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C7CFF),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
