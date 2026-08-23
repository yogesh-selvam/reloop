
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'features/listings/my_listings_screen.dart';
import 'features/auth/signup_screen.dart';

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
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          message = 'Login failed. Please try again.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                style: TextStyle(fontSize: 39, fontWeight: FontWeight.w800, color: ink),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your campus marketplace for smarter\nreuse.',
                style: TextStyle(fontSize: 23, height: 1.45, color: muted),
              ),
              const SizedBox(height: 82),
              const Label('College Email'),
              InputBox(
                controller: emailController,
                icon: Icons.school_outlined,
                hint: 'name@university.edu',
              ),
              const SizedBox(height: 42),
              const Label('Password'),
              InputBox(
                controller: passwordController,
                icon: Icons.lock_outline_rounded,
                hint: '••••••••',
                obscure: true,
              ),
              const SizedBox(height: 58),
              PrimaryButton(
                text: isLoading ? 'Signing in...' : 'Continue',
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
                        builder: (_) => const SignupScreen(),
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
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Text('OR', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: muted)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Text('G', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Colors.red)),
                label: const Text('Continue with College Google Account', style: TextStyle(fontSize: 17, color: ink)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(72),
                  side: const BorderSide(color: Color(0xFFC6D1C4), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 70),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD9E2FF)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: green, size: 32),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        'Only verified college\nstudents can access ReLoop.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, height: 1.5, color: muted, fontWeight: FontWeight.w600),
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
        padding: const EdgeInsets.fromLTRB(30, 18, 30, 30),
        children: [
          const AppHeader(),
          const SizedBox(height: 40),
          const Text(
            'Good morning, Arun 👋',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800, color: ink),
          ),
          const SizedBox(height: 8),
          const Text(
            'Make your next purchase a reuse.',
            style: TextStyle(fontSize: 19, color: muted),
          ),
          const SizedBox(height: 30),
          const SearchBox(),
          const SizedBox(height: 28),
          const ImpactCard(),
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
          const Text(
            'Recommended for you',
            style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: ink),
          ),
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
          const SizedBox(height: 34),
          const Text(
            'Latest Listings',
            style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: ink),
          ),
          const SizedBox(height: 18),
          const FirestoreListingsList(),
        ],
      ),
    );
  }
}

class FirestoreListingsList extends StatelessWidget {
  const FirestoreListingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('listings').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Unable to load listings right now.',
              style: TextStyle(color: muted, fontSize: 16),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator(color: green)),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: border),
            ),
            child: const Text(
              'No listings yet. Create your first listing from Sell.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: muted),
            ),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ProductCard(
                listingId: doc.id,
                title: (data['title'] ?? 'Untitled listing').toString(),
                price: _formatPrice(data['price']),
                condition: (data['condition'] ?? 'Condition not specified').toString(),
                distance: 'Nearby',
                icon: _iconForCategory(data['category']),
                impact: _impactForCategory(data['category']),
                sellerId: (data['sellerId'] ?? '').toString(),
                sellerName: (data['sellerName'] ?? data['sellerEmail'] ?? 'ReLoop Student').toString(),
                description: (data['description'] ?? '').toString(),
                category: (data['category'] ?? 'Other').toString(),
                listingType: (data['listingType'] ?? 'Sell').toString(),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

String _formatPrice(dynamic value) {
  if (value == null) return '₹0';
  if (value is num) {
    final number = value.toDouble();
    if (number == number.roundToDouble()) {
      return '₹${number.toInt()}';
    }
    return '₹${number.toStringAsFixed(2)}';
  }
  final text = value.toString().trim();
  return text.isEmpty ? '₹0' : (text.startsWith('₹') ? text : '₹$text');
}

IconData _iconForCategory(dynamic value) {
  switch (value?.toString()) {
    case 'Books':
      return Icons.menu_book_rounded;
    case 'Electronics':
      return Icons.devices_rounded;
    case 'Bags':
      return Icons.backpack_rounded;
    case 'Stationery':
      return Icons.edit_rounded;
    case 'Furniture':
      return Icons.chair_rounded;
    default:
      return Icons.inventory_2_outlined;
  }
}

String _impactForCategory(dynamic value) {
  switch (value?.toString()) {
    case 'Books':
      return '1.2 kg CO₂ saved';
    case 'Electronics':
      return '4.5 kg CO₂ saved';
    case 'Bags':
      return '2.1 kg CO₂ saved';
    case 'Stationery':
      return '0.5 kg CO₂ saved';
    default:
      return '1.0 kg CO₂ saved';
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
  final String? listingId;
  final String? sellerId;
  final String? sellerName;
  final String? description;
  final String? category;
  final String? listingType;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.condition,
    required this.distance,
    required this.icon,
    required this.impact,
    this.listingId,
    this.sellerId,
    this.sellerName,
    this.description,
    this.category,
    this.listingType,
  });

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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListingDetailsScreen(
                            listingId: listingId ?? '',
                            data: {
                              'title': title,
                              'price': price,
                              'condition': condition,
                              'distance': distance,
                              'impact': impact,
                              'sellerId': sellerId ?? '',
                              'sellerName': sellerName ?? 'ReLoop Student',
                              'description': description ?? '',
                              'category': category ?? 'Other',
                              'listingType': listingType ?? 'Sell',
                            },
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF9DF1B2),
                      foregroundColor: green,
                    ),
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


