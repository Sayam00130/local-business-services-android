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
        ),
      ),
      home: const SplashPage(),
    );
  }
}

// ============================================================
// MODELS
// ============================================================

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

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    });
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
                radius: 48,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.business,
                  size: 55,
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
// APP SHELL
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
    return favorites.any((item) => item.id == business.id);
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
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: pages[currentIndex],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
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
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        GestureDetector(
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
                Icon(Icons.arrow_forward_ios, size: 15),
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
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: .85,
          children: [
            categoryItem(context, Icons.restaurant, 'Restaurants'),
            categoryItem(context, Icons.local_hospital, 'Healthcare'),
            categoryItem(context, Icons.electrical_services, 'Electricians'),
            categoryItem(context, Icons.plumbing, 'Plumbers'),
            categoryItem(context, Icons.car_repair, 'Mechanics'),
            categoryItem(context, Icons.store, 'Shops'),
            categoryItem(context, Icons.school, 'Schools'),
            categoryItem(context, Icons.hotel, 'Hotels'),
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
          mainAxisAlignment: MainAxisAlignment.center,
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
        contentPadding: const EdgeInsets.all(8),
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
        final data = jsonDecode(response.body);

        if (data is Map &&
            data['error'] is Map &&
            data['error']['message'] != null) {
          message = data['error']['message'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }

    final data = jsonDecode(response.body);
    final places = data['places'];

    if (places is! List) {
      return [];
    }

    return places.map<Business>((place) {
      final displayName = place['displayName'];

      final name = displayName is Map
          ? (displayName['text'] ?? 'Unknown Business').toString()
          : 'Unknown Business';

      final category =
          (place['primaryType'] ?? 'Business')
              .toString()
              .replaceAll('_', ' ');

      final address =
          place['formattedAddress']?.toString() ??
              'Address unavailable';

      final international =
          place['internationalPhoneNumber']?.toString();

      final national =
          place['nationalPhoneNumber']?.toString();

      final phone =
          international != null && international.isNotEmpty
              ? international
              : (national ?? '');

      final mapsUrl =
          place['googleMapsUri']?.toString() ?? '';

      final website =
          place['websiteUri']?.toString() ?? '';

      final ratingValue = place['rating'];

      final rating = ratingValue is num
          ? ratingValue.toDouble()
          : 0.0;

      final reviewValue = place['userRatingCount'];

      final reviewCount = reviewValue is num
          ? reviewValue.toInt()
          : 0;

      bool openNow = false;

      final opening = place['currentOpeningHours'];

      if (opening is Map &&
          opening['openNow'] is bool) {
        openNow = opening['openNow'];
      }

      return Business(
        id: place['id']?.toString() ?? name,
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
// SEARCH PAGE
// ============================================================

class SearchPage extends StatefulWidget {
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const SearchPage({
    super.key,
    this.isFavorite = _defaultFavorite,
    this.onFavorite = _defaultFavoriteAction,
  });

  static bool _defaultFavorite(Business business) => false;

  static void _defaultFavoriteAction(Business business) {}

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();

  List<Business> results = [];
  bool loading = false;
  String error = '';

  Future<void> search() async {
    final query = controller.text.trim();

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
      final data = await PlacesService.search(query);

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
        title: const Text('Search Businesses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => search(),
              decoration: InputDecoration(
                hintText: 'Business, service or city...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: search,
                ),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : error.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            error,
                            textAlign: TextAlign.center,
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
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              100,
                            ),
                            itemCount: results.length,
                            itemBuilder: (_, index) {
                              final business = results[index];

                              return BusinessCard(
                                business: business,
                                favorite: widget.isFavorite(business),
                                onFavorite: () {
                                  widget.onFavorite(business);
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

// ============================================================
// CATEGORY SEARCH
// ============================================================

class CategorySearchPage extends StatefulWidget {
  final String title;

  const CategorySearchPage({
    super.key,
    required this.title,
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
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : businesses.isEmpty
                  ? const Center(
                      child: Text('No businesses found.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: businesses.length,
                      itemBuilder: (_, index) {
                        return BusinessCard(
                          business: businesses[index],
                        );
                      },
                    ),
    );
  }
}

// ============================================================
// NEARBY
// ============================================================

class NearbyPage extends StatefulWidget {
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const NearbyPage({
    super.key,
    this.isFavorite = SearchPage._defaultFavorite,
    this.onFavorite = SearchPage._defaultFavoriteAction,
  });

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  final controller = TextEditingController();

  bool loading = false;
  String error = '';
  List<Business> businesses = [];

  Future<void> searchNearby() async {
    final location = controller.text.trim();

    if (location.isEmpty) {
      setState(() {
        error = 'Enter a city, area or location.';
      });
      return;
    }

    setState(() {
      loading = true;
      error = '';
      businesses = [];
    });

    try {
      final data = await PlacesService.search(
        'businesses in $location',
      );

      if (!mounted) return;

      setState(() {
        businesses = data;
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
        title: const Text('Nearby Businesses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => searchNearby(),
              decoration: InputDecoration(
                hintText: 'Enter city or area',
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: searchNearby,
                ),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : error.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            error,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : businesses.isEmpty
                        ? const Center(
                            child: Text(
                              'Enter a city or area to find businesses.',
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              100,
                            ),
                            itemCount: businesses.length,
                            itemBuilder: (_, index) {
                              final business =
                                  businesses[index];

                              return BusinessCard(
                                business: business,
                                favorite:
                                    widget.isFavorite(business),
                                onFavorite: () {
                                  widget.onFavorite(business);
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

// ============================================================
// BUSINESS CARD
// ============================================================

class BusinessCard extends StatelessWidget {
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
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BusinessDetailsPage(
                business: business,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    child: Text(
                      business.name.isNotEmpty
                          ? business.name[0].toUpperCase()
                          : 'B',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      business.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onFavorite,
                    icon: Icon(
                      favorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: favorite ? Colors.red : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                business.category,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
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
                        ? business.rating.toStringAsFixed(1)
                        : 'No rating',
                  ),
                  if (business.reviewCount > 0)
                    Text(
                      ' (${business.reviewCount})',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  const Spacer(),
                  if (business.openNow)
                    const Text(
                      'Open',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      business.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BUSINESS DETAILS
// ============================================================

class BusinessDetailsPage extends StatelessWidget {
  final Business business;

  const BusinessDetailsPage({
    super.key,
    required this.business,
  });

  Future<void> openUrl(
    BuildContext context,
    String url,
  ) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This information is not available.'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null) return;

    try {
      await launchUrl(uri);
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the link.'),
        ),
      );
    }
  }

  Future<void> callBusiness(
    BuildContext context,
  ) async {
    if (business.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number is not available.'),
        ),
      );
      return;
    }

    final cleaned =
        business.phone.replaceAll(RegExp(r'[^\d+]'), '');

    await openUrl(
      context,
      'tel:$cleaned',
    );
  }

  Future<void> whatsapp(
    BuildContext context,
  ) async {
    if (business.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp number is not available.'),
        ),
      );
      return;
    }

    final number =
        business.phone.replaceAll(RegExp(r'[^\d]'), '');

    await openUrl(
      context,
      'https://wa.me/$number',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Sharing will be connected in the next release.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          30,
        ),
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.indigo,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                child: Text(
                  business.name.isNotEmpty
                      ? business.name[0].toUpperCase()
                      : 'B',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            business.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            business.category,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              const SizedBox(width: 5),
              Text(
                business.rating > 0
                    ? business.rating.toStringAsFixed(1)
                    : 'No rating',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (business.reviewCount > 0)
                Text(
                  '${business.reviewCount} reviews',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              const Spacer(),
              if (business.openNow)
                const Text(
                  'OPEN NOW',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => callBusiness(context),
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => whatsapp(context),
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () => openUrl(
              context,
              business.mapsUrl,
            ),
            icon: const Icon(Icons.map),
            label: const Text('Open in Google Maps'),
          ),

          if (business.website.isNotEmpty) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => openUrl(
                context,
                business.website,
              ),
              icon: const Icon(Icons.language),
              label: const Text('Open Website'),
            ),
          ],

          const SizedBox(height: 22),

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

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.star),
              ),
              title: const Text(
                'Ratings & Reviews',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                business.reviewCount > 0
                    ? '${business.reviewCount} reviews available'
                    : 'Be the first to review',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewsPage(
                      business: business,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.rate_review),
              ),
              title: const Text(
                'Write a Review',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Share your experience',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WriteReviewPage(
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

  Widget infoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(value),
        ),
      ),
    );
  }
}

// ============================================================
// REVIEWS
// ============================================================

class ReviewsPage extends StatefulWidget {
  final Business business;

  const ReviewsPage({
    super.key,
    required this.business,
  });

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final List<AppReview> reviews = [
    AppReview(
      name: 'Verified User',
      rating: 5,
      comment: 'Great experience and professional service.',
      date: 'Recently',
    ),
    AppReview(
      name: 'Local Customer',
      rating: 4,
      comment: 'Good service and friendly staff.',
      date: 'Recently',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final rating = widget.business.rating;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings & Reviews'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WriteReviewPage(
                business: widget.business,
              ),
            ),
          );
        },
        icon: const Icon(Icons.rate_review),
        label: const Text('Write Review'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Text(
                    rating > 0
                        ? rating.toStringAsFixed(1)
                        : '0.0',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < rating.round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 27,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.business.reviewCount} total reviews',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Customer Reviews',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...reviews.map(
            (review) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            review.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          review.date,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < review.rating
                              ? Icons.star
                              : Icons.star_border,
                          size: 19,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(review.comment),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WRITE REVIEW
// ============================================================

class WriteReviewPage extends StatefulWidget {
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
  final reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  void submit() {
    if (reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write your review.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Review Submitted'),
        content: const Text(
          'Your review has been prepared successfully. '
          'Permanent review storage will be connected with the backend/database later.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.business.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          const Center(
            child: Text(
              'Your Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () {
                  setState(() {
                    rating = index + 1.0;
                  });
                },
                icon: Icon(
                  index < rating
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 42,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: reviewController,
            maxLines: 7,
            decoration: const InputDecoration(
              hintText: 'Write your experience...',
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: submit,
            icon: const Icon(Icons.send),
            label: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FAVORITES
// ============================================================

class FavoritesPage extends StatelessWidget {
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
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Save businesses here for quick access.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ),
      itemCount: favorites.length,
      itemBuilder: (_, index) {
        return BusinessCard(
          business: favorites[index],
          favorite: true,
          onFavorite: () {
            onFavorite(favorites[index]);
          },
        );
      },
    );
  }
}

// ============================================================
// LOGIN
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login'),
        content: const Text(
          'Login screen is ready. Real account authentication will be connected to the backend/database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Login to your account',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: passwordController,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obscure = !obscure;
                  });
                },
                icon: Icon(
                  obscure
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: login,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text('Login'),
            ),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SignupPage(),
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

// ============================================================
// SIGNUP
// ============================================================

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void signup() {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields.'),
        ),
      );
      return;
    }

    if (passwordController.text !=
        confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Account Ready'),
        content: const Text(
          'Signup screen is ready. Permanent account creation will be connected to the backend/database.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 10),
          const Text(
            'Join Local Business & Services',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your account to save businesses and manage your profile.',
          ),
          const SizedBox(height: 25),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: confirmController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: signup,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text('Create Account'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADD BUSINESS
// ============================================================

class AddBusinessPage extends StatefulWidget {
  const AddBusinessPage({super.key});

  @override
  State<AddBusinessPage> createState() =>
      _AddBusinessPageState();
}

class _AddBusinessPageState
    extends State<AddBusinessPage> {
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final websiteController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    addressController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void submit() {
    if (nameController.text.trim().isEmpty ||
        categoryController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Business name, category and address are required.',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Business Submitted'),
        content: const Text(
          'Your business information is ready. Permanent business submission and approval will be connected to the backend/database.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Your Business'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          40,
        ),
        children: [
          const Text(
            'Add Your Business',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a professional listing for customers around the world.',
          ),
          const SizedBox(height: 25),
          field(
            nameController,
            'Business Name',
            Icons.business,
          ),
          field(
            categoryController,
            'Category',
            Icons.category_outlined,
          ),
          field(
            addressController,
            'Address',
            Icons.location_on_outlined,
          ),
          field(
            phoneController,
            'Phone Number',
            Icons.phone_outlined,
            keyboard: TextInputType.phone,
          ),
          field(
            websiteController,
            'Website',
            Icons.language,
            keyboard: TextInputType.url,
          ),
          field(
            descriptionController,
            'Business Description',
            Icons.description_outlined,
            maxLines: 5,
          ),
          const SizedBox(height: 15),
          FilledButton.icon(
            onPressed: submit,
            icon: const Icon(Icons.send),
            label: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Submit Business'),
            ),
          ),
        ],
      ),
    );
  }

  Widget field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }
}

// ============================================================
// MY BUSINESS
// ============================================================

class MyBusinessPage extends StatelessWidget {
  const MyBusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Business'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.business_center_outlined,
                size: 75,
                color: Colors.blue,
              ),
              const SizedBox(height: 18),
              const Text(
                'Manage Your Business',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your business listings will appear here after backend/database integration.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddBusinessPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_business),
                label: const Text('Add Business'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(
              Icons.person,
              size: 55,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Guest User',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Login to manage your profile',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 15),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('My Business'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 15),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyBusinessPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 15),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EDIT PROFILE
// ============================================================

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {
  final nameController =
      TextEditingController(text: 'Guest User');
  final emailController =
      TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 45,
            child: Icon(
              Icons.person,
              size: 50,
            ),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Profile changes will be saved through the backend later.',
                  ),
                ),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NOTIFICATIONS
// ============================================================

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.notifications),
              ),
              title: Text('Welcome'),
              subtitle: Text(
                'Welcome to Local Business & Services.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.star),
              ),
              title: Text('Reviews'),
              subtitle: Text(
                'Business reviews and notifications will appear here.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SETTINGS
// ============================================================

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Manage notifications'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy'),
            subtitle: const Text('Privacy settings'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HelpPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HELP
// ============================================================

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'How can we help?',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Card(
            child: ListTile(
              leading: Icon(Icons.search),
              title: Text('Finding a business'),
              subtitle: Text(
                'Use Search or Nearby to discover businesses and services.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.star),
              title: Text('Ratings and reviews'),
              subtitle: Text(
                'Open a business and use Ratings & Reviews to view or submit feedback.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.business),
              title: Text('List your business'),
              subtitle: Text(
                'Use List Your Business to create a business listing.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ABOUT
// ============================================================

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircleAvatar(
                radius: 45,
                child: Icon(
                  Icons.business,
                  size: 50,
                ),
              ),
              SizedBox(height: 18),
              Text(
                'Local Business & Services',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'A global platform for discovering local businesses and professional services.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 18),
              Text(
                'Version 1.0',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
