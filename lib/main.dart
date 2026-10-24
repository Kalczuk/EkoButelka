import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import do sprawdzania trybu Standalone (PWA) w przeglądarce
import 'package:universal_html/html.dart' as html;

// IMPORTY FIREBASE
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  runApp(const EkoButelkaApp());
}

class AppColors {
  static const Color primaryGreen = Color(0xFF1AA84C);
  static const Color darkGreen = Color(0xFF0F4C2E);
  static const Color lightGreen = Color(0xFFE8F6ED);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFE53935);
  static const Color background = Color(0xFFF5F8F6);
  static const Color textDark = Color(0xFF1A1E1B);
  static const Color silver = Color(0xFF78909C);
  static const Color gold = Color(0xFFFFC107);
}

class ButelkomatData {
  final LatLng point;
  final String name;
  final bool isFull;
  final bool isVerified;
  ButelkomatData({
    required this.point,
    required this.name,
    required this.isFull,
    this.isVerified = true,
  });
}

class EkoButelkaApp extends StatelessWidget {
  const EkoButelkaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EKOButelka',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// 1. EKRAN ŁADOWANIA (SPLASH SCREEN)
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryGreen, AppColors.darkGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    )
                  ],
                ),
                child: const Icon(Icons.eco_rounded, size: 90, color: AppColors.primaryGreen),
              ),
            ),
            const SizedBox(height: 35),
            const Text(
              'EKOButelka',
              style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 3),
            ),
            const SizedBox(height: 12),
            Text(
              'Krajowy System Recyklingu',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, letterSpacing: 0.8),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 3.5),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// NAWIGACJA Z ZAMRAŻANIEM STANÓW
// ==========================================
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const MapScreen(),
    const PortfelWrapper(),
    const ProfilWrapper(),
    const KalkulatorScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGreen.withOpacity(0.06),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: NavigationBar(
            height: 74,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.white.withOpacity(0.94),
            indicatorColor: AppColors.lightGreen,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map_rounded, color: AppColors.primaryGreen), label: 'Mapa'),
              NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryGreen), label: 'Portfel'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryGreen), label: 'Profil'),
              NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate_rounded, color: AppColors.primaryGreen), label: 'Kalkulator'),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// WIDŻET REKLAMOWY (MIEJSCE POD ADSENSE)
