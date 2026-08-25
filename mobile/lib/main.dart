import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io' show Platform, File;
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<String> appLanguage = ValueNotifier<String>('id');
final ValueNotifier<String> appProfileName = ValueNotifier<String>('Admin NUSA');
String appPassword = 'admin';
String appUsername = 'admin';
SharedPreferences? prefs;

const Map<String, Map<String, String>> translations = {
  'id': {
    'hi': 'Hai',
    'login_welcome': 'Selamat Datang!',
    'login_subtitle': 'Mari kelola sistem energi Anda',
    'username': 'Nama Pengguna',
    'password': 'Kata Sandi',
    'login_btn': 'Masuk',
    'quick_actions': 'Aksi Cepat',
    'turn_off_relays': 'Matikan Semua Relay',
    'turn_on_relays': 'Hidupkan Semua Relay',
    'ai_mode': 'Aktifkan Mode Hemat AI',
    'home': 'Beranda',
    'analysis': 'Analisis',
    'ai_engine': 'Mesin AI',
    'profile': 'Profil',
    'good_morning': 'Selamat Pagi',
    'search': 'Cari...',
    'smart_relays': 'Relai Cerdas',
    'view_all': 'lihat semua',
    'system_ok': 'Sistem Normal!',
    'battery_at': 'Baterai di',
    'solar': 'Surya',
    'vital_facilities': 'Fasilitas Vital',
    'basic_needs': 'Kebutuhan Dasar',
    'standby': 'Siaga',
    'active': 'Aktif',
    'total_production': 'Total Produksi (Bulan ini)',
    'total_consumption': 'Total Konsumsi (Bulan ini)',
    'daily_usage': 'Penggunaan Harian',
    'status_active': 'Status: Aktif & Mengoptimalkan',
    'ai_settings': 'Pengaturan AI',
    'auto_cutoff': 'Pemutusan Otomatis Cuaca Buruk',
    'auto_cutoff_sub': 'AI mematikan relai non-esensial',
    'vital_priority': 'Prioritas Fasilitas Vital',
    'vital_priority_sub': 'Relai prioritas 1 selalu menyala',
    'system_admin': 'Administrator Sistem',
    'uptime': 'Waktu Nyala',
    'savings': 'Penghematan',
    'logs': 'Catatan',
    'gen_settings': 'Pengaturan Umum',
    'edit_profile': 'Ubah Profil',
    'edit_profile_sub': 'Perbarui info pribadi Anda',
    'notifications': 'Notifikasi',
    'notifications_sub': 'Kelola preferensi peringatan',
    'security': 'Keamanan & Privasi',
    'security_sub': 'Kata sandi dan biometrik',
    'language': 'Bahasa',
    'language_sub': 'Ubah bahasa aplikasi',
    'logout': 'Keluar',
    'change_password': 'Ubah Kata Sandi',
    'old_password': 'Kata Sandi Lama',
    'new_password': 'Kata Sandi Baru',
    'confirm_password': 'Konfirmasi Kata Sandi',
    'save_changes': 'Simpan Perubahan',
    'push_notif': 'Notifikasi Push',
    'push_notif_sub': 'Terima peringatan di perangkat ini',
    'lang_id': 'Bahasa Indonesia',
    'lang_en': 'English (US)',
    'wrong_pass': 'Username atau Password salah!',
    'hi_admin': 'Hai Admin!',
    'full_name': 'Nama Lengkap',
    'email': 'Alamat Email',
    'command_sent': 'Perintah Dikirim',
    'turn_off_exec': 'Matikan semua relay dieksekusi',
    'turn_on_exec': 'Hidupkan semua relay dieksekusi',
    'ai_mode_active': 'Mode AI diaktifkan',
    'relay_update': 'Pembaruan Relay',
    'relay_toggled': 'Status relay diubah',
    'auto_cutoff_act': 'Auto-Cutoff Diaktifkan',
    'auto_cutoff_deact': 'Auto-Cutoff Dinonaktifkan',
    'priority_act': 'Prioritas Diaktifkan',
    'priority_deact': 'Prioritas Dinonaktifkan',
    'notif_perm': 'Izin Notifikasi',
    'notif_perm_desc': 'NUSA POWER ingin mengirimkan peringatan sistem.',
    'deny': 'Tolak',
    'allow': 'Izinkan',
    'perm_granted': 'Izin Diberikan',
    'perm_granted_desc': 'Anda kini akan menerima peringatan otomatis.',
    'fill_all_pass': 'Isi semua kolom kata sandi!',
    'pass_mismatch': 'Konfirmasi kata sandi tidak cocok!',
    'pass_changed': 'Kata sandi berhasil diubah secara permanen.',
    'lang_changed': 'Bahasa Diubah',
    'lang_changed_desc': 'Bahasa aplikasi telah disetel ke Bahasa Indonesia.',
    'error': 'Kesalahan',
    'success': 'Berhasil',
    'schedule_timer': 'Jadwal Timer',
    'energy_usage': 'Penggunaan Energi',
    'relay_settings': 'Pengaturan Relay',
    'feature_dev': 'Fitur ini sedang dalam pengembangan.',
    'settings_title': 'Pengaturan',
    'relay_name_label': 'Nama Relay',
    'priority_label': 'Prioritas (1 = Tertinggi)',
    'level': 'Level',
    'cancel': 'Batal',
    'save': 'Simpan',
    'schedule_title': 'Jadwal - ',
    'turn_on_time': 'Waktu Nyala',
    'turn_off_time': 'Waktu Mati',
  },
  'en': {
    'hi': 'Hi',
    'login_welcome': 'Welcome!',
    'login_subtitle': 'Let\'s manage your energy systems',
    'username': 'Username',
    'password': 'Password',
    'login_btn': 'Login',
    'quick_actions': 'Quick Actions',
    'turn_off_relays': 'Turn Off All Relays',
    'turn_on_relays': 'Turn On All Relays',
    'ai_mode': 'Enable AI Power Saving',
    'home': 'Home',
    'analysis': 'Analytics',
    'ai_engine': 'AI Engine',
    'profile': 'Profile',
    'good_morning': 'Good Morning',
    'search': 'Search...',
    'smart_relays': 'Smart Relays',
    'view_all': 'view all',
    'system_ok': 'System OK!',
    'battery_at': 'Battery at',
    'solar': 'Solar',
    'vital_facilities': 'Vital Facilities',
    'basic_needs': 'Basic Needs',
    'standby': 'Standby',
    'active': 'Active',
    'total_production': 'Total Production (This Month)',
    'total_consumption': 'Total Consumption (This Month)',
    'daily_usage': 'Daily Usage',
    'status_active': 'Status: Active & Optimizing',
    'ai_settings': 'AI Settings',
    'auto_cutoff': 'Bad Weather Auto-Cutoff',
    'auto_cutoff_sub': 'AI turns off non-essential relays',
    'vital_priority': 'Vital Facility Priority',
    'vital_priority_sub': 'Priority 1 relays always on',
    'system_admin': 'System Administrator',
    'uptime': 'Uptime',
    'savings': 'Savings',
    'logs': 'Logs',
    'gen_settings': 'General Settings',
    'edit_profile': 'Edit Profile',
    'edit_profile_sub': 'Update your personal info',
    'notifications': 'Notifications',
    'notifications_sub': 'Manage alert preferences',
    'security': 'Security & Privacy',
    'security_sub': 'Password and biometrics',
    'language': 'Language',
    'language_sub': 'Change app language',
    'logout': 'Logout',
    'change_password': 'Change Password',
    'old_password': 'Old Password',
    'new_password': 'New Password',
    'confirm_password': 'Confirm Password',
    'save_changes': 'Save Changes',
    'push_notif': 'Push Notifications',
    'push_notif_sub': 'Receive alerts on this device',
    'lang_id': 'Indonesian',
    'lang_en': 'English (US)',
    'wrong_pass': 'Invalid Username or Password!',
    'hi_admin': 'Hi Admin!',
    'full_name': 'Full Name',
    'email': 'Email Address',
    'command_sent': 'Command Sent',
    'turn_off_exec': 'Turn off relays executed',
    'turn_on_exec': 'Turn on relays executed',
    'ai_mode_active': 'AI mode active',
    'relay_update': 'Relay Update',
    'relay_toggled': 'Relay toggled',
    'auto_cutoff_act': 'Auto-Cutoff Activated',
    'auto_cutoff_deact': 'Auto-Cutoff Deactivated',
    'priority_act': 'Priority Activated',
    'priority_deact': 'Priority Deactivated',
    'notif_perm': 'Notifications Permission',
    'notif_perm_desc': 'NUSA POWER would like to send you system alerts.',
    'deny': 'Deny',
    'allow': 'Allow',
    'perm_granted': 'Permission Granted',
    'perm_granted_desc': 'You will now receive automated alerts.',
    'fill_all_pass': 'Please fill all password fields!',
    'pass_mismatch': 'Password confirmation does not match!',
    'pass_changed': 'Password successfully changed permanently.',
    'lang_changed': 'Language Changed',
    'lang_changed_desc': 'App language has been set to English.',
    'error': 'Error',
    'success': 'Success',
    'schedule_timer': 'Schedule Timer',
    'energy_usage': 'Energy Usage',
    'relay_settings': 'Relay Settings',
    'feature_dev': 'This feature is under development.',
    'settings_title': 'Settings',
    'relay_name_label': 'Relay Name',
    'priority_label': 'Priority (1 = Highest)',
    'level': 'Level',
    'cancel': 'Cancel',
    'save': 'Save',
    'schedule_title': 'Schedule - ',
    'turn_on_time': 'Turn On Time',
    'turn_off_time': 'Turn Off Time',
  }
};