class ListingDetailsScreen extends StatelessWidget {
  final String listingId;
  final Map<String, dynamic> data;

  const ListingDetailsScreen({
    super.key,
    required this.listingId,
    required this.data,
  });

  Future<void> _requestItem(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to request this item.')),
      );
      return;
    }

    final sellerId = (data['sellerId'] ?? '').toString();

    if (sellerId.isNotEmpty && sellerId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot request your own listing.')),
      );
      return;
    }

    final listingTitle = (data['title'] ?? 'Untitled listing').toString();

    try {
      final duplicateQuery = await FirebaseFirestore.instance
          .collection('requests')
          .where('requesterId', isEqualTo: user.uid)
          .where('listingId', isEqualTo: listingId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (duplicateQuery.docs.isNotEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You already have a pending request for this item.'),
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('requests').add({
        'listingId': listingId,
        'listingTitle': listingTitle,
        'requesterId': user.uid,
        'requesterEmail': user.email ?? '',
        'sellerId': sellerId,
        'sellerName': (data['sellerName'] ?? 'ReLoop Student').toString(),
        'listingType': (data['listingType'] ?? 'Sell').toString(),
        'category': (data['category'] ?? 'Other').toString(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Request Sent'),
            content: Text(
              'Your request for "$listingTitle" has been sent to the seller.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Done'),
              ),
            ],
          );
        },
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Unable to send request.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] ?? 'Untitled listing').toString();
    final description =
    (data['description'] ?? 'No description provided.').toString();
    final condition =
    (data['condition'] ?? 'Condition not specified').toString();
    final category = (data['category'] ?? 'Other').toString();
    final listingType = (data['listingType'] ?? 'Sell').toString();
    final seller = (data['sellerName'] ?? 'ReLoop Student').toString();
    final price = (data['price'] ?? 'Price N/A').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Listing Details',
          style: TextStyle(
            color: ink,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(30, 18, 30, 35),
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1EA),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 100,
                color: green,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              price,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: green,
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _DetailChip(text: category),
                _DetailChip(text: condition),
                _DetailChip(text: listingType),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description.isEmpty
                        ? 'No description provided.'
                        : description,
                    style: const TextStyle(
                      fontSize: 17,
                      color: muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: green,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          seller,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            PrimaryButton(
              text: 'Request This Item',
              onTap: () => _requestItem(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String text;

  const _DetailChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: muted,
          fontWeight: FontWeight.w700,
        ),
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
          PrimaryButton(
            text: 'Create Listing',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateListingScreen(),
                ),
              );

              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Listing created successfully!'),
                  ),
                );
              }
            },
          ),
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

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  String category = 'Books';
  String condition = 'Good';
  String listingType = 'Sell';
  bool isSaving = false;

  final categories = const [
    'Books',
    'Electronics',
    'Bags',
    'Stationery',
    'Furniture',
    'Other',
  ];

  final conditions = const [
    'New',
    'Like New',
    'Good',
    'Fair',
  ];

  final listingTypes = const [
    'Sell',
    'Exchange',
    'Donate',
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> saveListing() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login again.')),
      );
      return;
    }

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill title and description.'),
        ),
      );
      return;
    }

    final price = double.tryParse(priceController.text.trim()) ?? 0;

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('listings').add({
        'title': title,
        'description': description,
        'category': category,
        'condition': condition,
        'listingType': listingType,
        'price': price,
        'sellerId': user.uid,
        'sellerEmail': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Unable to create listing.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Listing'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Listing',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),

              const SizedBox(height: 30),

              const Label('Item Title'),
              InputBox(
                controller: titleController,
                icon: Icons.title,
                hint: 'Enter item title',
              ),

              const SizedBox(height: 22),

              const Label('Description'),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Describe your item',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 22),

              const Label('Category'),
              DropdownButtonFormField<String>(
                initialValue: category,
                items: categories.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => category = value);
                  }
                },
              ),

              const SizedBox(height: 22),

              const Label('Condition'),
              DropdownButtonFormField<String>(
                initialValue: condition,
                items: conditions.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => condition = value);
                  }
                },
              ),

              const SizedBox(height: 22),

              const Label('Listing Type'),
              DropdownButtonFormField<String>(
                initialValue: listingType,
                items: listingTypes.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => listingType = value);
                  }
                },
              ),

              const SizedBox(height: 22),

              const Label('Price'),
              InputBox(
                controller: priceController,
                icon: Icons.currency_rupee,
                hint: 'Enter price',
              ),

              const SizedBox(height: 35),

              PrimaryButton(
                text: isSaving ? 'Saving...' : 'Save Listing',
                onTap: isSaving ? () {} : saveListing,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
          const SizedBox(height: 45),
          const Text(
            'Explore Listings',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 37, fontWeight: FontWeight.w800, color: ink),
          ),
          const SizedBox(height: 10),
          const Text(
            'Find items listed by students around you.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: muted),
          ),
          const SizedBox(height: 35),
          const FirestoreListingsList(),
          const SizedBox(height: 35),
          const Divider(height: 1),
          const SizedBox(height: 35),
          const Center(
            child: Text(
              '✨ Smart Matches',
              style: TextStyle(color: green, fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Perfect Match',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: ink),
          ),
          const SizedBox(height: 8),
          const Text(
            'We found students who need what you have.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, color: muted),
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR ITEM',
                        style: TextStyle(
                          fontSize: 15,
                          color: muted,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 22),
                      Row(
                        children: [
                          ItemIllustration(icon: Icons.menu_book_rounded),
                          SizedBox(width: 22),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Java Programming\nBook',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: ink,
                                    height: 1.4,
                                  ),
                                ),
                                Text(
                                  'Condition: Like New',
                                  style: TextStyle(fontSize: 17, color: muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.fromLTRB(28, 40, 28, 30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9AF0AB),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: green, size: 20),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Priya needs this book',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          ItemIllustration(icon: Icons.auto_stories_rounded),
                          SizedBox(width: 22),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SHE OFFERS',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: muted,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Python Programming\nBook',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: green,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),
          PrimaryButton(text: 'View Match', onTap: () {}),
          const SizedBox(height: 18),
          SizedBox(
            height: 70,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD2F2DA),
                foregroundColor: green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                'Start Exchange',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
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

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _completedExchanges(
      String uid,
      ) async {
    final requester = await FirebaseFirestore.instance
        .collection('requests')
        .where('requesterId', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .get();

    final seller = await FirebaseFirestore.instance
        .collection('requests')
        .where('sellerId', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .get();

    final unique = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final doc in requester.docs) {
      unique[doc.id] = doc;
    }
    for (final doc in seller.docs) {
      unique[doc.id] = doc;
    }
    return unique.values.toList();
  }

  double _co2ForCategory(String? category) {
    switch (category) {
      case 'Books':
        return 1.2;
      case 'Electronics':
        return 4.5;
      case 'Bags':
        return 2.1;
      case 'Stationery':
        return 0.5;
      case 'Furniture':
        return 8.0;
      default:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SafeArea(
        child: Center(child: Text('Please login to view your impact.')),
      );
    }

    return SafeArea(
      child: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        future: _completedExchanges(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: green));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  'Unable to load impact right now.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: muted),
                ),
              ),
            );
          }

          final completed = snapshot.data ?? [];
          final exchangeCount = completed.length;
          final reusedCount = exchangeCount;
          final co2 = completed.fold<double>(
            0,
                (sum, doc) => sum + _co2ForCategory(
              (doc.data()['category'] ?? 'Other').toString(),
            ),
          );
          final ecoPoints = exchangeCount * 50;
          final co2Text = co2 == co2.roundToDouble()
              ? co2.toInt().toString()
              : co2.toStringAsFixed(1);

          return ListView(
            padding: const EdgeInsets.fromLTRB(30, 18, 30, 30),
            children: [
              const AppHeader(),
              const SizedBox(height: 45),
              const Text(
                'Your Impact 🌱',
                style: TextStyle(fontSize: 37, fontWeight: FontWeight.w800, color: ink),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your completed exchanges are now counted here.',
                style: TextStyle(fontSize: 19, color: muted),
              ),
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
                    Text(
                      '$co2Text kg',
                      style: const TextStyle(fontSize: 61, fontWeight: FontWeight.w800, color: ink),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Estimated CO₂ saved',
                      style: TextStyle(fontSize: 23, color: green, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC7EBD2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.sync_alt_rounded, color: muted),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              exchangeCount == 0
                                  ? 'Complete your first exchange to start building your impact.'
                                  : '$exchangeCount completed exchange${exchangeCount == 1 ? '' : 's'} are contributing to your ReLoop impact.',
                              style: const TextStyle(fontSize: 17, color: muted, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      number: '$reusedCount',
                      label: 'Items Reused',
                      icon: Icons.eco_outlined,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: StatCard(
                      number: '$exchangeCount',
                      label: 'Exchanges',
                      icon: Icons.sync_alt_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      number: '0',
                      label: 'Donations',
                      icon: Icons.volunteer_activism_outlined,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: StatCard(
                      number: '$ecoPoints',
                      label: 'Eco Points',
                      icon: Icons.eco,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: green),
                        SizedBox(width: 12),
                        Text(
                          'Exchange Completion',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      exchangeCount == 0
                          ? 'Your completed exchanges will appear here automatically.'
                          : 'Every completed exchange increases your reuse count and estimated environmental impact.',
                      style: const TextStyle(fontSize: 16, color: muted, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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


class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateRequest(
      BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> doc,
      String status,
      ) async {
    if (_updating) return;

    setState(() => _updating = true);
    try {
      await doc.reference.update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'accepted'
                ? 'Request accepted successfully.'
                : 'Request rejected.',
          ),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Unable to update request.')),
      );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return green;
      case 'in_progress':
        return const Color(0xFF2563EB);
      case 'completed':
        return const Color(0xFF047857);
      case 'rejected':
        return Colors.red.shade700;
      default:
        return Colors.orange.shade800;
    }
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }

  void _openExchange(
      BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExchangeDetailsScreen(requestId: doc.id),
      ),
    );
  }

  Widget _requestCard(
      BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> doc, {
        required bool incoming,
      }) {
    final data = doc.data() ?? <String, dynamic>{};
    final title = (data['listingTitle'] ?? 'Untitled listing').toString();
    final listingType = (data['listingType'] ?? 'Sell').toString();
    final status = (data['status'] ?? 'pending').toString();
    final requesterEmail = (data['requesterEmail'] ?? 'Student').toString();
    final sellerName = (data['sellerName'] ?? 'ReLoop Student').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      incoming
                          ? 'Requested by $requesterEmail'
                          : 'Seller: $sellerName',
                      style: const TextStyle(color: muted, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _smallTag(listingType),
                        const SizedBox(width: 8),
                        _statusChip(status),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (incoming && status == 'pending') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _updating
                        ? null
                        : () => _updateRequest(context, doc, 'rejected'),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade200),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _updating
                        ? null
                        : () => _updateRequest(context, doc, 'accepted'),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (status == 'accepted' || status == 'in_progress') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openExchange(context, doc),
                icon: Icon(
                  status == 'accepted'
                      ? Icons.handshake_outlined
                      : Icons.sync_alt_rounded,
                ),
                label: Text(
                  status == 'accepted' ? 'Open Exchange' : 'Continue Exchange',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ] else if (status == 'completed') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_outlined, color: green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Exchange completed successfully.',
                      style: TextStyle(
                        color: green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (!incoming && status == 'rejected') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'The seller rejected your request.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _smallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _requestList({required bool incoming}) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login to view requests.'));
    }

    final field = incoming ? 'sellerId' : 'requesterId';

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where(field, isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load requests.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: green));
        }

        final docs = [...(snapshot.data?.docs ?? [])];
        docs.sort((a, b) {
          final aTime = a.data()['createdAt'];
          final bTime = b.data()['createdAt'];
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          return 0;
        });

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox_outlined, size: 58, color: muted),
                  const SizedBox(height: 14),
                  Text(
                    incoming ? 'No incoming requests yet.' : 'No requests yet.',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    incoming
                        ? 'Requests from students will appear here.'
                        : 'Items you request will appear here.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: muted),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
          itemCount: docs.length,
          itemBuilder: (context, index) => _requestCard(
            context,
            docs[index],
            incoming: incoming,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        foregroundColor: ink,
        elevation: 0,
        title: const Text(
          'Requests & Exchanges',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: green,
          unselectedLabelColor: muted,
          indicatorColor: green,
          tabs: const [
            Tab(text: 'Incoming'),
            Tab(text: 'My Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _requestList(incoming: true),
          _requestList(incoming: false),
        ],
      ),
    );
  }
}

