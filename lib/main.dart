import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const LocalBusinessServicesApp());
}

// ============================================================
// APP
// ============================================================

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
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}

// ============================================================
// APP DATA
// ============================================================

class AppData {
  static String? currentUserEmail;
  static String? currentUserName;

  static final List<AppUser> users = [
    AppUser(
      name: 'Demo User',
      email: 'demo@example.com',
      password: '123456',
      phone: '923000000000',
    ),
  ];

  static final List<BusinessRecord> businesses = [];

  static final List<AppNotification> notifications = [];

  static bool get isLoggedIn =>
      currentUserEmail != null && currentUserEmail!.isNotEmpty;

  static AppUser? get currentUser {
    if (!isLoggedIn) return null;

    try {
      return users.firstWhere(
        (user) => user.email.toLowerCase() ==
            currentUserEmail!.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static void logout() {
    currentUserEmail = null;
    currentUserName = null;
  }
}

// ============================================================
// MODELS
// ============================================================

class AppUser {
  String name;
  String email;
  String password;
  String phone;

  AppUser({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });
}

class BusinessRecord {
  String id;
  String ownerEmail;
  String businessName;
  String category;
  String description;
  String phone;
  String address;
  String city;
  String website;
  String status;
  bool premium;
  DateTime? premiumExpiry;

  BusinessRecord({
    required this.id,
    required this.ownerEmail,
    required this.businessName,
    required this.category,
    required this.description,
    required this.phone,
    required this.address,
    required this.city,
    required this.website,
    this.status = 'Pending',
    this.premium = false,
    this.premiumExpiry,
  });
}

class Business {
  final String id;
  final String name;
  final String category;
  final String address;
  final String phone;
  final String mapsUrl;
  final String website;
  final double rating;
  final int reviewCount;
  final bool openNow;

  const Business({
    this.id = '',
    required this.name,
    required this.category,
    required this.address,
    this.phone = '',
    this.mapsUrl = '',
    this.website = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.openNow = false,
  });
}

class AppReview {
  final String name;
  final double rating;
  final String comment;
  final String date;

  const AppReview({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class AppNotification {
  final String title;
  final String message;
  final DateTime date;

  AppNotification({
    required this.title,
    required this.message,
    required this.date,
  });
}

// ============================================================
// HELPERS
// ============================================================

String businessStatusColorText(String status) {
  return status;
}

Future<void> openExternal(String value) async {
  if (value.trim().isEmpty) return;

  final uri = Uri.tryParse(value);

  if (uri == null) return;

  try {
    await launchUrl(uri);
  } catch (_) {}
}

Future<void> makePhoneCall(String phone) async {
  if (phone.trim().isEmpty) return;

  final clean = phone.replaceAll(' ', '');
  final uri = Uri.parse('tel:$clean');

  try {
    await launchUrl(uri);
  } catch (_) {}
}

Future<void> openWhatsApp(String phone) async {
  if (phone.trim().isEmpty) return;

  String clean = phone.replaceAll(
    RegExp(r'[^0-9]'),
    '',
  );

  if (clean.startsWith('0')) {
    clean = '92${clean.substring(1)}';
  }

  if (!clean.startsWith('92')) {
    clean = '92$clean';
  }

  final uri = Uri.parse(
    'https://wa.me/$clean',
  );

  try {
    await launchUrl(uri);
  } catch (_) {}
}

Future<void> openMapsForAddress(String address) async {
  if (address.trim().isEmpty) return;

  final encoded = Uri.encodeComponent(address);

  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$encoded',
  );

  try {
    await launchUrl(uri);
  } catch (_) {}
}

void showMessage(
  BuildContext context,
  String message, {
  bool error = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red : null,
    ),
  );
}

// ============================================================
// SPLASH
// ============================================================

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
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.business,
                  size: 58,
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
                'Discover businesses around the world',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 35),
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

// ============================================================
// HOME
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

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

  void refreshPage() {
    setState(() {});
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
            icon: const Icon(
              Icons.person_outline,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: pages[currentIndex],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!AppData.isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginPage(),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddBusinessPage(),
            ),
          );
        },
        icon: const Icon(Icons.add_business),
        label: const Text('List Your Business'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
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
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.location_on_outlined,
            ),
            selectedIcon: Icon(
              Icons.location_on,
            ),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.favorite_border,
            ),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME TAB
// ============================================================

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
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        120,
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
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
                  fontSize: 15,
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
                builder: (_) => const SearchPage(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
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
        const SizedBox(height: 28),
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
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: .85,
          children: [
            categoryItem(
              context,
              Icons.restaurant,
              'Restaurants',
            ),
            categoryItem(
              context,
              Icons.local_hospital,
              'Healthcare',
            ),
            categoryItem(
              context,
              Icons.electrical_services,
              'Electricians',
            ),
            categoryItem(
              context,
              Icons.plumbing,
              'Plumbers',
            ),
            categoryItem(
              context,
              Icons.car_repair,
              'Mechanics',
            ),
            categoryItem(
              context,
              Icons.store,
              'Shops',
            ),
            categoryItem(
              context,
              Icons.school,
              'Schools',
            ),
            categoryItem(
              context,
              Icons.hotel,
              'Hotels',
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        quickCard(
          context,
          Icons.search,
          'Search Businesses',
          'Find businesses and services worldwide.',
          const SearchPage(),
        ),
        quickCard(
          context,
          Icons.location_on,
          'Nearby Businesses',
          'Discover businesses around your area.',
          const NearbyPage(),
        ),
        quickCard(
          context,
          Icons.add_business,
          'List Your Business',
          'Add your business to the platform.',
          const AddBusinessPage(),
        ),
      ],
    );
  }