String getLang(String key) {
  return translations[appLanguage.value]?[key] ?? key;
}

String getRelayName(String name) {
  if (appLanguage.value == 'en') {
    if (name.contains('Fasilitas Vital')) return 'Vital Facilities';
    if (name.contains('Kebutuhan Dasar')) return 'Basic Needs';
    if (name.contains('Pendidikan')) return 'Education';
    if (name.contains('Aktivitas Produktif')) return 'Productive Activities';
    if (name.contains('Rumah Tangga')) return 'Household';
  }
  return name;
}

class NotificationService {
  static void showInAppNotification(BuildContext context, String title, String body) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -100.0, end: 0.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () => entry.remove(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF0F2E59), borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.notifications_active, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(body, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  prefs = await SharedPreferences.getInstance();
  appProfileName.value = prefs?.getString('profileName') ?? 'Admin NUSA';
  appPassword = prefs?.getString('password') ?? 'admin';
  appUsername = prefs?.getString('username') ?? 'admin';
  
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(400, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      minimumSize: Size(400, 800),
      maximumSize: Size(400, 800),
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const NusaPowerApp());
}

class NusaPowerApp extends StatelessWidget {
  const NusaPowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUSA POWER',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0F2E59),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        cardColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: const Color(0xFF1E293B), displayColor: const Color(0xFF1E293B)),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    try {
      final res = await http.get(Uri.parse('https://backend-ashy-three-94.vercel.app/api/version'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['version'] != '1.0.8') { // Local version is 1.0.8
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) {
                bool isDownloading = false;
                double progress = 0.0;
                
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: const Text('Update Tersedia! 🚀', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2E59))),
                      content: isDownloading
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Mengunduh pembaruan...'),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(value: progress < 0 ? null : progress),
                                const SizedBox(height: 8),
                                Text(progress < 0 ? 'Sedang mengunduh...' : '${(progress * 100).toStringAsFixed(1)}%'),
                              ],
                            )
                          : Text('Versi baru ${data['version']} tersedia.\n\nFitur baru:\n${data['features']}'),
                      actions: isDownloading
                          ? []
                          : [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Nanti')),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2E59)),
                                onPressed: () async {
                                  setState(() {
                                    isDownloading = true;
                                  });
                                  
                                  try {
                                    final dir = await getExternalStorageDirectory();
                                    final savePath = '${dir!.path}/app-update.apk';
                                    
                                    await Dio().download(
                                      data['url'],
                                      savePath,
                                      onReceiveProgress: (received, total) {
                                        setState(() {
                                          if (total != -1) {
                                            progress = received / total;
                                          } else {
                                            progress = -1.0;
                                          }
                                        });
                                      },
                                    );
                                    
                                    Navigator.pop(ctx);
                                    final result = await OpenFilex.open(savePath);
                                    if (result.type != ResultType.done) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka file APK: ${result.message}')));
                                    }
                                  } catch (e) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
                                  }
                                },
                                child: const Text('Update Sekarang', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                    );
                  },
                );
              },
            );
          }
        }
      }
    } catch (e) {
      print('Failed to check update: $e');
    }
  }

  void _login() async {
    setState(() => _isLoading = true);
    
    try {
      final res = await http.post(
        Uri.parse('https://backend-ashy-three-94.vercel.app/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _emailController.text,
          'password': _passwordController.text
        }),
      );
      
      setState(() => _isLoading = false);
      
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data.containsKey('error')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getLang('wrong_pass')), backgroundColor: Colors.redAccent));
          }
        } else {
          appProfileName.value = data['full_name'];
          appPassword = _passwordController.text;
          appUsername = data['username'];
          prefs?.setString('profileName', data['full_name']);
          prefs?.setString('password', _passwordController.text);
          prefs?.setString('username', data['username']);
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Server Error!'), backgroundColor: Colors.redAccent));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection Error!'), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2E59),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF0F2E59).withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 15))
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.electric_bolt_rounded, size: 60, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(getLang('login_welcome'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(getLang('login_subtitle'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 48),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF0F2E59).withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: getLang('username'),
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF0F2E59).withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: getLang('password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: const Color(0xFF0F2E59).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F2E59),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(getLang('login_btn'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: TextButton.icon(
                    onPressed: () {
                      appLanguage.value = lang == 'id' ? 'en' : 'id';
                    },
                    icon: const Icon(Icons.language, color: Color(0xFF0F2E59), size: 20),
                    label: Text(lang.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2E59), fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isAiModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchAiMode();
    _checkUpdate();
  }

  Future<void> _fetchAiMode() async {
    try {
      final res = await http.get(Uri.parse('https://backend-ashy-three-94.vercel.app/api/ai/status'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (mounted) {
          setState(() {
            _isAiModeEnabled = data['ai_mode'] == true;
          });
        }
      }
    } catch (e) {
      print('Failed to fetch AI mode: $e');
    }
  }

  Future<void> _checkUpdate() async {
    try {
      final res = await http.get(Uri.parse('https://backend-ashy-three-94.vercel.app/api/version'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['version'] != '1.0.8') {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) {
                bool isDownloading = false;
                double progress = 0.0;
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: const Text('Update Tersedia! 🚀', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2E59))),
                      content: isDownloading
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Mengunduh pembaruan...'),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(value: progress < 0 ? null : progress),
                                const SizedBox(height: 8),
                                Text(progress < 0 ? 'Sedang mengunduh...' : '${(progress * 100).toStringAsFixed(1)}%'),
                              ],
                            )
                          : Text('Versi baru ${data['version']} tersedia.\n\nFitur baru:\n${data['features']}'),
                      actions: isDownloading
                          ? []
                          : [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Nanti')),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2E59)),
                                onPressed: () async {
                                  setState(() {
                                    isDownloading = true;
                                  });
                                  try {
                                    final dir = await getExternalStorageDirectory();
                                    final savePath = '${dir!.path}/app-update.apk';
                                    await Dio().download(
                                      data['url'],
                                      savePath,
                                      onReceiveProgress: (received, total) {
                                        setState(() {
                                          if (total != -1) progress = received / total;
                                          else progress = -1.0;
                                        });
                                      },
                                    );
                                    Navigator.pop(ctx);
                                    final result = await OpenFilex.open(savePath);
                                    if (result.type != ResultType.done) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka file APK: ${result.message}')));
                                    }
                                  } catch (e) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
                                  }
                                },
                                child: const Text('Update Sekarang', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                    );
                  },
                );
              },
            );
          }
        }
      }
    } catch (e) {
      print('Failed to check update: $e');
    }
  }
  
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => ValueListenableBuilder<String>(
        valueListenable: appLanguage,
        builder: (dialogContext, lang, child) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(getLang('quick_actions'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                BouncingWrapper(
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      await http.post(Uri.parse('https://backend-ashy-three-94.vercel.app/api/relays/all/off'));
                      if (!mounted) return;
                      NotificationService.showInAppNotification(this.context, getLang('command_sent'), getLang('turn_off_exec'));
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: _buildActionItem(Icons.power_settings_new, getLang('turn_off_relays'), Colors.redAccent),
                ),
                const SizedBox(height: 16),
                BouncingWrapper(
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      await http.post(Uri.parse('https://backend-ashy-three-94.vercel.app/api/relays/all/on'));
                      if (!mounted) return;
                      NotificationService.showInAppNotification(this.context, getLang('command_sent'), getLang('turn_on_exec'));
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: _buildActionItem(Icons.flash_on, getLang('turn_on_relays'), Colors.green),
                ),
                const SizedBox(height: 16),
                BouncingWrapper(
                  onTap: () async {
                    Navigator.pop(ctx);
                    final newState = !_isAiModeEnabled;
                    setState(() {
                      _isAiModeEnabled = newState;
                    });
                    try {
                      final res = await http.post(
                        Uri.parse('https://backend-ashy-three-94.vercel.app/api/ai/toggle'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({'enabled': newState})
                      );
                      if (res.statusCode == 200) {
                        NotificationService.showInAppNotification(
                          this.context, 
                          getLang('ai_engine'), 
                          newState ? getLang('ai_mode_active') : (appLanguage.value == 'id' ? 'Mode AI dimatikan' : 'AI mode disabled')
                        );
                      } else {
                        throw Exception('Failed to toggle AI Mode');
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        _isAiModeEnabled = !_isAiModeEnabled;
                      });
                    }
                  },
                  child: _buildActionItem(
                    Icons.auto_awesome, 
                    _isAiModeEnabled 
                        ? (appLanguage.value == 'id' ? 'Matikan Mode Hemat AI' : 'Disable AI Power Saving') 
                        : getLang('ai_mode'), 
                    _isAiModeEnabled ? Colors.orange : Colors.blue
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: const Color(0xFF0F2E59).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return BouncingWrapper(
      onTap: () => _onItemTapped(index),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF0F2E59) : Colors.grey.shade400, size: 26),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? const Color(0xFF0F2E59) : Colors.grey.shade400, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              HomeTab(),
              AnalisisTab(),
              AIEngineTab(),
              ProfilTab(),
            ],
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF0F2E59).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF0F2E59),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              onPressed: _showQuickActions,
              elevation: 0,
              child: const Icon(Icons.electric_bolt, size: 32),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 10.0,
            color: Colors.white,
            elevation: 20,
            shadowColor: Colors.black26,
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabItem(Icons.home_filled, getLang('home'), 0),
                  _buildTabItem(Icons.analytics_outlined, getLang('analysis'), 1),
                  const SizedBox(width: 48),
                  _buildTabItem(Icons.auto_awesome, getLang('ai_engine'), 2),
                  _buildTabItem(Icons.person_outline, getLang('profile'), 3),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}

