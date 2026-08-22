import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/verify_email_screen.dart';
import 'core/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ReLoopApp());
}

class ReLoopApp extends StatelessWidget {
  const ReLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReLoop',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087A2F),
          brightness: Brightness.light,
        ),
        fontFamily: 'Arial',
      ),
      home: const SplashScreen(),
    );
  }
}

const green = Color(0xFF087A2F);
const lightGreen = Color(0xFFDDF8E6);
const ink = Color(0xFF111827);
const muted = Color(0xFF536055);
const border = Color(0xFFDCE4F5);

class ReLoopLogo extends StatelessWidget {
  final bool compact;
  const ReLoopLogo({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.all_inclusive_rounded, color: green, size: compact ? 34 : 42),
        const SizedBox(width: 7),
        Text(
          'ReLoop',
          style: TextStyle(
            color: green,
            fontSize: compact ? 28 : 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -.05),
            radius: 1.0,
            colors: [Color(0xFFFFFFFF), Color(0xFFF5F7FC)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 270,
                left: 45,
                right: 45,
                child: SizedBox(
                  height: 310,
                  child: CustomPaint(painter: LoopPainter()),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 350,
                      height: 350,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.08),
                            blurRadius: 35,
                            offset: const Offset(0, 18),
                          )
                        ],
                      ),
                      child: const ReLoopLogo(),
                    ),
                    const SizedBox(height: 75),
                    const Text(
                      'ReLoop',
                      style: TextStyle(
                        fontSize: 58,
                        fontWeight: FontWeight.w800,
                        color: ink,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Reuse. Exchange. Impact.',
                      style: TextStyle(fontSize: 22, color: muted),
                    ),
                  ],
                ),
              ),
              const Positioned(
                bottom: 45,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'CAMPUS CIRCULAR ECONOMY',
                    style: TextStyle(
                      color: green,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = green.withOpacity(.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawArc(
      Rect.fromLTWH(15, 20, size.width - 30, size.height - 40),
      -.8,
      4.9,
      false,
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );

      if (user == null) {
        throw Exception('Unable to login.');
      }

      await user.reload();

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('Unable to login.');
      }

      if (!currentUser.emailVerified) {
        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyEmailScreen(
              email: email,
            ),
          ),
        );

        return;
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainShell(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your email address first.'),
        ),
      );
      return;
    }

    try {
      await _authService.resetPassword(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent. Please check your inbox.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(44, 38, 44, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReLoopLogo(compact: true),

              const SizedBox(height: 92),

              const Text(
                'Welcome to ReLoop',
                style: TextStyle(
                  fontSize: 39,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Your campus marketplace for smarter\nreuse.',
                style: TextStyle(
                  fontSize: 23,
                  height: 1.45,
                  color: muted,
                ),
              ),

              const SizedBox(height: 65),

              const Label('College Email'),

              InputBox(
                controller: emailController,
                icon: Icons.school_outlined,
                hint: 'name@university.edu',
              ),

              const SizedBox(height: 30),

              const Label('Password'),

              InputBox(
                controller: passwordController,
                icon: Icons.lock_outline_rounded,
                hint: '••••••••',
                obscure: true,
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading ? null : forgotPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              PrimaryButton(
                text: isLoading
                    ? 'Signing in...'
                    : 'Continue',
                onTap: isLoading ? () {} : login,
              ),

              const SizedBox(height: 24),

              Center(
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'New to ReLoop? Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: green,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25,
                    ),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: muted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              OutlinedButton.icon(
                onPressed: () {},
                icon: const Text(
                  'G',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                  ),
                ),
                label: const Text(
                  'Continue with College Google Account',
                  style: TextStyle(
                    fontSize: 17,
                    color: ink,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize:
                  const Size.fromHeight(72),
                  side: const BorderSide(
                    color: Color(0xFFC6D1C4),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(22),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 70),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FF),
                  borderRadius:
                  BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD9E2FF),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: green,
                      size: 32,
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        'Only verified college\nstudents can access ReLoop.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: muted,
                          fontWeight: FontWeight.w600,
                        ),
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
}

class Label extends StatelessWidget {
  final String text;
  const Label(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 7, bottom: 13),
    child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ink)),
  );
}