class ExchangeDetailsScreen extends StatefulWidget {
  final String requestId;

  const ExchangeDetailsScreen({super.key, required this.requestId});

  @override
  State<ExchangeDetailsScreen> createState() => _ExchangeDetailsScreenState();
}

class _ExchangeDetailsScreenState extends State<ExchangeDetailsScreen> {
  bool _busy = false;

  DocumentReference<Map<String, dynamic>> get _requestRef =>
      FirebaseFirestore.instance.collection('requests').doc(widget.requestId);

  Future<void> _startExchange(Map<String, dynamic> data) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      await _requestRef.update({
        'status': 'in_progress',
        'startedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exchange started. Arrange the handover with the other student.')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Unable to start exchange.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _markCompleted(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _busy) return;

    setState(() => _busy = true);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(_requestRef);
        if (!snapshot.exists) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'not-found',
            message: 'Exchange request no longer exists.',
          );
        }

        final current = snapshot.data() ?? <String, dynamic>{};
        final requesterId = (current['requesterId'] ?? '').toString();
        final sellerId = (current['sellerId'] ?? '').toString();
        final currentStatus = (current['status'] ?? '').toString();

        if (currentStatus != 'in_progress' && currentStatus != 'accepted') {
          return;
        }

        final isRequester = requesterId == user.uid;
        final isSeller = sellerId == user.uid;

        if (!isRequester && !isSeller) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
            message: 'You are not part of this exchange.',
          );
        }

        final requesterCompleted =
            (current['requesterCompleted'] ?? false) == true || isRequester;
        final sellerCompleted =
            (current['sellerCompleted'] ?? false) == true || isSeller;

        final updates = <String, dynamic>{
          'status': requesterCompleted && sellerCompleted
              ? 'completed'
              : 'in_progress',
          'requesterCompleted': requesterCompleted,
          'sellerCompleted': sellerCompleted,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (requesterCompleted && sellerCompleted) {
          updates['completedAt'] = FieldValue.serverTimestamp();
        }

        transaction.update(_requestRef, updates);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your completion has been recorded.')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Unable to update exchange.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _statusTitle(String status) {
    switch (status) {
      case 'accepted':
        return 'Ready to Exchange';
      case 'in_progress':
        return 'Exchange in Progress';
      case 'completed':
        return 'Exchange Completed';
      default:
        return 'Exchange Details';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF047857);
      case 'in_progress':
        return const Color(0xFF2563EB);
      default:
        return green;
    }
  }

  Widget _step({
    required int number,
    required String title,
    required String subtitle,
    required bool active,
    required bool done,
  }) {
    final color = done || active ? green : const Color(0xFFB8C2BC);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? green : Colors.white,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
              '$number',
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: active || done ? ink : muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: muted, height: 1.35),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        foregroundColor: ink,
        elevation: 0,
        title: const Text(
          'Exchange Details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _requestRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  'Unable to load exchange.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: muted),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: green));
          }

          final data = snapshot.data!.data() ?? <String, dynamic>{};
          final title = (data['listingTitle'] ?? 'Untitled listing').toString();
          final listingType = (data['listingType'] ?? 'Sell').toString();
          final category = (data['category'] ?? 'Other').toString();
          final requesterEmail = (data['requesterEmail'] ?? 'Student').toString();
          final sellerName = (data['sellerName'] ?? 'ReLoop Student').toString();
          final sellerId = (data['sellerId'] ?? '').toString();
          final requesterId = (data['requesterId'] ?? '').toString();
          final status = (data['status'] ?? 'accepted').toString();
          final userId = FirebaseAuth.instance.currentUser?.uid;
          final isRequester = userId == requesterId;
          final myCompleted = isRequester
              ? (data['requesterCompleted'] ?? false) == true
              : (data['sellerCompleted'] ?? false) == true;
          final otherCompleted = isRequester
              ? (data['sellerCompleted'] ?? false) == true
              : (data['requesterCompleted'] ?? false) == true;

          final statusColor = _statusColor(status);
          final inProgress = status == 'in_progress';
          final completed = status == 'completed';

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 35),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.handshake_outlined, color: green, size: 34),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: ink),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '$category • $listingType',
                            style: const TextStyle(color: muted),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusTitle(status),
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Participants',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const CircleAvatar(backgroundColor: lightGreen, child: Icon(Icons.person, color: green)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Requester', style: TextStyle(color: muted, fontSize: 13)),
                              Text(requesterEmail, style: const TextStyle(fontWeight: FontWeight.w700, color: ink)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const CircleAvatar(backgroundColor: lightGreen, child: Icon(Icons.storefront_outlined, color: green)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Seller', style: TextStyle(color: muted, fontSize: 13)),
                              Text(sellerName, style: const TextStyle(fontWeight: FontWeight.w700, color: ink)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: [
                    _step(
                      number: 1,
                      title: 'Request accepted',
                      subtitle: 'Both students can now arrange the handover.',
                      active: true,
                      done: true,
                    ),
                    const SizedBox(height: 22),
                    _step(
                      number: 2,
                      title: 'Exchange in progress',
                      subtitle: 'Meet on campus and hand over the item.',
                      active: inProgress || completed,
                      done: completed || inProgress,
                    ),
                    const SizedBox(height: 22),
                    _step(
                      number: 3,
                      title: 'Exchange completed',
                      subtitle: 'Both participants confirm the handover.',
                      active: completed,
                      done: completed,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (!inProgress && !completed)
                PrimaryButton(
                  text: _busy ? 'Starting...' : 'Start Exchange',
                  onTap: _busy ? () {} : () => _startExchange(data),
                )
              else if (inProgress && !myCompleted)
                PrimaryButton(
                  text: _busy ? 'Saving...' : 'Mark as Completed',
                  onTap: _busy ? () {} : () => _markCompleted(data),
                )
              else if (inProgress && myCompleted)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            otherCompleted
                                ? 'Both participants confirmed. Completing exchange...'
                                : 'You confirmed completion. Waiting for the other participant.',
                            style: const TextStyle(color: green, fontWeight: FontWeight.w700, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_outlined, color: green),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Exchange completed. This reuse now counts toward your impact.',
                            style: TextStyle(color: green, fontWeight: FontWeight.w700, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD9E2FF)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Only mark the exchange as completed after the item has actually been handed over. Both participants must confirm completion.',
                        style: TextStyle(color: muted, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
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
            onTap: () {
              if (e.$1 == 'My Listings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyListingsScreen(),
                  ),
                );
              } else if (e.$1 == 'My Exchanges') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RequestsScreen(),
                  ),
                );
              }
            },
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
