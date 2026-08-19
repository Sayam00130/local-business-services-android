import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LocalBusinessServicesApp());
}

/* ============================================================
   APP
============================================================ */

class LocalBusinessServicesApp extends StatelessWidget {
  const LocalBusinessServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Business & Services',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const SplashPage(),
    );
  }
}

/* ============================================================
   MODELS
============================================================ */

class Business {
  final String id;
  final String name;
  final String category;
  final String address;
  final String phone;
  final String mapsUrl;
  final String website;
  final String description;
  final double rating;
  final int reviewCount;
  final bool openNow;
  final String ownerId;
  final String status;
  final bool premium;

  const Business({
    this.id = '',
    required this.name,
    required this.category,
    required this.address,
    this.phone = '',
    this.mapsUrl = '',
    this.website = '',
    this.description = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.openNow = false,
    this.ownerId = '',
    this.status = 'approved',
    this.premium = false,
  });

  factory Business.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return Business(
      id: id,
      name: data['name']?.toString() ?? 'Business',
      category: data['category']?.toString() ?? 'Business',
      address: data['address']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      mapsUrl: data['mapsUrl']?.toString() ?? '',
      website: data['website']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      rating: data['rating'] is num
          ? (data['rating'] as num).toDouble()
          : 0,
      reviewCount: data['reviewCount'] is num
          ? (data['reviewCount'] as num).toInt()
          : 0,
      openNow: data['openNow'] == true,
      ownerId: data['ownerId']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      premium: data['premium'] == true,
    );
  }
}

/* ============================================================
   APP CONFIG
============================================================ */

class AppConfig {
  // Change this email to YOUR Firebase admin email.
  // Firestore rules must use the same admin email/UID strategy.
  static const String adminEmail = 'admin@example.com';

  static const int monthlyPremiumPrice = 2000;

  static const String premiumName = 'Monthly Premium';

  static const String adLabel = 'Advertisement';
}

/* ============================================================
   FIREBASE SERVICE
============================================================ */

class FirebaseService {
  static final FirebaseFirestore db =
      FirebaseFirestore.instance;

  static final FirebaseAuth auth =
      FirebaseAuth.instance;

  static User? get user => auth.currentUser;

  static bool get loggedIn => user != null;

  static bool get isAdmin {
    final email = user?.email?.toLowerCase().trim();

    return email != null &&
        email.isNotEmpty &&
        email == AppConfig.adminEmail.toLowerCase();
  }

  static Future<bool> isPremium() async {
    final current = user;

    if (current == null) return false;

    final doc = await db
        .collection('users')
        .doc(current.uid)
        .get();

    if (!doc.exists) return false;

    final data = doc.data();

    if (data == null) return false;

    final premium = data['premium'] == true;

    if (!premium) return false;

    final expiry = data['premiumExpiry'];

    if (expiry is Timestamp) {
      return expiry.toDate().isAfter(DateTime.now());
    }

    return false;
  }

  static Future<Map<String, dynamic>?> userData() async {
    final current = user;

    if (current == null) return null;

    final doc = await db
        .collection('users')
        .doc(current.uid)
        .get();

    return doc.data();
  }
}