class InputBox extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool obscure;
  final TextEditingController? controller;

  const InputBox({
    super.key,
    this.controller,
    required this.icon,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 19, color: ink),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: muted, size: 28),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7A847B), fontSize: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFC6D1C4), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: green, width: 2),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const PrimaryButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 74,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(width: 14),
            const Icon(Icons.arrow_forward_rounded, size: 28),
          ],
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final screens = const [
    HomeScreen(),
    ExploreScreen(),
    ListItemScreen(),
    ImpactScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        height: 82,
        backgroundColor: const Color(0xFFFBFBFF),
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        indicatorColor: const Color(0xFFDDF8E6),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline, size: 32), selectedIcon: Icon(Icons.add_circle, size: 32), label: 'Sell'),
          NavigationDestination(icon: Icon(Icons.eco_outlined), selectedIcon: Icon(Icons.eco), label: 'Impact'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  final bool avatar;
  const AppHeader({super.key, this.avatar = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (avatar)
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEAF1EA),
            child: const Icon(Icons.person, color: green),
          ),
        if (avatar) const SizedBox(width: 12),
        const Text('ReLoop', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800, color: green)),
        const Spacer(),
        const Icon(Icons.notifications_none_rounded, size: 32, color: muted),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(30, 18, 30, 20),
        children: [
          const AppHeader(),
          const SizedBox(height: 40),
          const Text('Good morning, Arun 👋', style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 8),
          const Text('Make your next purchase a reuse.', style: TextStyle(fontSize: 19, color: muted)),
          const SizedBox(height: 30),
          SearchBox(),
          const SizedBox(height: 28),
          ImpactCard(),
          const SizedBox(height: 34),
          const Text('Categories', style: TextStyle(fontSize: 18, color: muted)),
          const SizedBox(height: 13),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                CategoryChip(icon: Icons.menu_book_outlined, text: 'Books'),
                CategoryChip(icon: Icons.devices_outlined, text: 'Electronics'),
                CategoryChip(icon: Icons.backpack_outlined, text: 'Bags'),
                CategoryChip(icon: Icons.edit_outlined, text: 'Stationery'),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text('Recommended for you', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 18),
          const ProductCard(
            title: 'Java Programming Book',
            price: '₹120',
            condition: 'Good condition',
            distance: '0.5km',
            icon: Icons.menu_book_rounded,
            impact: '1.2 kg CO₂ saved',
          ),
          const SizedBox(height: 20),
          const ProductCard(
            title: 'Wireless Headphones',
            price: '₹8,500',
            condition: 'Like New',
            distance: '1.2km',
            icon: Icons.headphones_rounded,
            impact: '4.5 kg CO₂ saved',
          ),
        ],
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});
  @override
  Widget build(BuildContext context) => TextField(
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search, size: 30, color: muted),
      hintText: 'Search books, gadgets, bags...',
      hintStyle: const TextStyle(fontSize: 18, color: ink),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: border),
      ),
    ),
  );
}