  Widget categoryItem(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategorySearchPage(
              title: title,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 30,
            ),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget quickCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(8),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 15,
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

// ============================================================
// GOOGLE PLACES
// ============================================================

class PlacesService {
  static const String apiKey =
      String.fromEnvironment(
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
      String message =
          'Places API error (${response.statusCode})';

      try {
        final data =
            jsonDecode(response.body);

        if (data is Map &&
            data['error'] is Map &&
            data['error']['message'] != null) {
          message = data['error']['message']
              .toString();
        }
      } catch (_) {}

      throw Exception(message);
    }

    final data = jsonDecode(
      response.body,
    );

    final places = data['places'];

    if (places is! List) {
      return [];
    }

    return places.map<Business>((place) {
      final displayName =
          place['displayName'];

      final name = displayName is Map
          ? (displayName['text'] ??
                  'Unknown Business')
              .toString()
          : 'Unknown Business';

      final category =
          (place['primaryType'] ??
                  'Business')
              .toString()
              .replaceAll('_', ' ');

      final address =
          place['formattedAddress']
                  ?.toString() ??
              'Address unavailable';

      final international =
          place[
              'internationalPhoneNumber'];

      final national =
          place['nationalPhoneNumber'];

      final phone =
          international != null &&
                  international
                      .toString()
                      .isNotEmpty
              ? international.toString()
              : (national?.toString() ?? '');

      final mapsUrl =
          place['googleMapsUri']
                  ?.toString() ??
              '';

      final website =
          place['websiteUri']
                  ?.toString() ??
              '';

      final ratingValue =
          place['rating'];

      final rating = ratingValue is num
          ? ratingValue.toDouble()
          : 0.0;

      final reviewValue =
          place['userRatingCount'];

      final reviewCount =
          reviewValue is num
              ? reviewValue.toInt()
              : 0;

      bool openNow = false;

      final opening =
          place['currentOpeningHours'];

      if (opening is Map &&
          opening['openNow'] is bool) {
        openNow = opening['openNow'];
      }

      return Business(
        id: place['id']?.toString() ??
            name,
        name: name,
        category: category,
        address: address,
        phone: phone,
        mapsUrl: mapsUrl,
        website: website,
        rating: rating,
        reviewCount: reviewCount,
        openNow: openNow,
      );
    }).toList();
  }
}

// ============================================================
// BUSINESS CARD
// ============================================================

class BusinessCard extends StatelessWidget {
  final Business business;
  final bool favorite;
  final VoidCallback onFavorite;

