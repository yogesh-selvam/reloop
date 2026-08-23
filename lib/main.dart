

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

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final searchController = TextEditingController();
  String category = 'All';
  String sortBy = 'Newest';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(30, 18, 30, 30),
        children: [
          const AppHeader(),
          const SizedBox(height: 34),
          const Text(
            'Explore',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800, color: ink),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find something worth reusing.',
            style: TextStyle(fontSize: 19, color: muted),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: muted),
              hintText: 'Search listings...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: border),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Books', 'Electronics', 'Bags', 'Stationery', 'Furniture', 'Other']
                  .map((item) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(item),
                  selected: category == item,
                  onSelected: (_) => setState(() => category = item),
                ),
              ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: DropdownButton<String>(
              value: sortBy,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'Newest', child: Text('Newest')),
                DropdownMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
                DropdownMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => sortBy = value);
              },
            ),
          ),
          const SizedBox(height: 8),
          FirestoreListingsList(
            searchQuery: searchController.text,
            category: category,
            sortBy: sortBy,
          ),
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
    final user = FirebaseAuth.instance.currentUser;

    return Row(
      children: [
        if (avatar)
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEAF1EA),
            child: const Icon(Icons.person, color: green),
          ),
        if (avatar) const SizedBox(width: 12),
        const Text(
          'ReLoop',
          style: TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w800,
            color: green,
          ),
        ),
        const Spacer(),
        if (user == null)
          const Icon(
            Icons.notifications_none_rounded,
            size: 32,
            color: muted,
          )
        else
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('notifications')
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data?.docs.length ?? 0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    tooltip: 'Notifications',
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 32,
                      color: muted,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 3,
                      top: 1,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
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
  final String searchQuery;
  final String category;
  final String sortBy;

  const FirestoreListingsList({
    super.key,
    this.searchQuery = '',
    this.category = 'All',
    this.sortBy = 'Newest',
  });

  double _price(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '') ?? 0;
  }

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

        final query = searchQuery.trim().toLowerCase();
        final docs = (snapshot.data?.docs ?? []).where((doc) {
          final data = doc.data();
          final itemCategory = (data['category'] ?? 'Other').toString();
          final searchable = [
            data['title'],
            data['description'],
            data['sellerName'],
            data['sellerEmail'],
            itemCategory,
          ].map((value) => value?.toString().toLowerCase() ?? '').join(' ');

          final matchesSearch = query.isEmpty || searchable.contains(query);
          final matchesCategory = category == 'All' || itemCategory == category;
          return matchesSearch && matchesCategory;
        }).toList();

        docs.sort((a, b) {
          final aData = a.data();
          final bData = b.data();
          if (sortBy == 'Price: Low to High') {
            return _price(aData['price']).compareTo(_price(bData['price']));
          }
          if (sortBy == 'Price: High to Low') {
            return _price(bData['price']).compareTo(_price(aData['price']));
          }

          final aTime = aData['createdAt'];
          final bTime = bData['createdAt'];
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          if (aTime is Timestamp) return -1;
          if (bTime is Timestamp) return 1;
          return 0;
        });

        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded, size: 48, color: muted),
                const SizedBox(height: 12),
                const Text(
                  'No listings found.',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: ink),
                ),
                if (query.isNotEmpty || category != 'All') ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Try another search or category.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: muted),
                  ),
                ],
              ],
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
                if (listingId != null && listingId!.isNotEmpty)
                  Positioned(
                    top: 15,
                    left: 15,
                    child: _SaveListingButton(listingId: listingId!),
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

  Future<void> _reportListing(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to report a listing.')),
      );
      return;
    }

    final sellerId = (data['sellerId'] ?? '').toString();

    if (sellerId.isNotEmpty && sellerId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot report your own listing.')),
      );
      return;
    }

    const reasons = [
      'Fake or scam listing',
      'Wrong information',
      'Inappropriate content',
      'Duplicate listing',
      'Other',
    ];

    String? selectedReason;

    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Report Listing',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: reasons.map((item) {
                  return RadioListTile<String>(
                    value: item,
                    groupValue: selectedReason,
                    title: Text(item),
                    activeColor: green,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedReason = value;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () => Navigator.pop(
                    dialogContext,
                    selectedReason,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit Report'),
                ),
              ],
            );
          },
        );
      },
    );

    if (reason == null) return;

    try {
      final existingReport = await FirebaseFirestore.instance
          .collection('reports')
          .where('reporterId', isEqualTo: user.uid)
          .where('listingId', isEqualTo: listingId)
          .limit(1)
          .get();

      if (existingReport.docs.isNotEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already reported this listing.'),
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('reports').add({
        'listingId': listingId,
        'listingTitle': (data['title'] ?? 'Untitled listing').toString(),
        'sellerId': sellerId,
        'sellerName': (data['sellerName'] ?? 'ReLoop Student').toString(),
        'reporterId': user.uid,
        'reporterEmail': user.email ?? '',
        'reason': reason,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully.'),
        ),
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Unable to submit report.'),
        ),
      );
    }
  }

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

      final requestRef = await FirebaseFirestore.instance.collection('requests').add({
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

      if (sellerId.isNotEmpty) {
        await NotificationService.requestReceived(
          sellerId: sellerId,
          requesterEmail: user.email ?? 'A student',
          listingTitle: listingTitle,
          requestId: requestRef.id,
          listingId: listingId,
        );
      }

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
            OutlinedButton.icon(
              onPressed: () => _reportListing(context),
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Report Listing'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade300),
                minimumSize: const Size.fromHeight(58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 14),
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

class ListItemScreen extends StatefulWidget {
  const ListItemScreen({super.key});

  @override
  State<ListItemScreen> createState() => _ListItemScreenState();
}

class _ListItemScreenState extends State<ListItemScreen> {
  bool _isAnalyzing = false;
  bool _analysisComplete = true;

  Future<void> _runAiDemo() async {
    setState(() {
      _isAnalyzing = true;
      _analysisComplete = false;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _analysisComplete = true;
    });
  }

  Future<void> _openCreateListing() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateListingScreen(
          aiAssisted: true,
          suggestedTitle: 'Java Programming – Complete Reference',
          suggestedDescription:
          'Java programming book in good condition. Useful for students learning Java and preparing for programming interviews.',
          suggestedCategory: 'Books',
          suggestedCondition: 'Good',
          suggestedPrice: '150',
          suggestedEcoImpact: '1.2 kg CO₂ saved',
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing created successfully!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(36, 18, 36, 30),
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFFEAF1EA),
                child: Icon(
                  Icons.person_outline,
                  color: green,
                  size: 30,
                ),
              ),
              Spacer(),
              Text(
                'ReLoop',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: green,
                ),
              ),
              Spacer(),
              Icon(
                Icons.notifications_none_rounded,
                size: 32,
                color: muted,
              ),
            ],
          ),
          const SizedBox(height: 80),
          const Text(
            'List an Item',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 41,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Let AI create your listing in seconds.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: muted),
          ),
          const SizedBox(height: 44),
          Container(
            height: 420,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE9F2E8),
                  Color(0xFFD4DCD5),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFB8EAC4),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 170,
                    color: green.withOpacity(.12),
                  ),
                ),
                Positioned(
                  left: 42,
                  right: 42,
                  bottom: 28,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.94),
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isAnalyzing
                              ? Icons.auto_awesome
                              : Icons.check_circle,
                          color: green,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isAnalyzing
                                ? 'AI is identifying your item...'
                                : 'AI suggestions are ready to review.',
                            style: const TextStyle(
                              fontSize: 16,
                              color: ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _isAnalyzing ? null : _runAiDemo,
            icon: const Icon(Icons.auto_awesome),
            label: Text(
              _analysisComplete
                  ? 'Re-analyze Item'
                  : 'Analyzing...',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: green,
              minimumSize: const Size.fromHeight(54),
              side: const BorderSide(color: green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 34),
          InfoCard(
            title: 'Suggested Title',
            icon: Icons.auto_awesome,
            child: const Text(
              'Java Programming – Complete Reference',
              style: TextStyle(
                fontSize: 24,
                color: ink,
                height: 1.35,
              ),
            ),
            footer: 'Detected: Java Programming Book',
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(
                child: MiniInfo(
                  title: 'Category',
                  value: '📖  Books',
                ),
              ),
              SizedBox(width: 18),
              Expanded(
                child: MiniInfo(
                  title: 'Condition',
                  value: 'Good',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: MiniInfo(
                  title: 'Suggested Price',
                  value: '₹150',
                  big: true,
                ),
              ),
              SizedBox(width: 18),
              Expanded(
                child: MiniInfo(
                  title: 'Eco Impact',
                  value: '🌿  1.2 kg CO₂\nsaved',
                  greenCard: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F8F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD7E9D8)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: green),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI suggestions are only recommendations. '
                        'Review and edit them before publishing.',
                    style: TextStyle(
                      fontSize: 15,
                      color: muted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          PrimaryButton(
            text: 'Review & Create Listing',
            onTap: _openCreateListing,
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

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(36, 28, 30, 25),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: green, size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        child,
        const Divider(height: 25),
        Text(
          footer,
          style: const TextStyle(
            fontSize: 15,
            color: muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class MiniInfo extends StatelessWidget {
  final String title, value;
  final bool big, greenCard;

  const MiniInfo({
    super.key,
    required this.title,
    required this.value,
    this.big = false,
    this.greenCard = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 145,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: greenCard ? const Color(0xFFD9F8E2) : Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: greenCard ? const Color(0xFF6EE88E) : border,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: big ? 29 : 18,
            color: big ? green : ink,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

class CreateListingScreen extends StatefulWidget {
  final bool aiAssisted;
  final String suggestedTitle;
  final String suggestedDescription;
  final String suggestedCategory;
  final String suggestedCondition;
  final String suggestedPrice;
  final String suggestedEcoImpact;

  const CreateListingScreen({
    super.key,
    this.aiAssisted = false,
    this.suggestedTitle = '',
    this.suggestedDescription = '',
    this.suggestedCategory = 'Books',
    this.suggestedCondition = 'Good',
    this.suggestedPrice = '',
    this.suggestedEcoImpact = '1.2 kg CO₂ saved',
  });

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;

  late String category;
  late String condition;
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
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.suggestedTitle,
    );
    descriptionController = TextEditingController(
      text: widget.suggestedDescription,
    );
    priceController = TextEditingController(
      text: widget.suggestedPrice,
    );

    category = categories.contains(widget.suggestedCategory)
        ? widget.suggestedCategory
        : 'Books';

    condition = conditions.contains(widget.suggestedCondition)
        ? widget.suggestedCondition
        : 'Good';
  }

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
    final priceText = priceController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill title and description.'),
        ),
      );
      return;
    }

    final price = double.tryParse(priceText) ?? 0;

    if (listingType == 'Sell' && price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price.'),
        ),
      );
      return;
    }

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
        'aiAssisted': widget.aiAssisted,
        'aiSuggestedTitle': widget.suggestedTitle,
        'aiSuggestedPrice':
        double.tryParse(widget.suggestedPrice) ?? price,
        'ecoImpact': widget.suggestedEcoImpact,
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
        title: Text(
          widget.aiAssisted
              ? 'Review AI Listing'
              : 'Create Listing',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.aiAssisted
                    ? 'Review Your Listing'
                    : 'Create Listing',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 10),
              if (widget.aiAssisted)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8ED),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFB8EAC4),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: green,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'AI generated these suggestions. '
                              'You can edit anything before publishing.',
                          style: TextStyle(
                            color: muted,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 28),
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
                decoration: InputDecoration(
                  hintText: 'Describe your item',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
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
              const SizedBox(height: 22),
              if (widget.aiAssisted)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9F8E2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6EE88E),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.eco_outlined,
                        color: green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Estimated eco impact: '
                              '${widget.suggestedEcoImpact}',
                          style: const TextStyle(
                            color: ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 35),
              PrimaryButton(
                text: isSaving
                    ? 'Publishing...'
                    : 'Publish Listing',
                onTap: isSaving ? () {} : saveListing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _completedExchanges(String uid) async {
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

    final result = unique.values.toList();
    result.sort((a, b) {
      final aTime = a.data()['completedAt'];
      final bTime = b.data()['completedAt'];
      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }
      if (aTime is Timestamp) return -1;
      if (bTime is Timestamp) return 1;
      return 0;
    });
    return result;
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

  String _formatDate(dynamic value) {
    if (value is! Timestamp) return 'Completed';
    final date = value.toDate();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
                (total, doc) => total +
                _co2ForCategory((doc.data()['category'] ?? 'Other').toString()),
          );
          final ecoPoints = exchangeCount * 50;
          final co2Text = co2 == co2.roundToDouble()
              ? co2.toInt().toString()
              : co2.toStringAsFixed(1);

          return ListView(
            padding: const EdgeInsets.fromLTRB(30, 18, 30, 30),
            children: [
              const AppHeader(),
              const SizedBox(height: 35),
              const Text(
                'Impact History 🌱',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your completed exchanges and environmental impact.',
                style: TextStyle(fontSize: 17, color: muted),
              ),
              const SizedBox(height: 25),

              // Summary
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1FFF4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFB8D4BF)),
                ),
                child: Column(
                  children: [
                    Text(
                      '$co2Text kg',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Estimated CO₂ saved',
                      style: TextStyle(
                        fontSize: 18,
                        color: green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ImpactMiniStat('$reusedCount', 'Items Reused'),
                        _ImpactMiniStat('$exchangeCount', 'Exchanges'),
                        _ImpactMiniStat('$ecoPoints', 'Eco Points'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                'Completed Exchanges',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 14),

              if (completed.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: border),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.eco_outlined, size: 48, color: green),
                      SizedBox(height: 12),
                      Text(
                        'No completed exchanges yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Complete an exchange and it will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted),
                      ),
                    ],
                  ),
                )
              else
                ...completed.map((doc) {
                  final data = doc.data();
                  final title =
                  (data['listingTitle'] ?? 'Completed exchange').toString();
                  final category =
                  (data['category'] ?? 'Other').toString();
                  final co2Saved = _co2ForCategory(category);
                  final role = data['requesterId'] == user.uid
                      ? 'Requested by you'
                      : 'Your listing';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: lightGreen,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.handshake_outlined,
                            color: green,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: ink,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '$category • $role',
                                style: const TextStyle(color: muted),
                              ),
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 15,
                                    color: muted,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _formatDate(data['completedAt']),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: muted,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Icon(
                                    Icons.eco_outlined,
                                    size: 17,
                                    color: green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${co2Saved.toStringAsFixed(1)} kg CO₂',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: green,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _ImpactMiniStat extends StatelessWidget {
  final String number;
  final String label;

  const _ImpactMiniStat(this.number, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: green,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: muted),
        ),
      ],
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


class NotificationService {
  static CollectionReference<Map<String, dynamic>> _userNotifications(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications');
  }

  static Future<void> create({
    required String uid,
    required String type,
    required String title,
    required String message,
    String? requestId,
    String? chatId,
    String? listingId,
  }) async {
    if (uid.isEmpty) return;

    await _userNotifications(uid).add({
      'type': type,
      'title': title,
      'message': message,
      'isRead': false,
      'requestId': requestId ?? '',
      'chatId': chatId ?? '',
      'listingId': listingId ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> requestReceived({
    required String sellerId,
    required String requesterEmail,
    required String listingTitle,
    required String requestId,
    required String listingId,
  }) async {
    await create(
      uid: sellerId,
      type: 'request_received',
      title: 'New Request',
      message: '$requesterEmail requested "$listingTitle".',
      requestId: requestId,
      listingId: listingId,
    );
  }

  static Future<void> requestStatusChanged({
    required String requesterId,
    required String listingTitle,
    required String requestId,
    required String listingId,
    required bool accepted,
  }) async {
    await create(
      uid: requesterId,
      type: accepted ? 'request_accepted' : 'request_rejected',
      title: accepted ? 'Request Accepted' : 'Request Rejected',
      message: accepted
          ? 'Your request for "$listingTitle" was accepted by the seller.'
          : 'Your request for "$listingTitle" was rejected by the seller.',
      requestId: requestId,
      listingId: listingId,
    );
  }

  static Future<void> exchangeStarted({
    required String uid,
    required String listingTitle,
    required String requestId,
    required String listingId,
  }) async {
    await create(
      uid: uid,
      type: 'exchange_started',
      title: 'Exchange Started',
      message: 'The exchange for "$listingTitle" is now in progress.',
      requestId: requestId,
      listingId: listingId,
    );
  }

  static Future<void> completionConfirmed({
    required String uid,
    required String listingTitle,
    required String requestId,
    required String listingId,
  }) async {
    await create(
      uid: uid,
      type: 'exchange_completed',
      title: 'Exchange Completed',
      message: 'The exchange for "$listingTitle" has been completed successfully.',
      requestId: requestId,
      listingId: listingId,
    );
  }

  static Future<void> newMessage({
    required String uid,
    required String senderName,
    required String message,
    required String chatId,
    String? listingId,
  }) async {
    await create(
      uid: uid,
      type: 'new_message',
      title: 'New Message',
      message: '$senderName: $message',
      chatId: chatId,
      listingId: listingId,
    );
  }
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

    final data = doc.data() ?? <String, dynamic>{};
    final requesterId = (data['requesterId'] ?? '').toString();
    final listingTitle = (data['listingTitle'] ?? 'Untitled listing').toString();
    final listingId = (data['listingId'] ?? '').toString();
    final previousStatus = (data['status'] ?? 'pending').toString();

    if (previousStatus != 'pending') return;

    setState(() => _updating = true);
    try {
      await doc.reference.update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (requesterId.isNotEmpty) {
        await NotificationService.requestStatusChanged(
          requesterId: requesterId,
          listingTitle: listingTitle,
          requestId: doc.id,
          listingId: listingId,
          accepted: status == 'accepted',
        );
      }

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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openExchange(context, doc),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Open Chat'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
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

  Future<void> _openChat(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final requesterId = (data['requesterId'] ?? '').toString();
    final sellerId = (data['sellerId'] ?? '').toString();
    final isRequester = requesterId == user.uid;
    final otherUserId = isRequester ? sellerId : requesterId;

    if (otherUserId.isEmpty || otherUserId == user.uid) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to identify the other participant.')),
      );
      return;
    }

    final participants = [user.uid, otherUserId]..sort();
    final chatId = participants.join('_');
    final otherUserName = isRequester
        ? (data['sellerName'] ?? 'Seller').toString()
        : (data['requesterEmail'] ?? 'Buyer').toString();

    try {
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'participant1Id': participants[0],
        'participant2Id': participants[1],
        'listingId': (data['listingId'] ?? '').toString(),
        'listingTitle': (data['listingTitle'] ?? 'Item').toString(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
          ),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Unable to open chat.')),
      );
    }
  }

  Future<void> _startExchange(Map<String, dynamic> data) async {
    if (_busy) return;
    setState(() => _busy = true);

    final user = FirebaseAuth.instance.currentUser;
    final requesterId = (data['requesterId'] ?? '').toString();
    final sellerId = (data['sellerId'] ?? '').toString();
    final otherUserId = user?.uid == requesterId ? sellerId : requesterId;
    final listingTitle = (data['listingTitle'] ?? 'Untitled listing').toString();
    final listingId = (data['listingId'] ?? '').toString();

    try {
      await _requestRef.update({
        'status': 'in_progress',
        'startedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (otherUserId.isNotEmpty && otherUserId != user?.uid) {
        await NotificationService.exchangeStarted(
          uid: otherUserId,
          listingTitle: listingTitle,
          requestId: widget.requestId,
          listingId: listingId,
        );
      }

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

    bool exchangeCompleted = false;
    String requesterId = '';
    String sellerId = '';
    String listingTitle = 'Untitled listing';
    String listingId = '';

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
        requesterId = (current['requesterId'] ?? '').toString();
        sellerId = (current['sellerId'] ?? '').toString();
        listingTitle = (current['listingTitle'] ?? 'Untitled listing').toString();
        listingId = (current['listingId'] ?? '').toString();
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

        exchangeCompleted = requesterCompleted && sellerCompleted;

        final updates = <String, dynamic>{
          'status': exchangeCompleted ? 'completed' : 'in_progress',
          'requesterCompleted': requesterCompleted,
          'sellerCompleted': sellerCompleted,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (exchangeCompleted) {
          updates['completedAt'] = FieldValue.serverTimestamp();
        }

        transaction.update(_requestRef, updates);
      });

      if (exchangeCompleted) {
        if (requesterId.isNotEmpty) {
          await NotificationService.completionConfirmed(
            uid: requesterId,
            listingTitle: listingTitle,
            requestId: widget.requestId,
            listingId: listingId,
          );
        }
        if (sellerId.isNotEmpty && sellerId != requesterId) {
          await NotificationService.completionConfirmed(
            uid: sellerId,
            listingTitle: listingTitle,
            requestId: widget.requestId,
            listingId: listingId,
          );
        }
      } else {
        final otherUserId = user.uid == requesterId ? sellerId : requesterId;
        if (otherUserId.isNotEmpty) {
          await NotificationService.create(
            uid: otherUserId,
            type: 'exchange_completed',
            title: 'Completion Confirmed',
            message: 'The other participant confirmed the handover for "$listingTitle".',
            requestId: widget.requestId,
            listingId: listingId,
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exchangeCompleted
                ? 'Exchange completed successfully.'
                : 'Your completion has been recorded.',
          ),
        ),
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
              SizedBox(
                width: double.infinity,
                height: 64,
                child: OutlinedButton.icon(
                  onPressed: () => _openChat(data),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(
                    isRequester ? 'Chat with Seller' : 'Chat with Buyer',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: green,
                    side: const BorderSide(color: green, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
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


class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _firstChats(String uid) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participant1Id', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _secondChats(String uid) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participant2Id', isEqualTo: uid)
        .snapshots();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _mergeChats(
      QuerySnapshot<Map<String, dynamic>> first,
      QuerySnapshot<Map<String, dynamic>> second,
      ) {
    final byId = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (final doc in [...first.docs, ...second.docs]) {
      byId[doc.id] = doc;
    }

    final chats = byId.values.toList();

    chats.sort((a, b) {
      final aTime = a.data()['updatedAt'];
      final bTime = b.data()['updatedAt'];

      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }
      if (aTime is Timestamp) return -1;
      if (bTime is Timestamp) return 1;
      return 0;
    });

    return chats;
  }

  Future<String> _getOtherUserEmail(String otherUserId) async {
    if (otherUserId.isEmpty) return 'Student';

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get();

      final data = snapshot.data();
      final email = (data?['email'] ?? '').toString().trim();

      if (email.isNotEmpty) return email;

      final name = (data?['name'] ?? '').toString().trim();
      if (name.isNotEmpty) return name;
    } catch (_) {
      // Fall back to a generic student label if the profile cannot be read.
    }

    return 'Student';
  }

  Widget _chatCard(
      BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> chat,
      String currentUserId,
      ) {
    final data = chat.data();
    final participant1Id = (data['participant1Id'] ?? '').toString();
    final participant2Id = (data['participant2Id'] ?? '').toString();
    final otherUserId = participant1Id == currentUserId
        ? participant2Id
        : participant1Id;

    final listingTitle = (data['listingTitle'] ?? 'Conversation').toString();
    final lastMessage = (data['lastMessage'] ?? 'Start a conversation').toString();
    final lastSenderId = (data['lastSenderId'] ?? '').toString();
    final isLastMessageMine = lastSenderId == currentUserId;

    return FutureBuilder<String>(
      future: _getOtherUserEmail(otherUserId),
      builder: (context, snapshot) {
        final otherUserName = snapshot.data ?? 'Student';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: otherUserId.isEmpty
                ? null
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    chatId: chat.id,
                    otherUserId: otherUserId,
                    otherUserName: otherUserName,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: lightGreen,
                    child: Icon(Icons.person, color: green, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                otherUserName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: ink,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: muted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          listingTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: green,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          isLastMessageMine
                              ? 'You: $lastMessage'
                              : lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: muted,
                            fontSize: 15,
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
      },
    );
  }

  Widget _buildList(
      BuildContext context,
      QuerySnapshot<Map<String, dynamic>> first,
      QuerySnapshot<Map<String, dynamic>> second,
      String uid,
      ) {
    final chats = _mergeChats(first, second);

    if (chats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: green,
                  size: 45,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No conversations yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Start a chat from an accepted exchange and your conversations will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
      itemCount: chats.length,
      itemBuilder: (context, index) =>
          _chatCard(context, chats[index], uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your messages.'),
        ),
      );
    }

    final uid = user.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firstChats(uid),
        builder: (context, firstSnapshot) {
          if (firstSnapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load conversations.',
                style: TextStyle(color: muted),
              ),
            );
          }

          if (firstSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: green),
            );
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _secondChats(uid),
            builder: (context, secondSnapshot) {
              if (secondSnapshot.hasError) {
                return const Center(
                  child: Text(
                    'Unable to load conversations.',
                    style: TextStyle(color: muted),
                  ),
                );
              }

              if (secondSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: green),
                );
              }

              return _buildList(
                context,
                firstSnapshot.data!,
                secondSnapshot.data!,
                uid,
              );
            },
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  bool isSending = false;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (text.isEmpty || user == null || isSending) return;

    setState(() => isSending = true);
    messageController.clear();

    try {
      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId);

      await chatRef.collection('messages').add({
        'senderId': user.uid,
        'receiverId': widget.otherUserId,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await chatRef.update({
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': text,
        'lastSenderId': user.uid,
      });

      await NotificationService.newMessage(
        uid: widget.otherUserId,
        senderName: user.email ?? 'Student',
        message: text,
        chatId: widget.chatId,
      );
    } on FirebaseException catch (e) {
      messageController.text = text;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Unable to send message.')),
      );
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: lightGreen,
              child: Icon(Icons.person, color: green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.otherUserName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Unable to load messages.',
                      style: TextStyle(color: muted),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: green),
                  );
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Start a conversation 👋',
                      style: TextStyle(color: muted, fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data();
                    final senderId = (data['senderId'] ?? '').toString();
                    final text = (data['text'] ?? '').toString();
                    final isMe = senderId == currentUser?.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 12,
                        ),
                        constraints: const BoxConstraints(maxWidth: 310),
                        decoration: BoxDecoration(
                          color: isMe ? green : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isMe ? 18 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 18),
                          ),
                          border: isMe ? null : Border.all(color: border),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.35,
                            color: isMe ? Colors.white : ink,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: const Color(0xFFF3F5F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: green,
                    child: IconButton(
                      icon: isSending
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                      onPressed: isSending ? null : sendMessage,
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

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _iconForType(String type) {
    switch (type) {
      case 'request_received':
        return Icons.mark_email_unread_outlined;
      case 'request_accepted':
        return Icons.check_circle_outline_rounded;
      case 'request_rejected':
        return Icons.cancel_outlined;
      case 'exchange_started':
        return Icons.sync_alt_rounded;
      case 'exchange_completed':
        return Icons.handshake_outlined;
      case 'new_message':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'request_received':
        return const Color(0xFFE8EDFC);
      case 'request_accepted':
        return lightGreen;
      case 'request_rejected':
        return const Color(0xFFFFE8E8);
      case 'exchange_started':
        return const Color(0xFFE8EDFC);
      case 'exchange_completed':
        return const Color(0xFFE8F7EF);
      case 'new_message':
        return const Color(0xFFEAF1EA);
      default:
        return const Color(0xFFF1F3F1);
    }
  }

  String _timeText(dynamic value) {
    if (value is! Timestamp) return 'Just now';

    final difference = DateTime.now().difference(value.toDate());

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }

    final date = value.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _markAllAsRead(
      BuildContext context,
      String uid,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      ) async {
    final unreadDocs = docs.where((doc) {
      final data = doc.data();
      return data['isRead'] != true;
    }).toList();

    if (unreadDocs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications are already read.')),
      );
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in unreadDocs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read.')),
    );
  }

  Future<void> _markAsRead(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) async {
    if (doc.data()['isRead'] == true) return;

    await doc.reference.update({
      'isRead': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view notifications.'),
        ),
      );
    }

    final uid = user.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('notifications')
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final unread = snapshot.data?.docs.length ?? 0;

              return TextButton(
                onPressed: unread == 0
                    ? null
                    : () async {
                  final all = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('notifications')
                      .get();

                  if (!context.mounted) return;

                  await _markAllAsRead(
                    context,
                    uid,
                    all.docs,
                  );
                },
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'Unable to load notifications.\nPlease check your Firestore rules and index.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: green),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: const BoxDecoration(
                        color: lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: green,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No notifications yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Request, exchange and chat updates will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: muted,
                        fontSize: 16,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final title = (data['title'] ?? 'ReLoop Update').toString();
              final message = (data['message'] ?? '').toString();
              final type = (data['type'] ?? '').toString();
              final isRead = data['isRead'] == true;
              final time = _timeText(data['createdAt']);

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: isRead ? Colors.white : const Color(0xFFF1FBF4),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isRead
                        ? border
                        : const Color(0xFFB8EAC4),
                    width: isRead ? 1 : 1.5,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => _markAsRead(doc),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _colorForType(type),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _iconForType(type),
                            color: green,
                            size: 27,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: ink,
                                      ),
                                    ),
                                  ),
                                  if (!isRead)
                                    Container(
                                      width: 9,
                                      height: 9,
                                      margin: const EdgeInsets.only(
                                        left: 8,
                                        top: 6,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Text(
                                message,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                time,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
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
            },
          );
        },
      ),
    );
  }
}