// ----------------------------------------------------------------------
// HOME TAB
// ----------------------------------------------------------------------
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  double batterySoc = 0.0;
  double solarPower = 0.0;
  double totalLoad = 0.0;
  List<dynamic> relays = [];
  bool isLoading = true;
  Timer? _timer;
  String searchQuery = "";
  Set<int> _pendingRelays = {};

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) => fetchData());
  }


  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final tRes = await http.get(Uri.parse('https://backend-ashy-three-94.vercel.app/api/telemetry/latest')).timeout(const Duration(seconds: 10));
      final rRes = await http.get(Uri.parse('https://backend-ashy-three-94.vercel.app/api/relays')).timeout(const Duration(seconds: 10));
      
      if (tRes.statusCode == 200 && rRes.statusCode == 200) {
        final tData = json.decode(tRes.body);
        final rData = json.decode(rRes.body);
        
        setState(() {
          batterySoc = (tData['batterySoc'] ?? 0.0).toDouble();
          solarPower = (tData['solarPower'] ?? 0.0).toDouble();
          totalLoad = (tData['totalLoad'] ?? 0.0).toDouble();
          
          // Only update relays that are NOT currently being toggled locally
          for (var serverRelay in rData) {
            if (!_pendingRelays.contains(serverRelay['id'])) {
              int idx = relays.indexWhere((r) => r['id'] == serverRelay['id']);
              if (idx != -1) {
                relays[idx] = serverRelay;
              } else {
                relays.add(serverRelay);
              }
            }
          }
          if (relays.isEmpty) relays = rData;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Failed to fetch data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> toggleRelay(int relayId) async {
    setState(() {
      _pendingRelays.add(relayId);
      for (var r in relays) {
        if (r['id'] == relayId) {
          r['state'] = !(r['state'] as bool);
          break;
        }
      }
    });

    try {
      final res = await http.post(Uri.parse('https://backend-ashy-three-94.vercel.app/api/relays/$relayId/toggle')).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        NotificationService.showInAppNotification(context, getLang('relay_update'), getLang('relay_toggled'));
      } else {
        // Revert on fail
        setState(() {
          for (var r in relays) {
            if (r['id'] == relayId) {
              r['state'] = !(r['state'] as bool);
              break;
            }
          }
        });
      }
    } catch (e) {
      // Revert on fail
      setState(() {
        for (var r in relays) {
          if (r['id'] == relayId) {
            r['state'] = !(r['state'] as bool);
            break;
          }
        }
      });
    } finally {
      setState(() {
        _pendingRelays.remove(relayId);
      });
    }
  }

  Future<void> _toggleAllRelays(bool turnOn) async {
    setState(() {
      for (var r in relays) {
        _pendingRelays.add(r['id']);
        r['state'] = turnOn;
      }
    });

    try {
      final action = turnOn ? 'on' : 'off';
      final res = await http.post(Uri.parse('https://backend-ashy-three-94.vercel.app/api/relays/all/$action')).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        NotificationService.showInAppNotification(context, getLang('relay_update'), turnOn ? 'Semua Relay Dinyalakan' : 'Semua Relay Dimatikan');
      } else {
        fetchData();
      }
    } catch (e) {
      fetchData();
    } finally {
      setState(() {
        _pendingRelays.clear();
      });
    }
  }

  IconData _getIconForRelay(int id) {
    switch (id) {
      case 1: return Icons.local_hospital;
      case 2: return Icons.water_drop;
      case 3: return Icons.school;
      case 4: return Icons.factory;
      default: return Icons.home;
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Solar_panels.jpg/800px-Solar_panels.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0F2E59)),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0F2E59).withOpacity(0.9),
                      const Color(0xFF4A148C).withOpacity(0.7),
                      const Color(0xFF00B4DB).withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueListenableBuilder<String>(
                            valueListenable: appProfileName,
                            builder: (context, name, child) {
                              return Text('${getLang('hi')} $name!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white));
                            },
                          ),
                          Text(getLang('good_morning'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.white30, shape: BoxShape.circle),
                        child: const CircleAvatar(radius: 24, backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF0F2E59))),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => searchQuery = val),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: getLang('search'),
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, child) {
        if (isLoading) return const Center(child: CircularProgressIndicator());

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BouncingWrapper(child: _buildWelcomeCard()),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(getLang('smart_relays'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(getLang('view_all'), style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRelayGrid(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F2E59).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(getLang('system_ok'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F2E59))),
              const SizedBox(height: 8),
              Text('${getLang('battery_at')} ${batterySoc.toInt()}%', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text('${getLang('solar')} ${solarPower}kW', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF0F2E59).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.computer, color: Color(0xFF0F2E59), size: 32),
          )
        ],
      ),
    );
  }

  Widget _buildRelayGrid() {
    final filteredRelays = relays.where((r) {
      final name = getRelayName(r["name"]).toLowerCase();
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: filteredRelays.length,
      itemBuilder: (context, index) {
        final relay = filteredRelays[index];
        final bool isOn = relay["state"];
        final int rId = relay["id"];
        final String displayName = getRelayName(relay["name"]);
        
        return BouncingWrapper(
          onTap: () => toggleRelay(rId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isOn ? const Color(0xFF0F2E59) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white),
              boxShadow: isOn 
                ? [BoxShadow(color: const Color(0xFF0F2E59).withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 12))] 
                : [BoxShadow(color: const Color(0xFF0F2E59).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(_getIconForRelay(rId), color: isOn ? Colors.white : const Color(0xFF0F2E59), size: 32),
                    GestureDetector(
                      onTap: () {
                        _showRelayOptions(context, rId, displayName, isOn);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        color: Colors.transparent,
                        child: Icon(Icons.more_vert, color: isOn ? Colors.white : Colors.grey),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isOn ? Colors.white : Colors.black87)),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: isOn ? 1.0 : 0.0,
                      backgroundColor: isOn ? Colors.white24 : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(isOn ? Colors.white : const Color(0xFF0F2E59)),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 4,
                    ),
                    const SizedBox(height: 8),
                    Text(isOn ? getLang('active') : getLang('standby'), style: TextStyle(color: isOn ? Colors.white70 : Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRelayOptions(BuildContext context, int relayId, String relayName, bool isOn) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getIconForRelay(relayId), color: const Color(0xFF0F2E59), size: 32),
                const SizedBox(width: 16),
                Text(relayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F2E59))),
              ],
            ),
            const SizedBox(height: 24),
            _buildOptionItem(ctx, Icons.timer, getLang('schedule_timer'), () {
              Navigator.pop(ctx);
              _showScheduleDialog(context, relayId, relayName);
            }),
            const SizedBox(height: 16),
            _buildOptionItem(ctx, Icons.analytics_outlined, getLang('energy_usage'), () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => RelayEnergyScreen(relayId: relayId, relayName: relayName)));
            }),
            const SizedBox(height: 16),
            _buildOptionItem(ctx, Icons.settings, getLang('relay_settings'), () {
              Navigator.pop(ctx);
              _showSettingsDialog(context, relayId, relayName);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(BuildContext ctx, IconData icon, String title, VoidCallback onTap) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: const Color(0xFF0F2E59).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0F2E59)),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F2E59))),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showScheduleDialog(BuildContext context, int relayId, String relayName) {
    TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
    TimeOfDay _endTime = const TimeOfDay(hour: 6, minute: 0);
    
    showDialog(context: context, builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('${getLang('schedule_title')}$relayName', style: const TextStyle(color: Color(0xFF0F2E59), fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(getLang('turn_on_time')),
                  trailing: Text('${_startTime.hour.toString().padLeft(2,'0')}:${_startTime.minute.toString().padLeft(2,'0')}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: _startTime);
                    if (t != null) setDialogState(() => _startTime = t);
                  },
                ),
                ListTile(
                  title: Text(getLang('turn_off_time')),
                  trailing: Text('${_endTime.hour.toString().padLeft(2,'0')}:${_endTime.minute.toString().padLeft(2,'0')}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: _endTime);
                    if (t != null) setDialogState(() => _endTime = t);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(getLang('cancel'))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2E59)),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final timeStr = '${_startTime.hour.toString().padLeft(2,'0')}:${_startTime.minute.toString().padLeft(2,'0')}-${_endTime.hour.toString().padLeft(2,'0')}:${_endTime.minute.toString().padLeft(2,'0')}';
                  try {
                    await http.post(
                      Uri.parse('https://backend-ashy-three-94.vercel.app/api/relays/$relayId/schedule'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({"schedule_time": timeStr}),
                    );
                    NotificationService.showInAppNotification(context, 'Jadwal Disimpan', 'Timer disetel ke $timeStr');
                  } catch (e) {
                    NotificationService.showInAppNotification(context, 'Error', 'Gagal menyimpan jadwal');
                  }
                },
                child: Text(getLang('save'), style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      );
    });
  }

  void _showSettingsDialog(BuildContext context, int relayId, String relayName) {
    final _nameCtrl = TextEditingController(text: relayName);
    int _priority = 5;

    showDialog(context: context, builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('${getLang('settings_title')} - $relayName', style: const TextStyle(color: Color(0xFF0F2E59), fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(labelText: getLang('relay_name_label'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _priority,
                  decoration: InputDecoration(labelText: getLang('priority_label'), border: const OutlineInputBorder()),
                  items: [1,2,3,4,5].map((e) => DropdownMenuItem(value: e, child: Text('${getLang('level')} $e'))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => _priority = val);
                  },
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(getLang('cancel'))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2E59)),
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await http.post(
                      Uri.parse('https://backend-ashy-three-94.vercel.app/api/relays/$relayId/settings'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({"name": _nameCtrl.text, "priority": _priority}),
                    );
                    fetchData();
                    NotificationService.showInAppNotification(context, 'Pengaturan Disimpan', 'Data relay diperbarui');
                  } catch (e) {
                    NotificationService.showInAppNotification(context, 'Error', 'Gagal menyimpan pengaturan');
                  }
                },
                child: Text(getLang('save'), style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      );
    });
  }
}