  const BusinessCard({
    super.key,
    required this.business,
    required this.favorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
                    radius: 27,
                    child: Text(
                      business.name.isNotEmpty
                          ? business.name[0]
                              .toUpperCase()
                          : 'B',
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          business.name,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          business.category,
                          style:
                              TextStyle(
                            color: Colors
                                .grey.shade700,
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
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      business.address,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (business.rating > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 18,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      business.rating
                          .toStringAsFixed(1),
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '(${business.reviewCount} reviews)',
                      style: TextStyle(
                        color: Colors
                            .grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      business.openNow
                          ? 'Open'
                          : 'Closed',
                      style: TextStyle(
                        color: business.openNow
                            ? Colors.green
                            : Colors.red,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SEARCH
// ============================================================

class SearchPage extends StatefulWidget {
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const SearchPage({
    super.key,
    this.isFavorite =
        _defaultFavorite,
    this.onFavorite =
        _defaultFavoriteAction,
  });

  static bool _defaultFavorite(
    Business business,
  ) =>
      false;

  static void _defaultFavoriteAction(
    Business business,
  ) {}

  @override
  State<SearchPage> createState() =>
      _SearchPageState();
}

class _SearchPageState
    extends State<SearchPage> {
  final controller =
      TextEditingController();

  List<Business> results = [];

  bool loading = false;
  String error = '';

  Future<void> search() async {
    final query =
        controller.text.trim();

    if (query.isEmpty) {
      setState(() {
        results = [];
        error = '';
      });
      return;
    }

    setState(() {
      loading = true;
      error = '';
      results = [];
    });

    try {
      final data =
          await PlacesService.search(
        query,
      );

      if (!mounted) return;

      setState(() {
        results = data;
        loading = false;

        if (data.isEmpty) {
          error =
              'No businesses found.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e
            .toString()
            .replaceFirst(
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
            padding:
                const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              textInputAction:
                  TextInputAction.search,
              onSubmitted: (_) =>
                  search(),
              decoration:
                  InputDecoration(
                hintText:
                    'Business, service or city...',
                prefixIcon:
                    const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    IconButton(
                  icon: const Icon(
                    Icons.search,
                  ),
                  onPressed: search,
                ),
              ),
            ),
          ),
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
                              const EdgeInsets
                                  .all(24),
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons
                                    .error_outline,
                                size: 55,
                                color:
                                    Colors.red,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                error,
                                textAlign:
                                    TextAlign
                                        .center,
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              FilledButton(
                                onPressed:
                                    search,
                                child:
                                    const Text(
                                  'Try Again',
                                ),
                              ),
                            ],
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
                                const EdgeInsets
                                    .fromLTRB(
                              16,
                              0,
                              16,
                              30,
                            ),
                            itemCount:
                                results.length,
                            itemBuilder:
                                (_, index) {
                              final business =
                                  results[index];

                              return BusinessCard(
                                business:
                                    business,
                                favorite: widget
                                    .isFavorite(
                                  business,
                                ),
                                onFavorite: () {
                                  widget
                                      .onFavorite(
                                    business,
                                  );
                                  setState(
                                    () {},
                                  );
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

// ============================================================
// CATEGORY SEARCH
// ============================================================

class CategorySearchPage
    extends StatefulWidget {
  final String title;

  const CategorySearchPage({
    super.key,
    required this.title,
  });

  @override
  State<CategorySearchPage>
      createState() =>
          _CategorySearchPageState();
}

class _CategorySearchPageState
    extends State<CategorySearchPage> {
  late Future<List<Business>> future;

  @override
  void initState() {
    super.initState();

    future = PlacesService.search(
      widget.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Business>>(
        future: future,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Text(
                  snapshot.error
                      .toString()
                      .replaceFirst(
                        'Exception: ',
                        '',
                      ),
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          final data =
              snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text(
                'No businesses found.',
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (_, index) {
              return BusinessCard(
                business: data[index],
                favorite: false,
                onFavorite: () {},
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// NEARBY
// ============================================================

class NearbyPage extends StatelessWidget {
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const NearbyPage({
    super.key,
    this.isFavorite =
        _defaultFavorite,
    this.onFavorite =
        _defaultFavoriteAction,
  });

  static bool _defaultFavorite(
    Business business,
  ) =>
      false;

  static void _defaultFavoriteAction(
    Business business,
  ) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nearby Businesses',
        ),
      ),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                size: 70,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Discover businesses near you',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Use search with your city or area to find local businesses.',
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SearchPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.search,
                ),
                label: const Text(
                  'Search Nearby',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FAVORITES
// ============================================================

class FavoritesPage
    extends StatelessWidget {
  final List<Business> favorites;
  final void Function(Business) onFavorite;

  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
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
                textAlign:
                    TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding:
          const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (_, index) {
        final business =
            favorites[index];

        return BusinessCard(
          business: business,
          favorite: true,
          onFavorite: () {
            onFavorite(business);
          },
        );
      },
    );
  }
}

// ============================================================
// BUSINESS DETAILS
// ============================================================

class BusinessDetailsPage
    extends StatelessWidget {
  final Business business;

  const BusinessDetailsPage({
    super.key,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Business Details',
        ),
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
                  BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor:
                      Colors.white,
                  child: Text(
                    business.name
                            .isNotEmpty
                        ? business.name[0]
                            .toUpperCase()
                        : 'B',
                    style:
                        const TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                Text(
                  business.name,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  business.category,
                  style:
                      const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (business.rating > 0)
            infoCard(
              Icons.star,
              'Rating',
              '${business.rating.toStringAsFixed(1)} (${business.reviewCount} reviews)',
            ),
          infoCard(
            Icons.location_on,
            'Address',
            business.address,
          ),
          if (business.phone.isNotEmpty)
            infoCard(
              Icons.phone,
              'Phone',
              business.phone,
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (business.phone.isNotEmpty)
                FilledButton.icon(
                  onPressed: () =>
                      makePhoneCall(
                    business.phone,
                  ),
                  icon: const Icon(
                    Icons.call,
                  ),
                  label: const Text(
                    'Call',
                  ),
                ),
              if (business.phone.isNotEmpty)
                FilledButton.icon(
                  onPressed: () =>
                      openWhatsApp(
                    business.phone,
                  ),
                  icon: const Icon(
                    Icons.chat,
                  ),
                  label: const Text(
                    'WhatsApp',
                  ),
                ),
              FilledButton.icon(
                onPressed: () {
                  if (business.mapsUrl
                      .isNotEmpty) {
                    openExternal(
                      business.mapsUrl,
                    );
                  } else {
                    openMapsForAddress(
                      business.address,
                    );
                  }
                },
                icon: const Icon(
                  Icons.map,
                ),
                label: const Text(
                  'Maps',
                ),
              ),
              if (business.website.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () =>
                      openExternal(
                    business.website,
                  ),
                  icon: const Icon(
                    Icons.language,
                  ),
                  label: const Text(
                    'Website',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            'Reviews',
            style: TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const AppReviewTile(
            review: AppReview(
              name: 'Local User',
              rating: 5,
              comment:
                  'Great business and good service.',
              date: 'Recently',
            ),
          ),
          const AppReviewTile(
            review: AppReview(
              name: 'Customer',
              rating: 4,
              comment:
                  'Good experience.',
              date: 'Recently',
            ),
          ),
        ],
      ),
    );
  }

  Widget infoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        subtitle: Text(value),
      ),
    );
  }
}

class AppReviewTile
    extends StatelessWidget {
  final AppReview review;

  const AppReviewTile({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            review.name[0],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                review.name,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            const Icon(
              Icons.star,
              size: 17,
              color: Colors.amber,
            ),
            Text(
              review.rating
                  .toStringAsFixed(1),
            ),
          ],
        ),
        subtitle: Text(
          '${review.comment}\n${review.date}',
        ),
      ),
    );
  }
}

// ============================================================
// ACCOUNT
// ============================================================

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() =>
      _AccountPageState();
}

class _AccountPageState
    extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    if (!AppData.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Account',
          ),
        ),
        body: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 42,
                  child: Icon(
                    Icons.person,
                    size: 45,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Login to your account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginPage(),
                      ),
                    );

                    setState(() {});
                  },
                  child: const Text(
                    'Login',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SignupPage(),
                      ),
                    );

                    setState(() {});
                  },
                  child: const Text(
                    'Create Account',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user =
        AppData.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Account',
        ),
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
                  BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor:
                      Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 38,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ??