class _SaveListingButton extends StatefulWidget {
  final String listingId;

  const _SaveListingButton({required this.listingId});

  @override
  State<_SaveListingButton> createState() => _SaveListingButtonState();
}

class _SaveListingButtonState extends State<_SaveListingButton> {
  bool? _isSaved;
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _saveIcon(false);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? <String, dynamic>{};
        final savedIds = (data['savedListingIds'] as List<dynamic>? ?? const <dynamic>[])
            .map((e) => e.toString())
            .toSet();

        // Use the local value while the Firestore update is in flight so the
        // bookmark changes immediately for the user.
        final isSaved = _isSaved ?? savedIds.contains(widget.listingId);
        return _saveIcon(isSaved);
      },
    );
  }

  Widget _saveIcon(bool isSaved) {
    return Material(
      color: Colors.white.withOpacity(.95),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: isSaved ? 'Remove from saved' : 'Save item',
        onPressed: _isUpdating ? null : _toggleSaved,
        icon: _isUpdating
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: green,
          ),
        )
            : Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: green,
        ),
      ),
    );
  }

  Future<void> _toggleSaved() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save items.')),
      );
      return;
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final previousValue = _isSaved;
    final currentlySaved = _isSaved ?? false;
    final nextValue = !currentlySaved;

    setState(() {
      _isSaved = nextValue;
      _isUpdating = true;
    });

    try {
      await userRef.set(
        {
          'savedListingIds': nextValue
              ? FieldValue.arrayUnion([widget.listingId])
              : FieldValue.arrayRemove([widget.listingId]),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextValue ? 'Saved to Saved Items.' : 'Removed from Saved Items.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaved = previousValue);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update Saved Items.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }
}

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: Text('Please login again.')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Items'),
        backgroundColor: Colors.white,
        foregroundColor: ink,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return const Center(child: Text('Unable to load saved items.'));
          }
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: green));
          }

          final data = userSnapshot.data?.data() ?? <String, dynamic>{};
          final savedIds = (data['savedListingIds'] as List<dynamic>? ?? const <dynamic>[])
              .map((e) => e.toString())
              .toList();

          if (savedIds.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_border, size: 70, color: green),
                    SizedBox(height: 15),
                    Text(
                      'No saved items yet',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the bookmark icon on a listing to save it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: muted),
                    ),
                  ],
                ),
              ),
            );
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('listings').snapshots(),
            builder: (context, listingSnapshot) {
              if (listingSnapshot.hasError) {
                return const Center(child: Text('Unable to load saved listings.'));
              }
              if (listingSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: green));
              }

              final docs = listingSnapshot.data?.docs
                  .where((doc) => savedIds.contains(doc.id))
                  .toList() ??
                  <QueryDocumentSnapshot<Map<String, dynamic>>>[];

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Your saved listings are no longer available.',
                    style: TextStyle(fontSize: 17, color: muted),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final item = doc.data();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ProductCard(
                      listingId: doc.id,
                      title: (item['title'] ?? 'Untitled listing').toString(),
                      price: _formatPrice(item['price']),
                      condition: (item['condition'] ?? 'Condition not specified').toString(),
                      distance: 'Nearby',
                      icon: _iconForCategory(item['category']),
                      impact: _impactForCategory(item['category']),
                      sellerId: (item['sellerId'] ?? '').toString(),
                      sellerName: (item['sellerName'] ?? item['sellerEmail'] ?? 'ReLoop Student').toString(),
                      description: (item['description'] ?? '').toString(),
                      category: (item['category'] ?? 'Other').toString(),
                      listingType: (item['listingType'] ?? 'Sell').toString(),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  Future<Map<String, int>> _loadStats(String uid) async {
    final firestore = FirebaseFirestore.instance;

    final results = await Future.wait([
      firestore
          .collection('listings')
          .where('sellerId', isEqualTo: uid)
          .get(),
      firestore
          .collection('requests')
          .where('sellerId', isEqualTo: uid)
          .get(),
    ]);

    final listingSnapshot =
    results[0] as QuerySnapshot<Map<String, dynamic>>;
    final requestSnapshot =
    results[1] as QuerySnapshot<Map<String, dynamic>>;

    int activeListings = 0;
    int pendingRequests = 0;
    int completedExchanges = 0;

    for (final doc in listingSnapshot.docs) {
      final status =
      (doc.data()['status'] ?? 'active').toString().toLowerCase();

      if (status != 'inactive' &&
          status != 'deleted' &&
          status != 'completed') {
        activeListings++;
      }
    }

    for (final doc in requestSnapshot.docs) {
      final status =
      (doc.data()['status'] ?? 'pending').toString().toLowerCase();

      if (status == 'pending') {
        pendingRequests++;
      } else if (status == 'completed') {
        completedExchanges++;
      }
    }

    return {
      'totalListings': listingSnapshot.docs.length,
      'activeListings': activeListings,
      'pendingRequests': pendingRequests,
      'completedExchanges': completedExchanges,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login to view your seller dashboard.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seller Dashboard',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _loadStats(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: green),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load dashboard.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final stats = snapshot.data ?? const <String, int>{};

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            children: [
              const Text(
                'Your ReLoop activity',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage your listings and exchanges in one place.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF687169),
                ),
              ),
              const SizedBox(height: 26),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.35,
                children: [
                  _DashboardStatCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Total Listings',
                    value: '${stats['totalListings'] ?? 0}',
                  ),
                  _DashboardStatCard(
                    icon: Icons.check_circle_outline,
                    title: 'Active Listings',
                    value: '${stats['activeListings'] ?? 0}',
                  ),
                  _DashboardStatCard(
                    icon: Icons.pending_actions_outlined,
                    title: 'Pending Requests',
                    value: '${stats['pendingRequests'] ?? 0}',
                  ),
                  _DashboardStatCard(
                    icon: Icons.swap_horizontal_circle_outlined,
                    title: 'Completed',
                    value: '${stats['completedExchanges'] ?? 0}',
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _DashboardActionButton(
                icon: Icons.inventory_2_outlined,
                title: 'My Listings',
                subtitle: 'View and manage your listings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyListingsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _DashboardActionButton(
                icon: Icons.sync_alt_rounded,
                title: 'My Exchanges',
                subtitle: 'View incoming and outgoing requests',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RequestsScreen(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DashboardStatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD9E2D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: green),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF687169),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD9E2D9)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7ED),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: green),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF687169),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>> _loadProfileStats(String uid) async {
    final results = await Future.wait([
      FirebaseFirestore.instance.collection('users').doc(uid).get(),
      FirebaseFirestore.instance
          .collection('listings')
          .where('sellerId', isEqualTo: uid)
          .get(),
      FirebaseFirestore.instance
          .collection('requests')
          .where('requesterId', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .get(),
    ]);

    final userDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
    final listingSnapshot = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final exchangeSnapshot = results[2] as QuerySnapshot<Map<String, dynamic>>;

    final userData = userDoc.data() ?? <String, dynamic>{};

    return {
      'name': (userData['name'] ?? '').toString().trim(),
      'email': (userData['email'] ?? '').toString().trim(),
      'college': (userData['college'] ?? '').toString().trim(),
      'department': (userData['department'] ?? '').toString().trim(),
      'profileImage': (userData['profileImage'] ?? '').toString().trim(),
      'listings': listingSnapshot.docs.length,
      'reuses': _toInt(userData['itemsReused'], exchangeSnapshot.docs.length),
      'ecoPoints': _toInt(userData['ecoPoints'], exchangeSnapshot.docs.length * 50),
      'exchanges': _toInt(userData['exchanges'], exchangeSnapshot.docs.length),
      'donations': _toInt(userData['donations'], 0),
      'co2Saved': _toDouble(userData['co2Saved'], 0),
    };
  }

  static int _toInt(dynamic value, int fallback) {
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    return parsed ?? fallback;
  }

  static double _toDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value?.toString() ?? '');
    return parsed ?? fallback;
  }

  void _openPage(BuildContext context, String title) {
    Widget? page;

    switch (title) {
      case 'Seller Dashboard':
        page = const SellerDashboardScreen();
        break;
      case 'My Listings':
        page = const MyListingsScreen();
        break;
      case 'Messages':
        page = const ChatListScreen();
        break;
      case 'My Exchanges':
        page = const RequestsScreen();
        break;
      case 'Notifications':
        page = const NotificationsScreen();
        break;
      case 'Saved Items':
        page = const SavedItemsScreen();
        break;
      case 'Impact History':
        page = const ImpactScreen();
        break;
      case 'My Reports':
        page = const MyReportsScreen();
        break;
      case 'Settings':
        page = const SettingsScreen();
        break;
    }

    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SafeArea(
        child: Center(
          child: Text(
            'Please login again.',
            style: TextStyle(fontSize: 18, color: muted),
          ),
        ),
      );
    }

    return SafeArea(
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load profile.',
                style: TextStyle(fontSize: 17, color: muted),
              ),
            );
          }

          return FutureBuilder<Map<String, dynamic>>(
            future: _loadProfileStats(user.uid),
            builder: (context, statsSnapshot) {
              if (statsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: green),
                );
              }

              final stats = statsSnapshot.data ?? <String, dynamic>{};

              final firestoreData = userSnapshot.data?.data() ?? {};
              final name = (firestoreData['name'] ??
                  stats['name'] ??
                  user.displayName ??
                  'ReLoop Student')
                  .toString()
                  .trim();

              final email = (firestoreData['email'] ??
                  stats['email'] ??
                  user.email ??
                  '')
                  .toString()
                  .trim();

              final college = (firestoreData['college'] ??
                  stats['college'] ??
                  '')
                  .toString()
                  .trim();

              final department = (firestoreData['department'] ??
                  stats['department'] ??
                  '')
                  .toString()
                  .trim();

              final subtitleParts = <String>[];
              if (department.isNotEmpty) subtitleParts.add(department);
              if (college.isNotEmpty) subtitleParts.add(college);

              final subtitle = subtitleParts.isEmpty
                  ? 'Verified Student ✓'
                  : '${subtitleParts.join(' • ')} • Verified Student ✓';

              final listings = stats['listings'] ?? 0;
              final reuses = stats['reuses'] ?? 0;
              final ecoPoints = stats['ecoPoints'] ?? 0;
              final exchanges = stats['exchanges'] ?? 0;
              final donations = stats['donations'] ?? 0;

              return ListView(
                padding: const EdgeInsets.fromLTRB(30, 18, 30, 30),
                children: [
                  const AppHeader(),
                  const SizedBox(height: 50),

                  const Center(
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: lightGreen,
                      child: Icon(
                        Icons.person,
                        size: 65,
                        color: green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    name.isEmpty ? 'ReLoop Student' : name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 16,
                    ),
                  ),

                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 14,
                      ),
                    ),
                  ],

                  const SizedBox(height: 35),

                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ProfileStat('$listings', 'Listings'),
                        ProfileStat('$reuses', 'Reuses'),
                        ProfileStat('$ecoPoints', 'Eco Points'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFB8EAC4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sync_alt_rounded, color: green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$exchanges exchange${exchanges == 1 ? '' : 's'} • '
                                '$donations donation${donations == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: green,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  ...[
                    ('Seller Dashboard', Icons.dashboard_outlined),
                    ('My Listings', Icons.inventory_2_outlined),
                    ('Messages', Icons.chat_bubble_outline_rounded),
                    ('My Exchanges', Icons.sync_alt),
                    ('Saved Items', Icons.bookmark_border),
                    ('Impact History', Icons.history),
                    ('Notifications', Icons.notifications_none),
                    ('My Reports', Icons.flag_outlined),
                    ('Settings', Icons.settings_outlined),
                  ].map(
                        (e) => ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 3),
                      leading: Icon(e.$2, color: green),
                      title: Text(
                        e.$1,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openPage(context, e.$1),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}