class ImpactCard extends StatelessWidget {
  const ImpactCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          const Text('Your Eco Impact', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 23),
          const ImpactRow(icon: '🌱', text: '12.8 kg CO₂ estimated saved'),
          const ImpactRow(icon: '♻️', text: '8 Items reused'),
          const ImpactRow(icon: '🏆', text: '420 Eco points'),
          const SizedBox(height: 12),
          const Row(
            children: [
              Text('View my impact →', style: TextStyle(fontSize: 17, color: green, fontWeight: FontWeight.w700)),
              Spacer(),
              SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(value: .72, strokeWidth: 13, color: Color(0xFF12A84E), backgroundColor: lightGreen),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Level', style: TextStyle(color: green, fontWeight: FontWeight.w700)),
                        Text('3', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: ink)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ImpactRow extends StatelessWidget {
  final String icon, text;
  const ImpactRow({super.key, required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(children: [Text(icon, style: const TextStyle(fontSize: 22)), const SizedBox(width: 14), Text(text, style: const TextStyle(fontSize: 17, color: muted))]),
  );
}

class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const CategoryChip({super.key, required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.symmetric(horizontal: 17),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: border),
    ),
    child: Row(children: [Icon(icon, size: 21, color: ink), const SizedBox(width: 6), Text(text, style: const TextStyle(fontSize: 16, color: ink))]),
  );
}

class ProductCard extends StatelessWidget {
  final String title, price, condition, distance, impact;
  final IconData icon;
  const ProductCard({super.key, required this.title, required this.price, required this.condition, required this.distance, required this.icon, required this.impact});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            height: 190,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFF0F4EC), Color(0xFFE7EEE4)]),
            ),
            child: Stack(
              children: [
                Center(child: Icon(icon, size: 95, color: green.withOpacity(.22))),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: lightGreen, borderRadius: BorderRadius.circular(20)),
                    child: Text(impact, style: const TextStyle(color: muted, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 20, 20, 18),
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink))),
                  Text(price, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: green)),
                ]),
                const SizedBox(height: 15),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFFE8EDFC), borderRadius: BorderRadius.circular(8)),
                    child: Text(condition, style: const TextStyle(fontWeight: FontWeight.w600, color: muted)),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.location_on_outlined, size: 18, color: muted),
                  Text(distance, style: const TextStyle(color: muted)),
                ]),
                const Divider(height: 25),
                Row(children: [
                  const CircleAvatar(radius: 16, backgroundColor: green, child: Text('AK', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 10),
                  const Text('Arun Kumar', style: TextStyle(fontSize: 16, color: muted)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(backgroundColor: const Color(0xFF9DF1B2), foregroundColor: green),
                    child: const Text('View'),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListItemScreen extends StatelessWidget {
  const ListItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(36, 18, 36, 30),
        children: [
          const Row(
            children: [
              CircleAvatar(radius: 25, backgroundColor: Color(0xFFEAF1EA), child: Icon(Icons.person_outline, color: green, size: 30)),
              Spacer(),
              Text('ReLoop', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: green)),
              Spacer(),
              Icon(Icons.notifications_none_rounded, size: 32, color: muted),
            ],
          ),
          const SizedBox(height: 80),
          const Text('List an Item', textAlign: TextAlign.center, style: TextStyle(fontSize: 41, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 14),
          const Text('Let AI create your listing in seconds.', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: muted)),
          const SizedBox(height: 44),
          Container(
            height: 420,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE9F2E8), Color(0xFFD4DCD5)],
              ),
              border: Border.all(color: const Color(0xFFB8EAC4), width: 2),
            ),
            child: Stack(
              children: [
                Center(child: Icon(Icons.menu_book_rounded, size: 170, color: green.withOpacity(.12))),
                Positioned(
                  left: 72, right: 72, bottom: 35,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.94), borderRadius: BorderRadius.circular(35)),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: green),
                        SizedBox(width: 10),
                        Expanded(child: Text('AI is identifying your item...', style: TextStyle(fontSize: 16, color: ink))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          InfoCard(
            title: 'Suggested Title',
            icon: Icons.auto_awesome,
            child: const Text('Java Programming – Complete Reference', style: TextStyle(fontSize: 24, color: ink, height: 1.35)),
            footer: 'Detected: Java Programming Book',
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: MiniInfo(title: 'Category', value: '📖  Books')),
              SizedBox(width: 18),
              Expanded(child: MiniInfo(title: 'Condition', value: 'Good')),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: MiniInfo(title: 'Suggested Price', value: '₹150', big: true)),
              SizedBox(width: 18),
              Expanded(child: MiniInfo(title: 'Eco Impact', value: '🌿  1.2 kg CO₂\nsaved', greenCard: true)),
            ],
          ),
          const SizedBox(height: 45),
          PrimaryButton(text: 'Create Listing', onTap: () {}),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title, footer;
  final IconData icon;
  final Widget child;
  const InfoCard({super.key, required this.title, required this.icon, required this.child, required this.footer});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(36, 28, 30, 25),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: green, size: 22), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 16, color: muted, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 15),
      child,
      const Divider(height: 25),
      Text(footer, style: const TextStyle(fontSize: 15, color: muted, fontWeight: FontWeight.w600)),
    ]),
  );
}