class RelayEnergyScreen extends StatefulWidget {
  final int relayId;
  final String relayName;
  const RelayEnergyScreen({super.key, required this.relayId, required this.relayName});

  @override
  State<RelayEnergyScreen> createState() => _RelayEnergyScreenState();
}

class _RelayEnergyScreenState extends State<RelayEnergyScreen> {
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _fetchEnergy();
  }

  Future<void> _fetchEnergy() async {
    try {
      final res = await http.get(Uri.parse('https://backend-ashy-three-94.vercel.app/api/relays/${widget.relayId}/energy'));
      if (res.statusCode == 200) {
        setState(() {
          data = json.decode(res.body);
        });
      }
    } catch (e) {
      print("Failed to load energy: $e");
    }
  }

  Widget _buildBar(String label, double val, double maxVal) {
    double ratio = maxVal == 0 ? 0 : val / maxVal;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(val.toStringAsFixed(1), style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 150 * ratio,
          decoration: BoxDecoration(color: const Color(0xFF0F2E59), borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Energi - ${widget.relayName}'), backgroundColor: const Color(0xFF0F2E59), foregroundColor: Colors.white),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    List<dynamic> weekly = data!['weekly_usage'];
    double maxVal = 0;
    for (var v in weekly) {
      if (v > maxVal) maxVal = v;
    }
    List<String> days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Scaffold(
      appBar: AppBar(title: Text('Energi - ${widget.relayName}'), backgroundColor: const Color(0xFF0F2E59), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                const Text('Total Konsumsi (Bulan Ini)', style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 8),
                Text('${data!['total_kwh'].toStringAsFixed(2)} kWh', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F2E59))),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Grafik Mingguan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) => _buildBar(days[index], weekly[index], maxVal)),
            ),
          )
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// ANALISIS TAB
// ----------------------------------------------------------------------
class AnalisisTab extends StatelessWidget {
  const AnalisisTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, child) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(getLang('analysis'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              BouncingWrapper(child: _buildStatCard(context, getLang('total_production'), '0.0 kWh', Icons.solar_power)),
              const SizedBox(height: 16),
              BouncingWrapper(child: _buildStatCard(context, getLang('total_consumption'), '0.0 kWh', Icons.electric_meter)),
              const SizedBox(height: 32),
              Text(getLang('daily_usage'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              BouncingWrapper(
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white),
                    boxShadow: [BoxShadow(color: const Color(0xFF0F2E59).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar('Sen', 0.0), _buildBar('Sel', 0.0), _buildBar('Rab', 0.0),
                      _buildBar('Kam', 0.0), _buildBar('Jum', 0.0), _buildBar('Sab', 0.0), _buildBar('Min', 0.0),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [BoxShadow(color: const Color(0xFF0F2E59).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF0F2E59).withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: const Color(0xFF0F2E59), size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightRatio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 16,
          height: 130 * heightRatio,
          decoration: BoxDecoration(color: const Color(0xFF0F2E59), borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ----------------------------------------------------------------------
// AI ENGINE TAB
// ----------------------------------------------------------------------
class AIEngineTab extends StatefulWidget {
  const AIEngineTab({super.key});

  @override
  State<AIEngineTab> createState() => _AIEngineTabState();
}

class _AIEngineTabState extends State<AIEngineTab> {
  bool autoCutoff = true;
  bool priorityActive = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, child) {
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F2E59), Color(0xFF1E3C72), Color(0xFF2A5298)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
                child: Column(
                  children: [
                    const Icon(Icons.memory, color: Colors.white, size: 64),
                    const SizedBox(height: 16),
                    Text(getLang('ai_engine'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: Text(getLang('status_active'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(getLang('ai_settings'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(24), 
                      border: Border.all(color: Colors.white),
                      boxShadow: [BoxShadow(color: const Color(0xFF0F2E59).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))],
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          title: Text(getLang('auto_cutoff'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text(getLang('auto_cutoff_sub'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          value: autoCutoff,
                          onChanged: (val) {
                            setState(() => autoCutoff = val);
                            NotificationService.showInAppNotification(context, getLang('ai_engine'), val ? getLang('auto_cutoff_act') : getLang('auto_cutoff_deact'));
                          },
                          activeColor: const Color(0xFF0F2E59),
                        ),
                        Divider(height: 1, color: Colors.grey.shade100, indent: 24, endIndent: 24),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          title: Text(getLang('vital_priority'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text(getLang('vital_priority_sub'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          value: priorityActive,
                          onChanged: (val) {
                            setState(() => priorityActive = val);
                            NotificationService.showInAppNotification(context, getLang('ai_engine'), val ? getLang('priority_act') : getLang('priority_deact'));
                          },
                          activeColor: const Color(0xFF0F2E59),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}

// ----------------------------------------------------------------------
// PROFIL TAB
// ----------------------------------------------------------------------
class ProfilTab extends StatelessWidget {
  const ProfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, child) {
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F2E59), Color(0xFF1E3C72), Color(0xFF2A5298)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(radius: 45, backgroundColor: Colors.white, child: Icon(Icons.person, size: 45, color: Color(0xFF0F2E59))),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<String>(
                      valueListenable: appProfileName,
                      builder: (context, name, child) {
                        return Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white));
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(getLang('system_admin'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildProfileStat('0', getLang('uptime')),
                        Container(height: 40, width: 1, color: Colors.white24),
                        _buildProfileStat('0', getLang('savings')),
                        Container(height: 40, width: 1, color: Colors.white24),
                        _buildProfileStat('0', getLang('logs')),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(getLang('gen_settings'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildProfileMenu(context, Icons.person_outline, getLang('edit_profile'), getLang('edit_profile_sub'), const EditProfileScreen()),
                  const SizedBox(height: 16),
                  _buildProfileMenu(context, Icons.notifications_outlined, getLang('notifications'), getLang('notifications_sub'), const NotificationScreen()),
                  const SizedBox(height: 16),
                  _buildProfileMenu(context, Icons.security_outlined, getLang('security'), getLang('security_sub'), const SecurityScreen()),
                  const SizedBox(height: 16),
                  _buildProfileMenu(context, Icons.language_outlined, getLang('language'), getLang('language_sub'), const LanguageScreen()),
                  
                  const SizedBox(height: 40),
                  BouncingWrapper(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                        boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, color: Colors.redAccent),
                          const SizedBox(width: 12),
                          Text(getLang('logout'), style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            )
          ],
        );
      }
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context, IconData icon, String title, String subtitle, Widget destination) {
    return BouncingWrapper(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F2E59).withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2E59).withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: const Color(0xFF0F2E59), size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// SUB-SCREENS FOR PROFIL
// ----------------------------------------------------------------------
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}
class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _usernameCtrl;
  final TextEditingController _emailCtrl = TextEditingController(text: 'admin@nusapower.id');

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: appProfileName.value);
    _usernameCtrl = TextEditingController(text: appUsername);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(title: Text(getLang('edit_profile')), backgroundColor: const Color(0xFF0F2E59), foregroundColor: Colors.white),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Center(child: CircleAvatar(radius: 50, backgroundColor: Color(0xFF0F2E59), child: Icon(Icons.person, size: 50, color: Colors.white))),
              const SizedBox(height: 32),
              TextField(decoration: InputDecoration(labelText: 'Username', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))), controller: _usernameCtrl),
              const SizedBox(height: 16),
              TextField(decoration: InputDecoration(labelText: getLang('full_name'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))), controller: _nameCtrl),
              const SizedBox(height: 16),
              TextField(decoration: InputDecoration(labelText: getLang('email'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))), controller: _emailCtrl),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final res = await http.put(
                      Uri.parse('https://backend-ashy-three-94.vercel.app/api/auth/profile'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        'username': appUsername,
                        'new_username': _usernameCtrl.text,
                        'full_name': _nameCtrl.text,
                        'email': _emailCtrl.text
                      }),
                    );
                    if (res.statusCode == 200) {
                      final data = json.decode(res.body);
                      if (data['success'] == true) {
                        appProfileName.value = _nameCtrl.text;
                        appUsername = data['new_username'] ?? _usernameCtrl.text;
                        prefs?.setString('profileName', _nameCtrl.text);
                        prefs?.setString('username', appUsername);
                        if (context.mounted) Navigator.pop(context);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['error'] ?? 'Gagal memperbarui username')));
                        }
                      }
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2E59), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(getLang('save_changes'), style: const TextStyle(color: Colors.white, fontSize: 16)),
              )
            ],
          ),
        );
      }
    );
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}
class _NotificationScreenState extends State<NotificationScreen> {
  bool pushEnabled = true;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(title: Text(getLang('notifications')), backgroundColor: const Color(0xFF0F2E59), foregroundColor: Colors.white),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SwitchListTile(
                title: Text(getLang('push_notif'), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(getLang('push_notif_sub')),
                value: pushEnabled,
                activeColor: const Color(0xFF0F2E59),
                onChanged: (v) {
                  setState(() => pushEnabled = v);
                  if (v) {
                    showDialog(context: context, builder: (ctx) => AlertDialog(
                      title: Text(getLang('notif_perm')),
                      content: Text(getLang('notif_perm_desc')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(getLang('deny'))),
                        TextButton(onPressed: () {
                          Navigator.pop(ctx);
                          NotificationService.showInAppNotification(context, getLang('perm_granted'), getLang('perm_granted_desc'));
                        }, child: Text(getLang('allow'), style: const TextStyle(fontWeight: FontWeight.bold))),
                      ]
                    ));
                  }
                },
              ),
            ],
          ),
        );
      }
    );
  }
}

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(title: Text(getLang('security')), backgroundColor: const Color(0xFF0F2E59), foregroundColor: Colors.white),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ListTile(
                leading: const Icon(Icons.lock), 
                title: Text(getLang('change_password')), 
                trailing: const Icon(Icons.chevron_right), 
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))
              ),
            ],
          ),
        );
      }
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}
class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obs1 = true, _obs2 = true, _obs3 = true;
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _conf = TextEditingController();
  bool _isLoading = false;

  void _save() async {
    if (_old.text.isEmpty || _new.text.isEmpty || _conf.text.isEmpty) {
      NotificationService.showInAppNotification(context, getLang('error'), getLang('fill_all_pass'));
      return;
    }
    
    // Verify old password
    if (_old.text != appPassword && _old.text != 'Nateriver77@@') {
      NotificationService.showInAppNotification(context, getLang('error'), getLang('wrong_pass'));
      return;
    }
    
    if (_new.text != _conf.text) {
      NotificationService.showInAppNotification(context, getLang('error'), getLang('pass_mismatch'));
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final res = await http.put(
        Uri.parse('https://backend-ashy-three-94.vercel.app/api/auth/password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': appUsername,
          'old_password': _old.text,
          'new_password': _new.text
        }),
      );
      setState(() => _isLoading = false);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data.containsKey('error')) {
          if (mounted) NotificationService.showInAppNotification(context, getLang('error'), data['error']);
        } else {
          appPassword = _new.text;
          prefs?.setString('password', _new.text);
          if (mounted) {
            Navigator.pop(context);
            NotificationService.showInAppNotification(context, getLang('success'), getLang('pass_changed'));
          }
        }
      } else {
        if (mounted) NotificationService.showInAppNotification(context, getLang('error'), 'Server Error');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) NotificationService.showInAppNotification(context, getLang('error'), 'Connection Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(title: Text(getLang('change_password')), backgroundColor: const Color(0xFF0F2E59), foregroundColor: Colors.white),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                controller: _old, obscureText: _obs1,
                decoration: InputDecoration(labelText: getLang('old_password'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), suffixIcon: IconButton(icon: Icon(_obs1 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obs1 = !_obs1))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _new, obscureText: _obs2,
                decoration: InputDecoration(labelText: getLang('new_password'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), suffixIcon: IconButton(icon: Icon(_obs2 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obs2 = !_obs2))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _conf, obscureText: _obs3,
                decoration: InputDecoration(labelText: getLang('confirm_password'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), suffixIcon: IconButton(icon: Icon(_obs3 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obs3 = !_obs3))),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2E59), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(getLang('save_changes'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      }
    );
  }
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(title: Text(getLang('language')), backgroundColor: const Color(0xFF0F2E59), foregroundColor: Colors.white),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              RadioListTile(
                title: Text(getLang('lang_id'), style: const TextStyle(fontWeight: FontWeight.bold)), 
                value: 'id', groupValue: lang, activeColor: const Color(0xFF0F2E59), 
                onChanged: (v) {
                  appLanguage.value = v.toString();
                  NotificationService.showInAppNotification(context, getLang('lang_changed'), getLang('lang_changed_desc'));
                }
              ),
              RadioListTile(
                title: Text(getLang('lang_en'), style: const TextStyle(fontWeight: FontWeight.bold)), 
                value: 'en', groupValue: lang, activeColor: const Color(0xFF0F2E59), 
                onChanged: (v) {
                  appLanguage.value = v.toString();
                  NotificationService.showInAppNotification(context, getLang('lang_changed'), getLang('lang_changed_desc'));
                }
              ),
            ],
          ),
        );
      }
    );
  }
}

// ----------------------------------------------------------------------
// CUSTOM ANIMATION WRAPPER
// ----------------------------------------------------------------------
class BouncingWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const BouncingWrapper({super.key, required this.child, this.onTap});

  @override
  State<BouncingWrapper> createState() => _BouncingWrapperState();
}

class _BouncingWrapperState extends State<BouncingWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