class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day/$month/$year';
    }
    return 'Recently submitted';
  }

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'reviewed':
        return const Color(0xFFDDF8E6);
      case 'dismissed':
        return const Color(0xFFFDE7E7);
      default:
        return const Color(0xFFFFF4D6);
    }
  }

  Color _statusForeground(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'reviewed':
        return green;
      case 'dismissed':
        return Colors.red.shade700;
      default:
        return const Color(0xFF8A6500);
    }
  }

  String _statusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return 'Our team has reviewed the report and resolved the issue.';
      case 'reviewed':
        return 'Our team has reviewed your report.';
      case 'dismissed':
        return 'The report was reviewed and no action was required.';
      default:
        return 'Your report is waiting for review.';
    }
  }

  Future<void> _showReportDetails(
      BuildContext context,
      Map<String, dynamic> data,
      ) async {
    final title = (data['listingTitle'] ?? 'Untitled listing').toString();
    final reason = (data['reason'] ?? 'Other').toString();
    final status = (data['status'] ?? 'pending').toString();
    final sellerName = (data['sellerName'] ?? 'ReLoop Student').toString();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      child: const Icon(Icons.flag_outlined, color: green),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Report Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _reportDetailRow('Listing', title),
                _reportDetailRow('Seller', sellerName),
                _reportDetailRow('Reason', reason),
                _reportDetailRow('Submitted', _formatDate(data['createdAt'])),
                _reportDetailRow('Last updated', _formatDate(data['updatedAt'])),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _statusBackground(status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: _statusForeground(status)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status.isEmpty
                                  ? 'Pending'
                                  : '${status[0].toUpperCase()}${status.substring(1)}',
                              style: TextStyle(
                                color: _statusForeground(status),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _statusMessage(status),
                              style: const TextStyle(color: muted, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _reportDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(color: muted, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: ink, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please login again.',
            style: TextStyle(fontSize: 18, color: muted),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF2E8),
        elevation: 0,
        title: const Text(
          'My Reports',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where('reporterId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load your reports.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, color: muted),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: green));
          }

          final reports = [...snapshot.data!.docs];
          reports.sort((a, b) {
            final aTime = a.data()['createdAt'];
            final bTime = b.data()['createdAt'];
            final aDate = aTime is Timestamp ? aTime.toDate() : DateTime(1970);
            final bDate = bTime is Timestamp ? bTime.toDate() : DateTime(1970);
            return bDate.compareTo(aDate);
          });

          if (reports.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flag_outlined,
                        size: 42,
                        color: green,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No reports yet.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Listings you report will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: muted),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final data = reports[index].data();
              final title = (data['listingTitle'] ?? 'Untitled listing').toString();
              final reason = (data['reason'] ?? 'Other').toString();
              final status = (data['status'] ?? 'pending').toString();
              final displayStatus = status.isEmpty
                  ? 'Pending'
                  : '${status[0].toUpperCase()}${status.substring(1)}';

              return InkWell(
                onTap: () => _showReportDetails(context, data),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                            ),
                            child: const Icon(Icons.flag_outlined, color: green),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: ink,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Reported on ${_formatDate(data['createdAt'])}',
                                  style: const TextStyle(color: muted, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _statusBackground(status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              displayStatus,
                              style: TextStyle(
                                color: _statusForeground(status),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 19, color: muted),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                reason,
                                style: const TextStyle(
                                  color: ink,
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
              );
            },
          );
        },
      ),
    );
  }
}


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool loading = true;

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final currentUser = user;
    if (currentUser == null) {
      if (mounted) setState(() => loading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final data = doc.data() ?? <String, dynamic>{};
      if (mounted) {
        setState(() {
          notificationsEnabled = data['notificationsEnabled'] != false;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _setNotifications(bool value) async {
    final currentUser = user;
    if (currentUser == null) return;

    setState(() => notificationsEnabled = value);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'notificationsEnabled': value});
    } catch (_) {
      if (mounted) {
        setState(() => notificationsEnabled = !value);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update notification setting.')),
        );
      }
    }
  }

  Future<void> _showAccountInfo() async {
    final currentUser = user;
    if (currentUser == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final data = doc.data() ?? <String, dynamic>{};

    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingInfoRow('Name', '${data['name'] ?? currentUser.displayName ?? 'Student'}'),
            _SettingInfoRow('Email', '${data['email'] ?? currentUser.email ?? ''}'),
            _SettingInfoRow('College', '${data['college'] ?? 'Not added'}'),
            _SettingInfoRow('Department', '${data['department'] ?? 'Not added'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to access ReLoop.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true) return;

    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = user;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please login again.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: green))
          : ListView(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: lightGreen,
                  child: Icon(Icons.person, color: green, size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser.email ?? 'Student account',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text('Verified ReLoop account', style: TextStyle(color: muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: muted)),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Account Information',
            subtitle: 'View your profile details',
            onTap: _showAccountInfo,
          ),
          const SizedBox(height: 10),
          const Text('Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: muted)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined, color: green),
              title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(notificationsEnabled ? 'Request, exchange and chat updates' : 'Notifications are turned off'),
              value: notificationsEnabled,
              activeColor: green,
              onChanged: _setNotifications,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: muted)),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Sign out',
            subtitle: 'Sign out from this account',
            destructive: true,
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Colors.red.shade700 : green;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: destructive ? Colors.red.shade700 : ink)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SettingInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _SettingInfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: muted)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
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