// ==========================================
class WebAdBanner extends StatelessWidget {
  const WebAdBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('REKLAMA', style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text('Wspieraj rozwój EKOButelki', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. EKRAN MAPY (Z BANEREM PWA)
// ==========================================
class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? _currentPosition;
  final MapController _mapController = MapController();
  final List<ButelkomatData> _machines = [];
  bool _isLoadingShops = false;
  bool _showPwaBanner = false;
  int _activePwaTab = 0;

  @override
  void initState() {
    super.initState();
    _checkPwaStatus();
    _loadStaticFallbackDatabase();
    _initLocation();
  }

  void _checkPwaStatus() {
    if (kIsWeb) {
      bool isStandalone = html.window.matchMedia('(display-mode: standalone)').matches;
      if (!isStandalone) {
        try {
          isStandalone = (html.window.navigator as dynamic).standalone == true;
        } catch (_) {}
      }
      setState(() {
        _showPwaBanner = !isStandalone;
      });

      final userAgent = html.window.navigator.userAgent.toLowerCase();
      if (userAgent.contains('iphone') || userAgent.contains('ipad')) {
        _activePwaTab = 0;
      } else {
        _activePwaTab = 1;
      }
    }
  }

  void _showSnackBar(String message, {Color color = AppColors.accentOrange}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 4),
    ));
  }

  void _loadStaticFallbackDatabase() {
    _currentPosition = Position(
        longitude: 16.9252, latitude: 52.4064, timestamp: DateTime.now(),
        accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0,
        altitudeAccuracy: 0, headingAccuracy: 0);
  }

  Future<void> _initLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
      _mapController.move(LatLng(position.latitude, position.longitude), 14.5);
      _fetchNearbyStoresAPI(position);
    } catch (e) {
      debugPrint("Błąd GPS: Używam lokalizacji domyślnej.");
      if (mounted) _showSnackBar("Brak dostępu do GPS. Używam domyślnej lokalizacji.", color: AppColors.errorRed);
      _fetchNearbyStoresAPI(_currentPosition!);
    }
    _fetchFirebaseMachines();
  }

  Future<void> _fetchFirebaseMachines() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('butelkomaty').get();
      List<ButelkomatData> firebaseStores = snapshot.docs.map((doc) {
        final data = doc.data();
        return ButelkomatData(
            point: LatLng(data['lat'], data['lng']),
            name: data['name'] ?? 'Automat',
            isFull: data['isFull'] ?? false,
            isVerified: true);
      }).toList();
      if (mounted) setState(() => _machines.addAll(firebaseStores));
    } catch (e) {
      debugPrint("Firebase error: $e");
    }
  }

  // --- ZABEZPIECZONE ZAPYTANIE DO OPENSTREETMAP ---
  Future<void> _fetchNearbyStoresAPI(Position pos) async {
    if (mounted) setState(() => _isLoadingShops = true);
    try {
      // Promień ustawiony na bezpieczne 3500m (3.5km).
      final query = '[out:json][timeout:25];('
          'nwr["shop"="supermarket"](around:3500, ${pos.latitude}, ${pos.longitude});'
          'nwr["shop"="convenience"](around:3500, ${pos.latitude}, ${pos.longitude});'
          'nwr["vending"="bottle_return"](around:3500, ${pos.latitude}, ${pos.longitude});'
          ');out center;';

      final url = Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeQueryComponent(query)}');

      // DODANO USER-AGENT ABY SERWER NIE BLOKOWAŁ APLIKACJI
      final response = await http.get(url, headers: {
        'User-Agent': 'EkoButelkaApp/1.0',
        'Accept': 'application/json'
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;
        List<ButelkomatData> fetchedStores = [];

        for (var el in elements) {
          final lat = el['lat'] ?? el['center']?['lat'];
          final lon = el['lon'] ?? el['center']?['lon'];
          if (lat == null || lon == null) continue;

          final tags = el['tags'] ?? {};
          final rawName = tags['name']?.toString() ?? '';
          final brand = tags['brand']?.toString() ?? '';
          final operatorName = tags['operator']?.toString() ?? '';

          final combinedString = '$rawName $brand $operatorName'.toLowerCase();
          String finalDisplayName = rawName.isNotEmpty ? rawName : (brand.isNotEmpty ? brand : 'Sklep osiedlowy');

          if (combinedString.contains('biedronka') || combinedString.contains('lidl') ||
              combinedString.contains('żabka') || combinedString.contains('zabka') ||
              combinedString.contains('netto') || combinedString.contains('kaufland') ||
              combinedString.contains('carrefour') || combinedString.contains('dino') ||
              combinedString.contains('auchan') || combinedString.contains('lewiatan') ||
              combinedString.contains('stokrotka')) {

            if (combinedString.contains('biedronka')) finalDisplayName = "Biedronka";
            if (combinedString.contains('żabka') || combinedString.contains('zabka')) finalDisplayName = "Żabka";
            if (combinedString.contains('lidl')) finalDisplayName = "Lidl";
            if (combinedString.contains('dino')) finalDisplayName = "Dino";
            if (combinedString.contains('lewiatan')) finalDisplayName = "Lewiatan";
            if (combinedString.contains('netto')) finalDisplayName = "Netto";
            if (combinedString.contains('kaufland')) finalDisplayName = "Kaufland";

            fetchedStores.add(ButelkomatData(point: LatLng(lat, lon), name: finalDisplayName, isFull: false, isVerified: false));
          } else if (tags['vending'] == 'bottle_return') {
            fetchedStores.add(ButelkomatData(point: LatLng(lat, lon), name: "Recyklomat ($finalDisplayName)", isFull: false, isVerified: true));
          }
        }
        if (mounted) {
          setState(() {
            _machines.removeWhere((m) => !m.isVerified);
            _machines.addAll(fetchedStores);
          });
        }
      } else {
        // Jeśli Overpass zwróci błąd obciążenia
        if (mounted) _showSnackBar("Błąd serwera map (Kod: ${response.statusCode}). Spróbuj ponownie.", color: AppColors.errorRed);
      }
    } catch (e) {
      debugPrint("API Error: $e");
      if (mounted) _showSnackBar("Błąd sieci. Sprawdź połączenie z internetem.", color: AppColors.errorRed);
    } finally {
      if (mounted) setState(() => _isLoadingShops = false);
    }
  }

  Widget _buildMarkerIcon(ButelkomatData machine) {
    Color brandColor;
    IconData iconData = Icons.storefront_rounded;
    String nameLower = machine.name.toLowerCase();

    if (nameLower.contains('biedronka')) { brandColor = const Color(0xFFE51A24); iconData = Icons.shopping_basket_rounded; }
    else if (nameLower.contains('lidl')) { brandColor = const Color(0xFF0050AA); iconData = Icons.shopping_cart_rounded; }
    else if (nameLower.contains('żabka') || nameLower.contains('zabka')) { brandColor = const Color(0xFF24AA4B); iconData = Icons.store_rounded; }
    else if (nameLower.contains('kaufland') || nameLower.contains('dino')) { brandColor = const Color(0xFFD90011); iconData = Icons.store_rounded; }
    else if (nameLower.contains('netto') || nameLower.contains('lewiatan')) { brandColor = const Color(0xFFFFD400); iconData = Icons.shopping_bag_rounded; }
    else if (machine.isVerified) { brandColor = AppColors.primaryGreen; iconData = Icons.recycling_rounded; }
    else { brandColor = AppColors.accentOrange; iconData = Icons.storefront_rounded; }

    int pseudoRandomStatus = (machine.point.latitude.hashCode + DateTime.now().minute ~/ 10) % 3;
    Color dotColor = Colors.green;
    if (pseudoRandomStatus == 1) dotColor = Colors.orange;
    if (pseudoRandomStatus == 2 && machine.isVerified) dotColor = Colors.red;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 42,
          height: 40,
          decoration: BoxDecoration(
            color: brandColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Icon(iconData, color: brandColor == const Color(0xFFFFD400) ? Colors.black : Colors.white, size: 18),
        ),
        Positioned(
          bottom: 1,
          right: 1,
          child: Container(
            width: 11, height: 11,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
          ),
        ),
      ],
    );
  }

  void _showStoreDetailsBottomSheet(ButelkomatData machine) {
    String nameLower = machine.name.toLowerCase();
    Color brandColor = AppColors.primaryGreen;

    if (nameLower.contains('biedronka')) brandColor = const Color(0xFFE51A24);
    if (nameLower.contains('lidl')) brandColor = const Color(0xFF0050AA);
    if (nameLower.contains('żabka') || nameLower.contains('zabka')) brandColor = const Color(0xFF24AA4B);
    if (nameLower.contains('kaufland')) brandColor = const Color(0xFFD90011);

    int seed = (machine.point.longitude.hashCode + DateTime.now().minute ~/ 5) % 3;
    String statusLabel = "Maszyna dostępna (Brak kolejki)";
    Color statusColor = AppColors.primaryGreen;
    IconData statusIcon = Icons.check_circle_outline_rounded;

    if (seed == 1) {
      statusLabel = "Wysokie obciążenie (Sugerowana kolejka)";
      statusColor = AppColors.accentOrange;
      statusIcon = Icons.hourglass_empty_rounded;
    } else if (seed == 2) {
      statusLabel = "Chwilowo niedostępny / Prace techniczne";
      statusColor = AppColors.errorRed;
      statusIcon = Icons.error_outline_rounded;
    }

    int minsAgo = (machine.point.latitude.hashCode % 10) + 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45, height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: brandColor.withOpacity(0.12),
                    child: Icon(Icons.storefront_rounded, color: brandColor, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(machine.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark, letterSpacing: -0.5)),
                        const Text("Oficjalny Punkt Akceptacji Zwrotów", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 22),
              const Divider(height: 1),
              const SizedBox(height: 22),
              const Text("STAN ZAPEŁNIENIA MASZYNY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 26),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text("Odświeżono: $minsAgo min temu", style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w400)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showPwaInstallGuide() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    final bool isIosLocal = userAgent.contains('iphone') || userAgent.contains('ipad') || userAgent.contains('ipod');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: AppColors.lightGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.install_mobile_rounded, color: AppColors.primaryGreen, size: 30),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Zainstaluj Aplikację', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        Text('Dodaj do ekranu głównego', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'EKOButelka działa niezależnie od sklepów App Store. Aby w pełni z niej korzystać (Portfel, Skaner), dodaj ją do swojego telefonu wykonując 2 proste kroki:',
                style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(isIosLocal ? Icons.ios_share_rounded : Icons.more_vert_rounded, color: AppColors.primaryGreen, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            isIosLocal ? '1. Kliknij ikonę "Udostępnij" na dolnym pasku przeglądarki Safari.'
                                : '1. Kliknij ikonę "Opcje" (trzy kropki) w prawym górnym rogu przeglądarki.',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                          ),
                        )
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_box_rounded, color: AppColors.primaryGreen, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            isIosLocal ? '2. Przewiń listę i wybierz "Dodaj do ekranu głównego".'
                                : '2. Wybierz z listy opcję "Dodaj do ekranu głównego" lub "Zainstaluj".',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Zrozumiałem, zamknij', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showAddMachineDialog() {
    if (_currentPosition == null) return;
    if (FirebaseAuth.instance.currentUser == null) {
      _showSnackBar("Musisz założyć konto, aby dodawać punkty na mapę!", color: AppColors.errorRed);
      return;
    }

    final nameController = TextEditingController();
    bool isFullStatus = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, left: 24, right: 24, top: 10),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 5,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Zgłoś nowy automat', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nazwa sklepu / lokalizacja',
                      prefixIcon: const Icon(Icons.storefront, color: AppColors.primaryGreen),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: Text(isFullStatus ? 'Zapełniony / Awaria' : 'Działa poprawnie', style: TextStyle(color: isFullStatus ? AppColors.errorRed : AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                    value: isFullStatus,
                    activeColor: AppColors.errorRed,
                    onChanged: (bool value) {
                      setModalState(() => isFullStatus = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) return;
                        final name = nameController.text.trim();
                        Navigator.pop(context);
                        setState(() {
                          _machines.add(ButelkomatData(point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude), name: name, isFull: isFullStatus, isVerified: true));
                        });
                        try {
                          await FirebaseFirestore.instance.collection('butelkomaty').add({
                            'lat': _currentPosition!.latitude,
                            'lng': _currentPosition!.longitude,
                            'name': name,
                            'isFull': isFullStatus,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                        } catch (e) {
                          debugPrint("Upload błąd: $e");
                        }
                      },
                      child: const Text('Zapisz na mapie', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_currentPosition?.latitude ?? 52.4064, _currentPosition?.longitude ?? 16.9252),
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.butelkomat',
              ),
              MarkerLayer(
                markers: [
                  ..._machines.map((machine) {
                    return Marker(
                      point: machine.point,
                      width: 45,
                      height: 45,
                      child: GestureDetector(
                        onTap: () => _showStoreDetailsBottomSheet(machine),
                        child: _buildMarkerIcon(machine),
                      ),
                    );
                  }).toList(),
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withOpacity(0.25)),
                        child: const Center(child: Icon(Icons.my_location, color: Colors.blue, size: 20)),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white.withOpacity(0.86),
                  child: Row(
                    children: [
                      const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 28),
                      const SizedBox(width: 10),
                      const Text(
                        'EKOButelka',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen, letterSpacing: -0.5),
                      ),
                      const Spacer(),
                      if (_isLoadingShops)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2.5)),
                        ),
                      if (_showPwaBanner && !_isLoadingShops)
                        InkWell(
                          onTap: _showPwaInstallGuide,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.download_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('ZAINSTALUJ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 125,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'loc',
                  mini: true,
                  backgroundColor: Colors.white,
                  elevation: 3,
                  child: const Icon(Icons.my_location, color: AppColors.primaryGreen),
                  onPressed: () {
                    if (_currentPosition != null) {
                      _mapController.move(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 14.5);
                    }
                  },
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'add_m',
                  backgroundColor: AppColors.primaryGreen,
                  elevation: 4,
                  icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
                  label: const Text('Zgłoś automat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: _showAddMachineDialog,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 3. WRAPPERY AUTORYZACJI FIREBASE
// ==========================================
class PortfelWrapper extends StatelessWidget {
  const PortfelWrapper({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData && snapshot.data != null) {
          return PortfelScreen(user: snapshot.data!);
        }
        return const AuthScreenUI(message: "Zaloguj się, aby sprawdzić EKO-Portfel");
      },
    );
  }
}

class ProfilWrapper extends StatelessWidget {
  const ProfilWrapper({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData && snapshot.data != null) {
          return ProfilScreen(user: snapshot.data!);
        }
        return const AuthScreenUI(message: "Zaloguj się, by zbierać eko-statystyki");
      },
    );
  }
}