class MiniInfo extends StatelessWidget {
  final String title, value;
  final bool big, greenCard;
  const MiniInfo({super.key, required this.title, required this.value, this.big = false, this.greenCard = false});
  @override
  Widget build(BuildContext context) => Container(
    height: 145,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: greenCard ? const Color(0xFFD9F8E2) : Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: greenCard ? const Color(0xFF6EE88E) : border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16, color: muted, fontWeight: FontWeight.w600)),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: big ? 29 : 18, color: big ? green : ink, fontWeight: FontWeight.w700, height: 1.4)),
    ]),
  );
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(30, 18, 30, 30),
        children: [
          const AppHeader(),
          const SizedBox(height: 55),
          const Center(child: Text('✨ Perfect Match Found', style: TextStyle(color: green, fontSize: 17, fontWeight: FontWeight.w700))),
          const SizedBox(height: 28),
          const Text('Smart Matches', textAlign: TextAlign.center, style: TextStyle(fontSize: 37, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 10),
          const Text('We found students who need what you have.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: muted)),
          const SizedBox(height: 48),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: border)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('YOUR ITEM', style: TextStyle(fontSize: 15, color: muted, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    const SizedBox(height: 22),
                    Row(children: [
                      ItemIllustration(icon: Icons.menu_book_rounded),
                      const SizedBox(width: 22),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Java Programming\nBook', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink, height: 1.4)),
                        Text('Condition: Like New', style: TextStyle(fontSize: 17, color: muted)),
                      ])),
                    ]),
                  ]),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.fromLTRB(28, 40, 28, 30),
                  decoration: BoxDecoration(color: const Color(0xFF9AF0AB), borderRadius: BorderRadius.circular(25)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [
                      CircleAvatar(radius: 17, backgroundColor: Colors.white, child: Icon(Icons.person, color: green, size: 20)),
                      SizedBox(width: 12),
                      Text('Priya needs this book', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: green)),
                    ]),
                    const SizedBox(height: 25),
                    Row(children: [
                      ItemIllustration(icon: Icons.auto_stories_rounded),
                      const SizedBox(width: 22),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('SHE OFFERS', style: TextStyle(fontSize: 14, color: muted, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        SizedBox(height: 8),
                        Text('Python Programming\nBook', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: green, height: 1.35)),
                      ])),
                    ]),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 45),
          PrimaryButton(text: 'View Match', onTap: () {}),
          const SizedBox(height: 18),
          SizedBox(
            height: 70,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD2F2DA),
                foregroundColor: green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: const Text('Start Exchange', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemIllustration extends StatelessWidget {
  final IconData icon;
  const ItemIllustration({super.key, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    width: 145,
    height: 125,
    decoration: BoxDecoration(
      color: const Color(0xFFF1F3F1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Icon(icon, size: 65, color: green.withOpacity(.35)),
  );
}

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(30, 18, 30, 30),
        children: [
          const AppHeader(),
          const SizedBox(height: 45),
          const Text('Your Impact 🌱', style: TextStyle(fontSize: 37, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 10),
          const Text('Track your environmental contributions.', style: TextStyle(fontSize: 19, color: muted)),
          const SizedBox(height: 38),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 55, horizontal: 25),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FFF4),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFB8D4BF)),
            ),
            child: Column(
              children: [
                const Text('12.8 kg', style: TextStyle(fontSize: 61, fontWeight: FontWeight.w800, color: ink)),
                const SizedBox(height: 8),
                const Text('Estimated CO₂ saved', style: TextStyle(fontSize: 23, color: green, fontWeight: FontWeight.w600)),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: const Color(0xFFC7EBD2), borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    children: [
                      CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.directions_car_filled_outlined, color: muted)),
                      SizedBox(width: 18),
                      Expanded(child: Text("That's approximately equivalent to avoiding 52 km of car travel.", style: TextStyle(fontSize: 17, color: muted, height: 1.35))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Row(children: [
            Expanded(child: StatCard(number: '8', label: 'Items Reused', icon: Icons.eco_outlined)),
            SizedBox(width: 18),
            Expanded(child: StatCard(number: '5', label: 'Exchanges', icon: Icons.sync_alt_rounded)),
          ]),
          const SizedBox(height: 18),
          const Row(children: [
            Expanded(child: StatCard(number: '2', label: 'Donations', icon: Icons.volunteer_activism_outlined)),
            SizedBox(width: 18),
            Expanded(child: StatCard(number: '420', label: 'Eco Points', icon: Icons.eco)),
          ]),
          const SizedBox(height: 30),
          Container(
            height: 280,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.bar_chart_rounded, color: muted),
                SizedBox(width: 12),
                Text('Your Reuse Journey', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
              ]),
              const SizedBox(height: 25),
              Expanded(
                child: CustomPaint(
                  painter: ChartPainter(),
                  child: const SizedBox.expand(),
                ),
              ),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Text('M'), Text('T'), Text('W'), Text('T'), Text('F'), Text('S'), Text('S'),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String number, label;
  final IconData icon;
  const StatCard({super.key, required this.number, required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    height: 180,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFFB8D4BF))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(radius: 24, backgroundColor: lightGreen, child: Icon(icon, color: green)),
      const Spacer(),
      Text(number, style: const TextStyle(fontSize: 31, fontWeight: FontWeight.w800, color: ink)),
      Text(label, style: const TextStyle(fontSize: 14, color: muted, fontWeight: FontWeight.w600)),
    ]),
  );
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = const Color(0xFFE6E9E7)..strokeWidth = 1;
    for (int i = 0; i < 3; i++) {
      final y = size.height * (i + 1) / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final line = Paint()
      ..color = green
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(10, size.height * .82)
      ..lineTo(size.width * .20, size.height * .60)
      ..lineTo(size.width * .35, size.height * .70)
      ..lineTo(size.width * .50, size.height * .35)
      ..lineTo(size.width * .67, size.height * .52)
      ..lineTo(size.width * .82, size.height * .25)
      ..lineTo(size.width - 10, size.height * .40);
    canvas.drawPath(path, line);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(30, 18, 30, 30),
        children: [
          const AppHeader(),
          const SizedBox(height: 50),
          const Center(child: CircleAvatar(radius: 55, backgroundColor: lightGreen, child: Icon(Icons.person, size: 65, color: green))),
          const SizedBox(height: 18),
          const Text('Arun Kumar', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink)),
          const Text('Computer Science • Verified Student ✓', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 16)),
          const SizedBox(height: 35),
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: border)),
            child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ProfileStat('12', 'Listings'),
              ProfileStat('8', 'Reuses'),
              ProfileStat('420', 'Eco Points'),
            ]),
          ),
          const SizedBox(height: 25),
          ...[
            ('My Listings', Icons.inventory_2_outlined),
            ('My Exchanges', Icons.sync_alt),
            ('Saved Items', Icons.bookmark_border),
            ('Impact History', Icons.history),
            ('Notifications', Icons.notifications_none),
            ('Settings', Icons.settings_outlined),
          ].map((e) => ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 3),
            leading: Icon(e.$2, color: green),
            title: Text(e.$1, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          )),
        ],
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String number, label;
  const ProfileStat(this.number, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(number, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: green)),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: muted)),
  ]);
}