/* ============================================================
   SPLASH
============================================================ */

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue,
              Colors.indigo,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.business,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 22),
              Text(
                'Local Business\n& Services',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Find businesses and services anywhere',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   HOME
============================================================ */

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Business> favorites = [];

  bool isFavorite(Business business) {
    return favorites.any(
      (item) => item.id == business.id,
    );
  }

  void toggleFavorite(Business business) {
    setState(() {
      if (isFavorite(business)) {
        favorites.removeWhere(
          (item) => item.id == business.id,
        );
      } else {
        favorites.add(business);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(
        isFavorite: isFavorite,
        onFavorite: toggleFavorite,
      ),
      SearchPage(
        isFavorite: isFavorite,
        onFavorite: toggleFavorite,
      ),
      NearbyPage(
        isFavorite: isFavorite,
        onFavorite: toggleFavorite,
      ),
      FavoritesPage(
        favorites: favorites,
        onFavorite: toggleFavorite,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Local Business & Services',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(
              Icons.notifications_outlined,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const NotificationsPage(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(
              Icons.person_outline,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: pages[selectedIndex],
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AddBusinessPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.add_business,
              ),
              label: const Text(
                'List Your Business',
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   HOME TAB
============================================================ */

class HomeTab extends StatelessWidget {
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const HomeTab({
    super.key,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      [Icons.restaurant, 'Restaurants'],
      [Icons.local_hospital, 'Healthcare'],
      [Icons.electrical_services, 'Electricians'],
      [Icons.plumbing, 'Plumbers'],
      [Icons.car_repair, 'Mechanics'],
      [Icons.store, 'Shops'],
      [Icons.school, 'Schools'],
      [Icons.hotel, 'Hotels'],
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        110,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.blue,
                Colors.indigo,
              ],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find What You Need',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Discover businesses and professional services anywhere in the world.',
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchPage(
                  isFavorite: isFavorite,
                  onFavorite: onFavorite,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.search),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Search businesses or services...',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        const AdPlaceholder(),
        const SizedBox(height: 25),
        const Text(
          'Explore Categories',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: .82,
          children: categories.map((category) {
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategorySearchPage(
                      title: category[1] as String,
                      isFavorite: isFavorite,
                      onFavorite: onFavorite,
                    ),
                  ),
                );
              },
              child: Card(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      category[0] as IconData,
                      color: Colors.blue,
                      size: 29,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      category[1] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 25),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.workspace_premium),
            ),
            title: const Text(
              'Go Premium',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Rs. 2,000/month',
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PremiumPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/* ============================================================
   ADS STRUCTURE
============================================================ */

class AdPlaceholder extends StatelessWidget {
  const AdPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService.user;

    if (user == null) {
      return _adBox();
    }

    return FutureBuilder<bool>(
      future: FirebaseService.isPremium(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return const SizedBox.shrink();
        }

        return _adBox();
      },
    );
  }

  Widget _adBox() {
    return Container(
      height: 70,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppConfig.adLabel,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Ad space',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   GOOGLE PLACES
============================================================ */

class PlacesService {
  static const apiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
  );

  static Future<List<Business>> search(
    String query,
  ) async {
    if (apiKey.isEmpty) {
      throw Exception(
        'Google Places API key is missing.',
      );
    }

    final response = await http.post(
      Uri.parse(
        'https://places.googleapis.com/v1/places:searchText',
      ),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'places.id,places.displayName,places.formattedAddress,places.primaryType,places.rating,places.userRatingCount,places.nationalPhoneNumber,places.internationalPhoneNumber,places.googleMapsUri,places.websiteUri,places.currentOpeningHours',
      },
      body: jsonEncode({
        'textQuery': query,
        'pageSize': 20,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Places API error: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    final places = data['places'];

    if (places is! List) {
      return [];
    }

    return places.map<Business>((place) {
      final display = place['displayName'];

      final name = display is Map
          ? (display['text'] ?? 'Unknown Business')
              .toString()
          : 'Unknown Business';

      final rating = place['rating'] is num
          ? (place['rating'] as num).toDouble()
          : 0.0;

      final reviews =
          place['userRatingCount'] is num
              ? (place['userRatingCount'] as num).toInt()
              : 0;

      final opening = place['currentOpeningHours'];

      return Business(
        id: place['id']?.toString() ?? name,
        name: name,
        category: (place['primaryType'] ?? 'Business')
            .toString()
            .replaceAll('_', ' '),
        address:
            place['formattedAddress']?.toString() ??
                'Address unavailable',
        phone:
            place['internationalPhoneNumber']?.toString() ??
                place['nationalPhoneNumber']?.toString() ??
                '',
        mapsUrl:
            place['googleMapsUri']?.toString() ?? '',
        website:
            place['websiteUri']?.toString() ?? '',
        rating: rating,
        reviewCount: reviews,
        openNow:
            opening is Map && opening['openNow'] == true,
      );
    }).toList();
  }
}

/* ============================================================
   SEARCH
============================================================ */

class SearchPage extends StatefulWidget {
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const SearchPage({
    super.key,
    this.isFavorite = _falseFavorite,
    this.onFavorite = _emptyFavorite,
  });

  static bool _falseFavorite(Business business) => false;

  static void _emptyFavorite(Business business) {}

  @override
  State<SearchPage> createState() =>
      _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();

  List<Business> results = [];

  bool loading = false;

  String error = '';

  Future<void> search() async {
    final query = controller.text.trim();

    if (query.isEmpty) return;

    setState(() {
      loading = true;
      error = '';
      results = [];
    });

    try {
      final data =
          await PlacesService.search(query);

      if (!mounted) return;

      setState(() {
        results = data;
        loading = false;

        if (data.isEmpty) {
          error = 'No businesses found.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Businesses',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              textInputAction:
                  TextInputAction.search,
              onSubmitted: (_) => search(),
              decoration: InputDecoration(
                hintText:
                    'Business, service or city...',
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: search,
                  icon: const Icon(Icons.search),
                ),
                border:
                    const OutlineInputBorder(),
              ),
            ),
          ),
          const AdPlaceholder(),
          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : error.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(20),
                          child: Text(
                            error,
                            textAlign:
                                TextAlign.center,
                          ),
                        ),
                      )
                    : results.isEmpty
                        ? const Center(
                            child: Text(
                              'Search for a business or service.',
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.all(16),
                            itemCount:
                                results.length,
                            itemBuilder: (_, index) {
                              final business =
                                  results[index];

                              return BusinessCard(
                                business: business,
                                favorite:
                                    widget.isFavorite(
                                  business,
                                ),
                                onFavorite: () {
                                  widget.onFavorite(
                                    business,
                                  );
                                  setState(() {});
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   CATEGORY
============================================================ */

class CategorySearchPage
    extends StatefulWidget {
  final String title;
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const CategorySearchPage({
    super.key,
    required this.title,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  State<CategorySearchPage> createState() =>
      _CategorySearchPageState();
}

class _CategorySearchPageState
    extends State<CategorySearchPage> {
  bool loading = true;

  String error = '';

  List<Business> businesses = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final data = await PlacesService.search(
        '${widget.title} near me',
      );

      if (!mounted) return;

      setState(() {
        businesses = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error.isNotEmpty
              ? Center(child: Text(error))
              : businesses.isEmpty
                  ? const Center(
                      child: Text(
                        'No businesses found.',
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.all(16),
                      itemCount: businesses.length,
                      itemBuilder: (_, index) {
                        final business =
                            businesses[index];

                        return BusinessCard(
                          business: business,
                          favorite:
                              widget.isFavorite(
                            business,
                          ),
                          onFavorite: () {
                            widget.onFavorite(
                              business,
                            );
                            setState(() {});
                          },
                        );
                      },
                    ),
    );
  }
}

/* ============================================================
   NEARBY
============================================================ */

class NearbyPage extends StatefulWidget {
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const NearbyPage({
    super.key,
    this.isFavorite =
        SearchPage._falseFavorite,
    this.onFavorite =
        SearchPage._emptyFavorite,
  });

  @override
  State<NearbyPage> createState() =>
      _NearbyPageState();
}

class _NearbyPageState
    extends State<NearbyPage> {
  final controller = TextEditingController();

  List<Business> businesses = [];

  bool loading = false;

  String error = '';

  Future<void> search() async {
    final location =
        controller.text.trim();

    if (location.isEmpty) {
      setState(() {
        error = 'Enter a city or area.';
      });
      return;
    }

    setState(() {
      loading = true;
      error = '';
      businesses = [];
    });

    try {
      final data =
          await PlacesService.search(
        'businesses in $location',
      );

      if (!mounted) return;

      setState(() {
        businesses = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Nearby Businesses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              textInputAction:
                  TextInputAction.search,
              onSubmitted: (_) => search(),
              decoration: InputDecoration(
                hintText:
                    'Enter city or area',
                prefixIcon: const Icon(
                  Icons.location_on,
                ),
                suffixIcon: IconButton(
                  onPressed: search,
                  icon:
                      const Icon(Icons.search),
                ),
                border:
                    const OutlineInputBorder(),
              ),
            ),
          ),
          const AdPlaceholder(),
          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : error.isNotEmpty
                    ? Center(
                        child: Text(error),
                      )
                    : businesses.isEmpty
                        ? const Center(
                            child: Text(
                              'Enter a city or area to find businesses.',
                              textAlign:
                                  TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.all(16),
                            itemCount:
                                businesses.length,
                            itemBuilder:
                                (_, index) {
                              final business =
                                  businesses[index];

                              return BusinessCard(
                                business:
                                    business,
                                favorite: widget
                                    .isFavorite(
                                  business,
                                ),
                                onFavorite: () {
                                  widget.onFavorite(
                                    business,
                                  );
                                  setState(() {});
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   BUSINESS CARD
============================================================ */

class BusinessCard
    extends StatelessWidget {
  final Business business;
  final bool favorite;
  final VoidCallback? onFavorite;

  const BusinessCard({
    super.key,
    required this.business,
    this.favorite = false,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  BusinessDetailsPage(
                business: business,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(
                      business.name.isEmpty
                          ? 'B'
                          : business.name[0]
                              .toUpperCase(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            business.name,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (business.premium)
                          const Padding(
                            padding:
                                EdgeInsets.only(
                                    left: 5),
                            child: Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onFavorite,
                    icon: Icon(
                      favorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: favorite
                          ? Colors.red
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                business.category,
                style:
                    const TextStyle(
                  color: Colors.blue,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 18,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    business.rating > 0
                        ? business.rating
                            .toStringAsFixed(1)
                        : 'No rating',
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '(${business.reviewCount})',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  if (business.openNow)
                    const Text(
                      'Open',
                      style:
                          TextStyle(
                        color: Colors.green,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                business.address,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   BUSINESS DETAILS
============================================================ */

class BusinessDetailsPage
    extends StatelessWidget {
  final Business business;

  const BusinessDetailsPage({
    super.key,
    required this.business,
  });

  Future<void> openLink(
    BuildContext context,
    String value,
  ) async {
    if (value.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Information is not available.',
          ),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(value);

    if (uri == null) return;

    try {
      await launchUrl(uri);
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open the link.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Business Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.indigo,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 42,
                backgroundColor:
                    Colors.white,
                child: Text(
                  business.name.isEmpty
                      ? 'B'
                      : business.name[0]
                          .toUpperCase(),
                  style:
                      const TextStyle(
                    fontSize: 36,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  business.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              if (business.premium)
                const Icon(
                  Icons.verified,
                  color: Colors.blue,
                  size: 30,
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            business.category,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          Text(business.address),
          if (business.description
              .isNotEmpty) ...[
            const SizedBox(height: 15),
            Text(
              business.description,
              style:
                  const TextStyle(
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    final phone =
                        business.phone
                            .replaceAll(
                      RegExp(r'[^\d+]'),
                      '',
                    );

                    if (phone.isNotEmpty) {
                      openLink(
                        context,
                        'tel:$phone',
                      );
                    }
                  },
                  icon:
                      const Icon(Icons.call),
                  label:
                      const Text('Call'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    final phone =
                        business.phone
                            .replaceAll(
                      RegExp(r'[^\d]'),
                      '',
                    );

                    if (phone.isNotEmpty) {
                      openLink(
                        context,
                        'https://wa.me/$phone',
                      );
                    }
                  },
                  icon:
                      const Icon(Icons.chat),
                  label:
                      const Text('WhatsApp'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (business.mapsUrl.isNotEmpty)
            Card(
              child: ListTile(
                leading:
                    const CircleAvatar(
                  child: Icon(Icons.map),
                ),
                title: const Text(
                  'Open in Google Maps',
                ),
                onTap: () => openLink(
                  context,
                  business.mapsUrl,
                ),
              ),
            ),
          if (business.website.isNotEmpty)
            Card(
              child: ListTile(
                leading:
                    const CircleAvatar(
                  child:
                      Icon(Icons.language),
                ),
                title: const Text(
                  'Visit Website',
                ),
                onTap: () => openLink(
                  context,
                  business.website,
                ),
              ),
            ),
          Card(
            child: ListTile(
              leading:
                  const CircleAvatar(
                child: Icon(Icons.star),
              ),
              title: const Text(
                'Ratings & Reviews',
              ),
              subtitle: Text(
                business.reviewCount > 0
                    ? '${business.reviewCount} reviews'
                    : 'View reviews',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ReviewsPage(
                      business: business,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   REVIEWS
============================================================ */

class ReviewsPage extends StatelessWidget {
  final Business business;

  const ReviewsPage({
    super.key,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Ratings & Reviews'),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          if (FirebaseAuth
                  .instance
                  .currentUser ==
              null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const LoginPage(),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  WriteReviewPage(
                business: business,
              ),
            ),
          );
        },
        icon: const Icon(
          Icons.rate_review,
        ),
        label: const Text(
          'Write Review',
        ),
      ),
      body:
          StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore
            .instance
            .collection('businesses')
            .doc(business.id)
            .collection('reviews')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        builder:
            (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Could not load reviews.',
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          return ListView(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              100,
            ),
            children: [
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Text(
                        business.rating > 0
                            ? business.rating
                                .toStringAsFixed(
                                    1)
                            : '0.0',
                        style:
                            const TextStyle(
                          fontSize: 45,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.star,
                        color:
                            Colors.amber,
                        size: 32,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        '${business.reviewCount} total reviews',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              if (docs.isEmpty)
                const Card(
                  child: Padding(
                    padding:
                        EdgeInsets.all(25),
                    child: Text(
                      'No reviews yet. Be the first to review this business.',
                      textAlign:
                          TextAlign.center,
                    ),
                  ),
                ),
              ...docs.map((doc) {
                final data = doc.data()
                    as Map<String,
                        dynamic>;

                return Card(
                  margin:
                      const EdgeInsets.only(
                          bottom: 10),
                  child: ListTile(
                    leading:
                        const CircleAvatar(
                      child:
                          Icon(Icons.person),
                    ),
                    title: Text(
                      data['name']
                              ?.toString() ??
                          'Customer',
                    ),
                    subtitle: Text(
                      data['comment']
                              ?.toString() ??
                          '',
                    ),
                    trailing: Text(
                      '${data['rating'] ?? 0}★',
                    ),
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

class WriteReviewPage
    extends StatefulWidget {
  final Business business;

  const WriteReviewPage({
    super.key,
    required this.business,
  });

  @override
  State<WriteReviewPage> createState() =>
      _WriteReviewPageState();
}

class _WriteReviewPageState
    extends State<WriteReviewPage> {
  double rating = 5;

  final controller =
      TextEditingController();

  bool saving = false;

  Future<void> submit() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LoginPage(),
        ),
      );
      return;
    }

    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please write your review.',
          ),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('businesses')
          .doc(widget.business.id)
          .collection('reviews')
          .add({
        'userId': user.uid,
        'name': user.displayName ??
            user.email
                ?.split('@')
                .first ??
            'Customer',
        'rating': rating,
        'comment':
            controller.text.trim(),
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Review submitted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Review failed: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Write a Review'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          Text(
            widget.business.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          const Center(
            child: Text(
              'Your Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      rating =
                          index + 1.0;
                    });
                  },
                  icon: Icon(
                    index < rating
                        ? Icons.star
                        : Icons.star_border,
                    color:
                        Colors.amber,
                    size: 40,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: controller,
            maxLines: 6,
            decoration:
                const InputDecoration(
              hintText:
                  'Write your experience...',
              border:
                  OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed:
                saving ? null : submit,
            icon:
                const Icon(Icons.send),
            label: Text(
              saving
                  ? 'Submitting...'
                  : 'Submit Review',
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   FAVORITES
============================================================ */

class FavoritesPage
    extends StatelessWidget {
  final List<Business> favorites;

  final void Function(Business)
      onFavorite;

  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 15),
            Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Save businesses here for quick access.',
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding:
          const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (_, index) {
        return BusinessCard(
          business: favorites[index],
          favorite: true,
          onFavorite: () {
            onFavorite(
              favorites[index],
            );
          },
        );
      },
    );
  }
}

/* ============================================================
   LOGIN
============================================================ */

class LoginPage
    extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {
  final email =
      TextEditingController();

  final password =
      TextEditingController();

  bool obscure = true;

  bool loading = false;

  Future<void> login() async {
    if (email.text.trim().isEmpty ||
        password.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Enter email and password.',
          ),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const ProfilePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.message ??
                'Login failed.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Login')),
      body: ListView(
        padding:
            const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 45,
            child: Icon(
              Icons.person,
              size: 50,
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Welcome Back',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: email,
            keyboardType:
                TextInputType.emailAddress,
            decoration:
                const InputDecoration(
              labelText: 'Email',
              prefixIcon:
                  Icon(Icons.email_outlined),
              border:
                  OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: password,
            obscureText: obscure,
            decoration:
                InputDecoration(
              labelText: 'Password',
              prefixIcon:
                  const Icon(
                Icons.lock_outline,
              ),
              suffixIcon:
                  IconButton(
                onPressed: () {
                  setState(() {
                    obscure =
                        !obscure;
                  });
                },
                icon: Icon(
                  obscure
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
              border:
                  const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed:
                loading ? null : login,
            child: Padding(
              padding:
                  const EdgeInsets.all(14),
              child: Text(
                loading
                    ? 'Logging in...'
                    : 'Login',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SignupPage(),
                ),
              );
            },
            child: const Text(
              'Create a new account',
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   SIGNUP
============================================================ */

class SignupPage
    extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() =>
      _SignupPageState();
}

class _SignupPageState
    extends State<SignupPage> {
  final name =
      TextEditingController();

  final email =
      TextEditingController();

  final password =
      TextEditingController();

  final confirm =
      TextEditingController();

  bool loading = false;

  Future<void> signup() async {
    if (name.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        password.text.isEmpty ||
        confirm.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Complete all fields.',
          ),
        ),
      );
      return;
    }

    if (password.text !=
        confirm.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords do not match.',
          ),
        ),
      );
      return;
    }

    if (password.text.length < 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Password must be at least 6 characters.',
          ),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      await credential.user
          ?.updateDisplayName(
        name.text.trim(),
      );

      final user =
          credential.user;

      if (user != null) {
        await FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'name': name.text.trim(),
          'email': email.text.trim(),
          'premium': false,
          'premiumExpiry': null,
          'createdAt':
              FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const ProfilePage(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.message ??
                'Signup failed.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Create Account'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(24),
        children: [
          const Text(
            'Join Local Business & Services',
            style: TextStyle(
              fontSize: 26,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: name,
            decoration:
                const InputDecoration(
              labelText: 'Full Name',
              prefixIcon:
                  Icon(Icons.person_outline),
              border:
                  OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: email,
            keyboardType:
                TextInputType.emailAddress,
            decoration:
                const InputDecoration(
              labelText: 'Email',
              prefixIcon:
                  Icon(Icons.email_outlined),
              border:
                  OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: password,
            obscureText: true,
            decoration:
                const InputDecoration(
              labelText: 'Password',
              prefixIcon:
                  Icon(Icons.lock_outline),
              border:
                  OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: confirm,
            obscureText: true,
            decoration:
                const InputDecoration(
              labelText:
                  'Confirm Password',
              prefixIcon:
                  Icon(Icons.lock_outline),
              border:
                  OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed:
                loading ? null : signup,
            child: Padding(
              padding:
                  const EdgeInsets.all(14),
              child: Text(
                loading
                    ? 'Creating account...'
                    : 'Create Account',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   PROFILE
============================================================ */

class ProfilePage
    extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('My Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 45,
                child: Icon(
                  Icons.person,
                  size: 50,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'You are not logged in.',
                style:
                    TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LoginPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.login,
                ),
                label:
                    const Text('Login'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SignupPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.person_add,
                ),
                label: const Text(
                  'Create Account',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('My Profile'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    child: Icon(
                      Icons.person,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.displayName ??
                        'User',
                    style:
                        const TextStyle(
                      fontSize: 23,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.email ?? '',
                  ),
                  const SizedBox(height: 12),
                  const PremiumStatusCard(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _profileButton(
            context,
            Icons.edit,
            'Edit Profile',
            const EditProfilePage(),
          ),
          _profileButton(
            context,
            Icons.business,
            'My Business',
            const MyBusinessPage(),
          ),
          _profileButton(
            context,
            Icons.rate_review,
            'My Reviews',
            const MyReviewsPage(),
          ),
          _profileButton(
            context,
            Icons.workspace_premium,
            'Premium',
            const PremiumPage(),
          ),
          if (FirebaseService.isAdmin)
            _profileButton(
              context,
              Icons.admin_panel_settings,
              'Admin Panel',
              const AdminPage(),
            ),
          _profileButton(
            context,
            Icons.settings,
            'Settings',
            const SettingsPage(),
          ),
          _profileButton(
            context,
            Icons.help_outline,
            'Help & Support',
            const HelpPage(),
          ),
          _profileButton(
            context,
            Icons.info_outline,
            'About',
            const AboutPage(),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title:
                  const Text('Logout'),
              onTap: () async {
                await FirebaseAuth
                    .instance
                    .signOut();

                if (!context.mounted) {
                  return;
                }

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const HomePage(),
                  ),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileButton(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },
      ),
    );
  }
}

/* ============================================================
   PREMIUM STATUS
============================================================ */

class PremiumStatusCard
    extends StatelessWidget {
  const PremiumStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseService.user;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: FirebaseService.userData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        final data = snapshot.data;

        final premium =
            data?['premium'] == true;

        DateTime? expiry;

        final value =
            data?['premiumExpiry'];

        if (value is Timestamp) {
          expiry = value.toDate();
        }

        final active = premium &&
            expiry != null &&
            expiry.isAfter(DateTime.now());

        if (active) {
          return Container(
            padding:
                const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: Colors.amber,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: Colors.orange,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Premium Active\nExpires: ${_date(expiry)}',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding:
              const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Premium is not active',
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _date(DateTime? date) {
    if (date == null) return '-';

    return '${date.day}/${date.month}/${date.year}';
  }
}

/* ============================================================
   EDIT PROFILE
============================================================ */

class EditProfilePage
    extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {
  late TextEditingController name;

  late TextEditingController email;

  @override
  void initState() {
    super.initState();

    final user =
        FirebaseAuth.instance.currentUser;

    name = TextEditingController(
      text: user?.displayName ?? '',
    );

    email = TextEditingController(
      text: user?.email ?? '',
    );
  }

  Future<void> save() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      await user.updateDisplayName(
        name.text.trim(),
      );

      await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': name.text.trim(),
        'email': user.email ??
            email.text.trim(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Profile saved successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Save failed: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Edit Profile'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          TextField(
            controller: name,
            decoration:
                const InputDecoration(
              labelText: 'Full Name',
              prefixIcon:
                  Icon(Icons.person),
              border:
                  OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: email,
            readOnly: true,
            decoration:
                const InputDecoration(
              labelText: 'Email',
              prefixIcon:
                  Icon(Icons.email),
              border:
                  OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: save,
            icon:
                const Icon(Icons.save),
            label:
                const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   ADD BUSINESS
============================================================ */

class AddBusinessPage
    extends StatefulWidget {
  const AddBusinessPage({super.key});

  @override
  State<AddBusinessPage> createState() =>
      _AddBusinessPageState();
}

class _AddBusinessPageState
    extends State<AddBusinessPage> {
  final name =
      TextEditingController();

  final category =
      TextEditingController();

  final address =
      TextEditingController();

  final phone =
      TextEditingController();

  final website =
      TextEditingController();

  final description =
      TextEditingController();

  bool saving = false;

  Future<void> submit() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LoginPage(),
        ),
      );
      return;
    }

    if (name.text.trim().isEmpty ||
        category.text.trim().isEmpty ||
        address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Business name, category and address are required.',
          ),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await FirebaseFirestore
          .instance
          .collection('businesses')
          .add({
        'ownerId': user.uid,
        'ownerEmail': user.email ?? '',
        'name': name.text.trim(),
        'category':
            category.text.trim(),
        'address':
            address.text.trim(),
        'phone':
            phone.text.trim(),
        'website':
            website.text.trim(),
        'description':
            description.text.trim(),
        'status': 'pending',
        'premium': false,
        'rating': 0,
        'reviewCount': 0,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Business submitted successfully. It is pending admin approval.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Submission failed: $e',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    name.dispose();
    category.dispose();
    address.dispose();
    phone.dispose();
    website.dispose();
    description.dispose();
    super.dispose();
  }

  Widget field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
              bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration:
            InputDecoration(
          labelText: label,
          prefixIcon:
              Icon(icon),
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List Your Business',
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          const Text(
            'Add Your Business',
            style: TextStyle(
              fontSize: 26,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your listing will be reviewed by the admin before appearing in the app.',
          ),
          const SizedBox(height: 22),
          field(
            name,
            'Business Name',
            Icons.business,
          ),
          field(
            category,
            'Category',
            Icons.category_outlined,
          ),
          field(
            address,
            'Address',
            Icons.location_on_outlined,
          ),
          field(
            phone,
            'Phone Number',
            Icons.phone_outlined,
            keyboard:
                TextInputType.phone,
          ),
          field(
            website,
            'Website',
            Icons.language,
            keyboard:
                TextInputType.url,
          ),
          field(
            description,
            'Business Description',
            Icons.description_outlined,
            maxLines: 5,
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed:
                saving ? null : submit,
            icon:
                const Icon(Icons.send),
            label: Text(
              saving
                  ? 'Submitting...'
                  : 'Submit Business',
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   MY BUSINESS
============================================================ */

class MyBusinessPage
    extends StatelessWidget {
  const MyBusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('My Business'),
        ),
        body: const Center(
          child:
              Text('Please login first.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('My Business'),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddBusinessPage(),
            ),
          );
        },
        icon: const Icon(
          Icons.add_business,
        ),
        label:
            const Text('Add Business'),
      ),
      body:
          StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore
            .instance
            .collection('businesses')
            .where(
              'ownerId',
              isEqualTo: user.uid,
            )
            .snapshots(),
        builder:
            (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                        20),
                child: Text(
                  'Could not load businesses.\n${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding:
                    EdgeInsets.all(30),
                child: Text(
                  'You have no business listings yet.\n\nTap Add Business to submit one.',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              100,
            ),
            children: [
              ...docs.map((doc) {
                final data =
                    doc.data()
                        as Map<String,
                            dynamic>;

                final status =
                    data['status']
                            ?.toString() ??
                        'pending';

                final premium =
                    data['premium'] == true;

                return Card(
                  margin:
                      const EdgeInsets.only(
                          bottom: 12),
                  child: ListTile(
                    leading:
                        const CircleAvatar(
                      child: Icon(
                        Icons.business,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            data['name']
                                    ?.toString() ??
                                'Business',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                        if (premium)
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                          ),
                      ],
                    ),
                    subtitle: Padding(
                      padding:
                          const EdgeInsets.only(
                              top: 6),
                      child: Text(
                        '${data['category'] ?? ''}\n${data['address'] ?? ''}',
                      ),
                    ),
                    isThreeLine: true,
                    trailing:
                        _statusChip(status),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style:
            TextStyle(
          fontSize: 10,
          color: color,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }
}

/* ============================================================
   MY REVIEWS
============================================================ */

class MyReviewsPage
    extends StatelessWidget {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('My Reviews'),
        ),
        body: const Center(
          child:
              Text('Please login first.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('My Reviews'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore
            .instance
            .collectionGroup('reviews')
            .where(
              'userId',
              isEqualTo: user.uid,
            )
            .snapshots(),
        builder:
            (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Could not load your reviews.',
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'You have not written any reviews yet.',
                textAlign:
                    TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder:
                (_, index) {
              final data =
                  docs[index].data()
                      as Map<String,
                          dynamic>;

              return Card(
                margin:
                    const EdgeInsets.only(
                        bottom: 12),
                child: ListTile(
                  leading:
                      const CircleAvatar(
                    child:
                        Icon(Icons.star),
                  ),
                  title: Text(
                    '${data['rating'] ?? 0}★',
                  ),
                  subtitle: Text(
                    data['comment']
                            ?.toString() ??
                        '',
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

/* ============================================================
   PREMIUM
============================================================ */

class PremiumPage
    extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() =>
      _PremiumPageState();
}

class _PremiumPageState
    extends State<PremiumPage> {
  bool loading = true;

  bool premium = false;

  DateTime? expiry;

  bool requestPending = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    try {
      final data =
          await FirebaseService.userData();

      final value =
          data?['premiumExpiry'];

      DateTime? date;

      if (value is Timestamp) {
        date = value.toDate();
      }

      final active =
          data?['premium'] == true &&
              date != null &&
              date.isAfter(DateTime.now());

      final request =
          await FirebaseFirestore
              .instance
              .collection('premiumRequests')
              .where(
                'userId',
                isEqualTo: user.uid,
              )
              .where(
                'status',
                isEqualTo: 'pending',
              )
              .limit(1)
              .get();

      if (!mounted) return;

      setState(() {
        premium = active;
        expiry = date;
        requestPending =
            request.docs.isNotEmpty;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> requestPremium() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LoginPage(),
        ),
      );
      return;
    }

    if (premium) {
      return;
    }

    if (requestPending) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Your premium request is already pending.',
          ),
        ),
      );
      return;
    }

    final method =
        await showDialog<String>(
      context: context,
      builder: (_) =>
          const PaymentMethodDialog(),
    );

    if (method == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('premiumRequests')
          .add({
        'userId': user.uid,
        'email': user.email ?? '',
        'name':
            user.displayName ?? '',
        'plan': 'monthly',
        'amount':
            AppConfig.monthlyPremiumPrice,
        'currency': 'PKR',
        'paymentMethod': method,
        'status': 'pending',
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        requestPending = true;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Premium request submitted. Admin will verify payment and activate your membership.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Request failed: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('Premium Plans'),
        ),
        body: const Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Premium Plans'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(18),
        children: [
          Container(
            padding:
                const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.indigo,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(22),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 55,
                ),
                SizedBox(height: 10),
                Text(
                  'Premium Membership',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'More visibility and premium account features.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Premium',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Rs. 2,000 / month',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '✓ Premium badge\n'
                    '✓ Enhanced business presence\n'
                    '✓ Priority placement options\n'
                    '✓ Premium account features\n'
                    '✓ No in-app ad placeholders while premium is active',
                    style:
                        TextStyle(height: 1.8),
                  ),
                  const SizedBox(height: 20),
                  if (premium)
                    Container(
                      padding:
                          const EdgeInsets.all(14),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.green.shade50,
                        borderRadius:
                            BorderRadius.circular(
                                12),
                      ),
                      child: Text(
                        'Premium Active\nExpiry: ${_date(expiry)}',
                        style:
                            const TextStyle(
                          color:
                              Colors.green,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    )
                  else if (requestPending)
                    Container(
                      padding:
                          const EdgeInsets.all(14),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.orange.shade50,
                        borderRadius:
                            BorderRadius.circular(
                                12),
                      ),
                      child: const Text(
                        'Payment request pending admin verification.',
                        style:
                            TextStyle(
                          color:
                              Colors.orange,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          FilledButton.icon(
                        onPressed:
                            requestPremium,
                        icon: const Icon(
                          Icons.workspace_premium,
                        ),
                        label: const Text(
                          'Request Premium',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Card(
            child: Padding(
              padding:
                  EdgeInsets.all(18),
              child: Text(
                'Payment is verified by the admin before premium access is activated. Do not enter sensitive banking passwords or PINs inside the app.',
                style:
                    TextStyle(height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _date(DateTime? date) {
    if (date == null) return '-';

    return '${date.day}/${date.month}/${date.year}';
  }
}

class PaymentMethodDialog
    extends StatelessWidget {
  const PaymentMethodDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          const Text('Payment Method'),
      content: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          const Text(
            'Select the method you used to pay Rs. 2,000.',
          ),
          const SizedBox(height: 15),
          ListTile(
            leading:
                const Icon(Icons.account_balance),
            title:
                const Text('Bank Transfer'),
            onTap: () =>
                Navigator.pop(
              context,
              'Bank Transfer',
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.phone_android),
            title:
                const Text('Mobile Wallet'),
            onTap: () =>
                Navigator.pop(
              context,
              'Mobile Wallet',
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.payment),
            title:
                const Text('Other'),
            onTap: () =>
                Navigator.pop(
              context,
              'Other',
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   ADMIN PANEL
============================================================ */

class AdminPage
    extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() =>
      _AdminPageState();
}

class _AdminPageState
    extends State<AdminPage> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    if (!FirebaseService.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('Admin Panel'),
        ),
        body: const Center(
          child: Text(
            'Admin access required.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Admin Panel'),
      ),
      body: tab == 0
          ? const AdminBusinesses()
          : const AdminPremiumRequests(),
      bottomNavigationBar:
          NavigationBar(
        selectedIndex: tab,
        onDestinationSelected:
            (value) {
          setState(() {
            tab = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon:
                Icon(Icons.business),
            label: 'Businesses',
          ),
          NavigationDestination(
            icon: Icon(
                Icons.workspace_premium),
            label: 'Premium',
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   ADMIN BUSINESSES
============================================================ */

class AdminBusinesses
    extends StatelessWidget {
  const AdminBusinesses({super.key});

  Future<void> approve(
    BuildContext context,
    String id,
  ) async {
    await FirebaseFirestore.instance
        .collection('businesses')
        .doc(id)
        .update({
      'status': 'approved',
      'approvedAt':
          FieldValue.serverTimestamp(),
      'approvedBy':
          FirebaseService.user?.uid ?? '',
    });

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text('Business approved.'),
      ),
    );
  }

  Future<void> reject(
    BuildContext context,
    String id,
  ) async {
    await FirebaseFirestore.instance
        .collection('businesses')
        .doc(id)
        .update({
      'status': 'rejected',
      'rejectedAt':
          FieldValue.serverTimestamp(),
      'rejectedBy':
          FirebaseService.user?.uid ?? '',
    });

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text('Business rejected.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore
          .instance
          .collection('businesses')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder:
          (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
            ),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        final docs =
            snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child:
                Text('No businesses yet.'),
          );
        }

        return ListView.builder(
          padding:
              const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder:
              (_, index) {
            final doc = docs[index];

            final data =
                doc.data()
                    as Map<String,
                        dynamic>;

            final status =
                data['status']
                        ?.toString() ??
                    'pending';

            return Card(
              margin:
                  const EdgeInsets.only(
                      bottom: 12),
              child: Padding(
                padding:
                    const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          child: Icon(
                            Icons.business,
                          ),
                        ),
                        const SizedBox(
                            width: 10),
                        Expanded(
                          child: Text(
                            data['name']
                                    ?.toString() ??
                                'Business',
                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 10),
                    Text(
                      'Category: ${data['category'] ?? ''}',
                    ),
                    Text(
                      'Address: ${data['address'] ?? ''}',
                    ),
                    Text(
                      'Owner: ${data['ownerEmail'] ?? ''}',
                    ),
                    const SizedBox(
                        height: 10),
                    Chip(
                      label: Text(
                        status
                            .toUpperCase(),
                      ),
                    ),
                    const SizedBox(
                        height: 8),
                    if (status !=
                        'approved')
                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            FilledButton.icon(
                          onPressed:
                              () => approve(
                            context,
                            doc.id,
                          ),
                          icon: const Icon(
                            Icons.check,
                          ),
                          label: const Text(
                            'Approve Business',
                          ),
                        ),
                      ),
                    if (status !=
                        'rejected')
                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            OutlinedButton.icon(
                          onPressed:
                              () => reject(
                            context,
                            doc.id,
                          ),
                          icon: const Icon(
                            Icons.close,
                          ),
                          label: const Text(
                            'Reject Business',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/* ============================================================
   ADMIN PREMIUM REQUESTS
============================================================ */

class AdminPremiumRequests
    extends StatelessWidget {
  const AdminPremiumRequests({
    super.key,
  });

  Future<void> approve(
    BuildContext context,
    String requestId,
    String userId,
    String? businessId,
  ) async {
    final expiry =
        DateTime.now().add(
      const Duration(days: 30),
    );

    final batch =
        FirebaseFirestore.instance.batch();

    final userRef =
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId);

    final requestRef =
        FirebaseFirestore.instance
            .collection('premiumRequests')
            .doc(requestId);

    batch.set(
      userRef,
      {
        'premium': true,
        'premiumPlan': 'monthly',
        'premiumPrice':
            AppConfig.monthlyPremiumPrice,
        'premiumExpiry':
            Timestamp.fromDate(expiry),
        'premiumActivatedAt':
            FieldValue.serverTimestamp(),
        'premiumActivatedBy':
            FirebaseService.user?.uid ?? '',
      },
      SetOptions(merge: true),
    );

    batch.update(
      requestRef,
      {
        'status': 'approved',
        'approvedAt':
            FieldValue.serverTimestamp(),
        'approvedBy':
            FirebaseService.user?.uid ?? '',
        'premiumExpiry':
            Timestamp.fromDate(expiry),
      },
    );

    if (businessId != null &&
        businessId.isNotEmpty) {
      final businessRef =
          FirebaseFirestore.instance
              .collection('businesses')
              .doc(businessId);

      batch.set(
        businessRef,
        {
          'premium': true,
          'premiumExpiry':
              Timestamp.fromDate(expiry),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text('Premium activated.'),
      ),
    );
  }

  Future<void> reject(
    BuildContext context,
    String requestId,
  ) async {
    await FirebaseFirestore.instance
        .collection('premiumRequests')
        .doc(requestId)
        .update({
      'status': 'rejected',
      'rejectedAt':
          FieldValue.serverTimestamp(),
      'rejectedBy':
          FirebaseService.user?.uid ?? '',
    });

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text('Premium request rejected.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore
          .instance
          .collection('premiumRequests')
          .where(
            'status',
            isEqualTo: 'pending',
          )
          .snapshots(),
      builder:
          (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
            ),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        final docs =
            snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No pending premium requests.',
            ),
          );
        }

        return ListView.builder(
          padding:
              const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder:
              (_, index) {
            final doc = docs[index];

            final data =
                doc.data()
                    as Map<String,
                        dynamic>;

            return Card(
              margin:
                  const EdgeInsets.only(
                      bottom: 12),
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Premium Request',
                          style:
                              TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 12),
                    Text(
                      'Name: ${data['name'] ?? ''}',
                    ),
                    Text(
                      'Email: ${data['email'] ?? ''}',
                    ),
                    Text(
                      'Plan: Monthly',
                    ),
                    Text(
                      'Amount: Rs. ${data['amount'] ?? AppConfig.monthlyPremiumPrice}',
                    ),
                    Text(
                      'Payment method: ${data['paymentMethod'] ?? ''}',
                    ),
                    const SizedBox(
                        height: 14),
                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          FilledButton.icon(
                        onPressed: () =>
                            approve(
                          context,
                          doc.id,
                          data['userId']
                                  ?.toString() ??
                              '',
                          data['businessId']
                              ?.toString(),
                        ),
                        icon: const Icon(
                          Icons.check,
                        ),
                        label: const Text(
                          'Approve & Activate',
                        ),
                      ),
                    ),
                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          OutlinedButton.icon(
                        onPressed: () =>
                            reject(
                          context,
                          doc.id,
                        ),
                        icon: const Icon(
                          Icons.close,
                        ),
                        label: const Text(
                          'Reject',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/* ============================================================
   NOTIFICATIONS
============================================================ */

class NotificationsPage
    extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('Notifications'),
        ),
        body: const Center(
          child:
              Text('Login to view notifications.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore
            .instance
            .collection('notifications')
            .where(
              'userId',
              isEqualTo: user.uid,
            )
            .snapshots(),
        builder:
            (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Could not load notifications.',
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No new notifications.',
                    style:
                        TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder:
                (_, index) {
              final data =
                  docs[index].data()
                      as Map<String,
                          dynamic>;

              return Card(
                child: ListTile(
                  leading:
                      const CircleAvatar(
                    child:
                        Icon(Icons.notifications),
                  ),
                  title: Text(
                    data['title']
                            ?.toString() ??
                        'Notification',
                  ),
                  subtitle: Text(
                    data['message']
                            ?.toString() ??
                        '',
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

/* ============================================================
   SETTINGS
============================================================ */

class SettingsPage
    extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading:
                const Icon(Icons.language),
            title:
                const Text('Language'),
            subtitle:
                const Text('English'),
          ),
          ListTile(
            leading: const Icon(
              Icons.notifications,
            ),
            title: const Text(
              'Notifications',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const NotificationsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.help),
            title:
                const Text('Help & Support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const HelpPage(),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AboutPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   HELP
============================================================ */

class HelpPage
    extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Help & Support'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          const Text(
            'How can we help?',
            style: TextStyle(
              fontSize: 26,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Use Search and Nearby to discover businesses and services.',
          ),
          const SizedBox(height: 12),
          const Text(
            'Create an account to add businesses and write reviews.',
          ),
          const SizedBox(height: 12),
          const Text(
            'Business listings are reviewed by the administrator before approval.',
          ),
          const SizedBox(height: 12),
          const Text(
            'Premium costs Rs. 2,000 per month and is activated after payment verification.',
          ),
          const SizedBox(height: 12),
          const Text(
            'Premium users do not see the in-app ad placeholders.',
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   ABOUT
============================================================ */

class AboutPage
    extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('About')),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 45,
                child: Icon(
                  Icons.business,
                  size: 50,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Local Business & Services',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'A platform for discovering local businesses and professional services.',
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(height: 18),
              const Text('Version 1.0'),
            ],
          ),
        ),
      ),
    );
  }
}