// ==========================================
// 4. EKRAN LOGOWANIA
// ==========================================
class AuthScreenUI extends StatefulWidget {
  final String message;
  const AuthScreenUI({Key? key, this.message = "Dołącz do EKOButelki"}) : super(key: key);
  @override
  State<AuthScreenUI> createState() => _AuthScreenUIState();
}

class _AuthScreenUIState extends State<AuthScreenUI> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String _errorText = "";

  void _submitEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    if (password.length < 6) {
      setState(() => _errorText = "Hasło musi mieć minimum 6 znaków!");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = "";
    });

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      } else {
        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        await FirebaseFirestore.instance.collection('uzytkownicy').doc(userCred.user!.uid).set({
          'butelki': 0,
          'puszki': 0,
          'saldo': 0.0,
          'co2': 0.0,
          'data_rejestracji': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _errorText = 'Konto z tym adresem e-mail już istnieje w systemie!';
        } else if (e.code == 'weak-password') {
          _errorText = 'Podane hasło jest zbyt słabe.';
        } else if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _errorText = 'Niepoprawny adres e-mail lub hasło.';
        } else {
          _errorText = 'Błąd systemu autoryzacji: ${e.message}';
        }
      });
    } catch (e) {
      setState(() => _errorText = "Wystąpił nieoczekiwany problem sieciowy.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autoryzacja', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(color: AppColors.lightGreen, shape: BoxShape.circle),
                child: const Icon(Icons.shield_rounded, size: 60, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 24),
              Text(
                widget.message,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark, letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Bezpieczny dostęp do portfela i historii zwrotów.',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_errorText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.errorRed.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.errorRed),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_errorText, style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Adres Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Hasło',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primaryGreen)
                  : SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _submitEmail,
                  child: Text(
                    _isLogin ? 'Zaloguj się' : 'Zarejestruj EKO-Konto',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? 'Nie masz konta? Zarejestruj się' : 'Masz już konto? Zaloguj się',
                  style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. REAKTYWNY EKRAN PORTFELA
// ==========================================
class PortfelScreen extends StatelessWidget {
  final User user;
  const PortfelScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String ekoId = user.uid.substring(0, 10).toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twój Portfel Kaucji', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('uzytkownicy').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final double saldo = (data['saldo'] ?? 0.0).toDouble();
          final int butelki = data['butelki'] ?? 0;
          final int puszki = data['puszki'] ?? 0;
          final int totalCount = butelki + puszki;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.darkGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ZGROMADZONE ŚRODKI Z KAUCJI', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text('${saldo.toStringAsFixed(2)} zł', style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Uratowane opakowania: $totalCount szt.', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                        const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey.shade200)),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text('EKO-ID: $ekoId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          32,
                              (index) => Container(
                            width: (index * 13) % 5 == 0 ? 4.5 : 2,
                            height: 65,
                            color: AppColors.textDark,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Zeskanuj przy recyklomacie, aby odebrać środki', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Historia ostatnich operacji', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen, letterSpacing: -0.5)),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('uzytkownicy').doc(user.uid).collection('historia').orderBy('data', descending: true).snapshots(),
                builder: (context, histSnapshot) {
                  if (!histSnapshot.hasData || histSnapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.history_toggle_off_rounded, size: 50, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text('Brak historii zwrotów', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                          Text('Zwróć butelki w kalkulatorze, by zasilić profil.', style: TextStyle(color: Colors.grey[500], fontSize: 12), textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: histSnapshot.data!.docs.map((doc) {
                      final hData = doc.data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade100)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: const CircleAvatar(backgroundColor: AppColors.lightGreen, child: Icon(Icons.done_rounded, color: AppColors.primaryGreen, size: 20)),
                          title: Text(hData['tytul'] ?? 'Zwrot', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          subtitle: Text('${hData['data']} • Ilość: ${hData['ilosc']} szt.'),
                          trailing: Text(hData['kwota'] ?? '0.00 zł', style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 17)),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              const WebAdBanner(),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }
}

// ==========================================
// 6. REAKTYWNY EKRAN PROFILU
// ==========================================
class ProfilScreen extends StatelessWidget {
  final User user;
  const ProfilScreen({Key? key, required this.user}) : super(key: key);

  Widget _buildBadgeItem(String label, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color == Colors.grey ? Colors.grey[200] : AppColors.lightGreen,
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color == Colors.grey ? Colors.grey : AppColors.textDark),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = user.email ?? "eko.uzytkownik@eko.pl";
    final name = email.split('@')[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twój Profil EKO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('uzytkownicy').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final int butelki = data['butelki'] ?? 0;
          final int puszki = data['puszki'] ?? 0;
          final double co2 = (data['co2'] ?? 0.0).toDouble();
          final int totalCount = butelki + puszki;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.lightGreen,
                  child: Icon(Icons.person_rounded, size: 65, color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark, letterSpacing: -0.5),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    totalCount > 50 ? 'Status: Eko-Bohater 🏆' : 'Status: Nowy Ekolog 🌱',
                    style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade100)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(Icons.recycling_rounded, color: Colors.green, size: 36),
                              const SizedBox(height: 10),
                              Text('$totalCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              Text('Uratowane gabaryty', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade100)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(Icons.cloud_done_rounded, color: Colors.blue, size: 36),
                              const SizedBox(height: 10),
                              Text('${co2.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              Text('Redukcja śladu CO2', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 28),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Twoje Odznaki EKO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen, letterSpacing: -0.5)),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBadgeItem('Zgłaszający', Icons.explore_rounded, totalCount > 0 ? Colors.orange : Colors.grey),
                    _buildBadgeItem('Recykler', Icons.eco_rounded, totalCount > 10 ? Colors.green : Colors.grey),
                    _buildBadgeItem('Eko-Mistrz', Icons.nature_people_rounded, totalCount > 50 ? Colors.amber : Colors.grey),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.errorRed, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    icon: const Icon(Icons.logout, color: AppColors.errorRed),
                    label: const Text('Wyloguj się z profilu', style: TextStyle(color: AppColors.errorRed, fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () async => await FirebaseAuth.instance.signOut(),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 7. KALKULATOR (PODPIĘTY POD FIREBASE)
// ==========================================
class KalkulatorScreen extends StatefulWidget {
  const KalkulatorScreen({Key? key}) : super(key: key);
  @override
  State<KalkulatorScreen> createState() => _KalkulatorScreenState();
}

class _KalkulatorScreenState extends State<KalkulatorScreen> {
  int _plasticCount = 0;
  int _canCount = 0;
  double get _totalRefund => (_plasticCount + _canCount) * 0.50;

  void _zatwierdzZwrotWChmurze() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aby zapisać ten zwrot na swoim koncie, zaloguj się w zakładce Profil!"), backgroundColor: AppColors.accentOrange));
      return;
    }

    if (_plasticCount == 0 && _canCount == 0) return;

    try {
      await FirebaseFirestore.instance.collection('uzytkownicy').doc(user.uid).update({
        'butelki': FieldValue.increment(_plasticCount),
        'puszki': FieldValue.increment(_canCount),
        'saldo': FieldValue.increment(_totalRefund),
        'co2': FieldValue.increment((_plasticCount + _canCount) * 0.06),
      });

      await FirebaseFirestore.instance.collection('uzytkownicy').doc(user.uid).collection('historia').add({
        'tytul': 'Zwrot - Recyklomat',
        'kwota': '+ ${_totalRefund.toStringAsFixed(2)} zł',
        'ilosc': _plasticCount + _canCount,
        'data': DateTime.now().toString().substring(0, 16),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pomyślnie dopisano ${_totalRefund.toStringAsFixed(2)} zł do Twojego konta! 💰"), backgroundColor: AppColors.primaryGreen));

      setState(() {
        _plasticCount = 0;
        _canCount = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Błąd połączenia z Firebase."), backgroundColor: AppColors.errorRed));
    }
  }

  Widget _buildCounterRow(String label, int count, IconData icon, Function(int) onChange) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade100)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 28),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark))),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.grey, size: 26),
              onPressed: count > 0 ? () => onChange(count - 1) : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('$count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGreen, size: 26),
              onPressed: () => onChange(count + 1),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Kaucji', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Oficjalne polskie stawki kaucyjne (PET oraz Aluminium)', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          _buildCounterRow('Butelki Plastikowe (PET do 3L)', _plasticCount, Icons.local_drink_rounded, (val) => setState(() => _plasticCount = val)),
          _buildCounterRow('Puszki Metalowe / Alu (do 1L)', _canCount, Icons.view_headline_rounded, (val) => setState(() => _canCount = val)),
          const SizedBox(height: 24),
          Card(
            color: AppColors.lightGreen,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('PRZEWIDYWANY ZWROT KAUCJI', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGreen, fontSize: 12, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  Text('${_totalRefund.toStringAsFixed(2)} zł', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: AppColors.darkGreen, letterSpacing: -0.5)),
                  const SizedBox(height: 12),
                  Text('Łączna liczba opakowań: ${_plasticCount + _canCount} szt.', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14))
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: (_plasticCount == 0 && _canCount == 0) ? null : _zatwierdzZwrotWChmurze,
              icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
              label: const Text('Zatwierdź zwrot w recyklomacie', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
          const WebAdBanner(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}