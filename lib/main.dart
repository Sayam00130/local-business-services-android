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
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.indigo],
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
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 35),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final List<Business> favorites = [];

  bool isFavorite(Business b) {
    return favorites.any((x) => x.id == b.id);
  }

  void toggleFavorite(Business b) {
    setState(() {
      if (isFavorite(b)) {
        favorites.removeWhere((x) => x.id == b.id);
      } else {
        favorites.add(b);
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
          style: TextStyle(fontWeight: FontWeight.bold),
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
      body: pages[index],
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
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() => index = i);
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.indigo],
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
                    style: TextStyle(color: Colors.grey),
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
          childAspectRatio: .82,
          children: categories.map((c) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategorySearchPage(
                      title: c[1] as String,
                    ),
                  ),
                );
              },
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      c[0] as IconData,
                      color: Colors.blue,
                      size: 29,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      c[1] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class PlacesService {
  static const apiKey =
      String.fromEnvironment('GOOGLE_PLACES_API_KEY');

  static Future<List<Business>> search(String query) async {
    if (apiKey.isEmpty) {
      throw Exception('Google Places API key is missing.');
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

    if (places is! List) return [];

    return places.map<Business>((p) {
      final display = p['displayName'];
      final name = display is Map
          ? (display['text'] ?? 'Unknown Business').toString()
          : 'Unknown Business';

      final rating = p['rating'] is num
          ? (p['rating'] as num).toDouble()
          : 0.0;

      final reviews = p['userRatingCount'] is num
          ? (p['userRatingCount'] as num).toInt()
          : 0;

      final opening = p['currentOpeningHours'];

      return Business(
        id: p['id']?.toString() ?? name,
        name: name,
        category: (p['primaryType'] ?? 'Business')
            .toString()
            .replaceAll('_', ' '),
        address:
            p['formattedAddress']?.toString() ??
                'Address unavailable',
        phone:
            p['internationalPhoneNumber']?.toString() ??
                p['nationalPhoneNumber']?.toString() ??
                '',
        mapsUrl:
            p['googleMapsUri']?.toString() ?? '',
        website:
            p['websiteUri']?.toString() ?? '',
        rating: rating,
        reviewCount: reviews,
        openNow: opening is Map &&
            opening['openNow'] == true,
      );
    }).toList();
  }
}

class SearchPage extends StatefulWidget {
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const SearchPage({
    super.key,
    this.isFavorite = _falseFavorite,
    this.onFavorite = _emptyFavorite,
  });

  static bool _falseFavorite(Business b) => false;
  static void _emptyFavorite(Business b) {}

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();
  List<Business> results = [];
  bool loading = false;
  String error = '';

  Future<void> search() async {
    final q = controller.text.trim();

    if (q.isEmpty) return;

    setState(() {
      loading = true;
      error = '';
      results = [];
    });

    try {
      final data = await PlacesService.search(q);

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
                  onPressed: search,
                  icon: const Icon(Icons.search),
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
                    ? Center(child: Text(error))
                    : results.isEmpty
                        ? const Center(
                            child: Text(
                              'Search for a business or service.',
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: results.length,
                            itemBuilder: (_, i) {
                              final b = results[i];

                              return BusinessCard(
                                business: b,
                                favorite:
                                    widget.isFavorite(b),
                                onFavorite: () {
                                  widget.onFavorite(b);
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
      appBar: AppBar(title: Text(widget.title)),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error.isNotEmpty
              ? Center(child: Text(error))
              : businesses.isEmpty
                  ? const Center(
                      child: Text('No businesses found.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: businesses.length,
                      itemBuilder: (_, i) {
                        return BusinessCard(
                          business: businesses[i],
                        );
                      },
                    ),
    );
  }
}

class NearbyPage extends StatefulWidget {
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const NearbyPage({
    super.key,
    this.isFavorite = SearchPage._falseFavorite,
    this.onFavorite = SearchPage._emptyFavorite,
  });

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  final controller = TextEditingController();
  List<Business> businesses = [];
  bool loading = false;
  String error = '';

  Future<void> search() async {
    final location = controller.text.trim();

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
      final data = await PlacesService.search(
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
        title: const Text('Nearby Businesses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              onSubmitted: (_) => search(),
              decoration: InputDecoration(
                hintText: 'Enter city or area',
                prefixIcon:
                    const Icon(Icons.location_on),
                suffixIcon: IconButton(
                  onPressed: search,
                  icon: const Icon(Icons.search),
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
                    ? Center(child: Text(error))
                    : businesses.isEmpty
                        ? const Center(
                            child: Text(
                              'Enter a city or area to find businesses.',
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: businesses.length,
                            itemBuilder: (_, i) {
                              final b = businesses[i];

                              return BusinessCard(
                                business: b,
                                favorite:
                                    widget.isFavorite(b),
                                onFavorite: () {
                                  widget.onFavorite(b);
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  BusinessDetailsPage(business: business),
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
                      color:
                          favorite ? Colors.red : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                business.category,
                style: const TextStyle(
                  color: Colors.blue,
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
                        ? business.rating
                            .toStringAsFixed(1)
                        : 'No rating',
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
              Text(
                business.address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BusinessDetailsPage extends StatelessWidget {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Information is not available.'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(value);

    if (uri == null) return;

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the link.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.indigo],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                child: Text(
                  business.name.isEmpty
                      ? 'B'
                      : business.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
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
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          Text(business.address),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    final phone = business.phone
                        .replaceAll(RegExp(r'[^\d+]'), '');

                    if (phone.isNotEmpty) {
                      openLink(context, 'tel:$phone');
                    }
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    final phone = business.phone
                        .replaceAll(RegExp(r'[^\d]'), '');

                    if (phone.isNotEmpty) {
                      openLink(
                        context,
                        'https://wa.me/$phone',
                      );
                    }
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (business.mapsUrl.isNotEmpty)
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.map),
                ),
                title: const Text('Open in Google Maps'),
                onTap: () =>
                    openLink(context, business.mapsUrl),
              ),
            ),
          if (business.website.isNotEmpty)
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.language),
                ),
                title: const Text('Visit Website'),
                onTap: () =>
                    openLink(context, business.website),
              ),
            ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.star),
              ),
              title: const Text('Ratings & Reviews'),
              subtitle: Text(
                business.reviewCount > 0
                    ? '${business.reviewCount} reviews'
                    : 'View and write reviews',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ReviewsPage(business: business),
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
        title: const Text('Ratings & Reviews'),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          if (FirebaseAuth.instance.currentUser ==
              null) {
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
              builder: (_) =>
                  WriteReviewPage(business: business),
            ),
          );
        },
        icon: const Icon(Icons.rate_review),
        label: const Text('Write Review'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('businesses')
            .doc(business.id)
            .collection('reviews')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load reviews.'),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView(
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
                        business.rating > 0
                            ? business.rating
                                .toStringAsFixed(1)
                            : '0.0',
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${business.reviewCount} total reviews',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ...docs.map((doc) {
                final data =
                    doc.data() as Map<String, dynamic>;

                return Card(
                  margin:
                      const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      data['name']?.toString() ??
                          'Customer',
                    ),
                    subtitle: Text(
                      data['comment']?.toString() ?? '',
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
  final controller = TextEditingController();
  bool saving = false;

  Future<void> submit() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
      return;
    }

    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write your review.'),
        ),
      );
      return;
    }

    setState(() => saving = true);

    try {
      await FirebaseFirestore.instance
          .collection('businesses')
          .doc(widget.business.id)
          .collection('reviews')
          .add({
        'userId': user.uid,
        'name': user.displayName ??
            user.email?.split('@').first ??
            'Customer',
        'email': user.email ?? '',
        'rating': rating,
        'comment': controller.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review failed: $e'),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => IconButton(
                onPressed: () {
                  setState(() => rating = i + 1.0);
                },
                icon: Icon(
                  i < rating
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: controller,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Write your experience...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: saving ? null : submit,
            icon: const Icon(Icons.send),
            label: Text(
              saving ? 'Submitting...' : 'Submit Review',
            ),
          ),
        ],
      ),
    );
  }
}

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
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (_, i) {
        return BusinessCard(
          business: favorites[i],
          favorite: true,
          onFavorite: () {
            onFavorite(favorites[i]);
          },
        );
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;
  bool loading = false;

  Future<void> login() async {
    if (email.text.trim().isEmpty ||
        password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter email and password.'),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Login failed.',
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
      appBar: AppBar(title: const Text('Login')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 45,
            child: Icon(Icons.person, size: 50),
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
          const SizedBox(height: 25),
          TextField(
            controller: email,
            keyboardType:
                TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon:
                  Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: password,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon:
                  const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => obscure = !obscure);
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
            onPressed: loading ? null : login,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                loading ? 'Logging in...' : 'Login',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SignupPage(),
                ),
              );
            },
            child: const Text('Create a new account'),
          ),
        ],
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool loading = false;

  Future<void> signup() async {
    if (name.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        password.text.isEmpty ||
        confirm.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete all fields.'),
        ),
      );
      return;
    }

    if (password.text != confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
        ),
      );
      return;
    }

    if (password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password must be at least 6 characters.',
          ),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      await credential.user?.updateDisplayName(
        name.text.trim(),
      );

      final user = credential.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'name': name.text.trim(),
          'email': email.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      Navigator.pop(context);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Signup failed.',
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
        title: const Text('Create Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Join Local Business & Services',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: email,
            keyboardType:
                TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon:
                  Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon:
                  Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: confirm,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon:
                  Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: loading ? null : signup,
            child: Padding(
              padding: const EdgeInsets.all(14),
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

class AddBusinessPage extends StatefulWidget {
  const AddBusinessPage({super.key});

  @override
  State<AddBusinessPage> createState() =>
      _AddBusinessPageState();
}

class _AddBusinessPageState
    extends State<AddBusinessPage> {
  final name = TextEditingController();
  final category = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();
  final website = TextEditingController();
  final description = TextEditingController();
  bool saving = false;

  Future<void> submit() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
      return;
    }

    if (name.text.trim().isEmpty ||
        category.text.trim().isEmpty ||
        address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Business name, category and address are required.',
          ),
        ),
      );
      return;
    }

    setState(() => saving = true);

    try {
      await FirebaseFirestore.instance
          .collection('businesses')
          .add({
        'ownerId': user.uid,
        'ownerEmail': user.email ?? '',
        'name': name.text.trim(),
        'category': category.text.trim(),
        'address': address.text.trim(),
        'phone': phone.text.trim(),
        'website': website.text.trim(),
        'description': description.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Business submitted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: $e'),
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
    TextEditingController c,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
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
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Add Your Business',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
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
            keyboard: TextInputType.phone,
          ),
          field(
            website,
            'Website',
            Icons.language,
            keyboard: TextInputType.url,
          ),
          field(
            description,
            'Business Description',
            Icons.description_outlined,
            maxLines: 5,
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: saving ? null : submit,
            icon: const Icon(Icons.send),
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

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Notifications')),
      body: const Center(
        child: Text(
          'No new notifications.',
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 55),
          ),
          const SizedBox(height: 15),
          Text(
            user?.displayName ??
                user?.email ??
                'Guest User',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (user?.email != null)
            Text(
              user!.email!,
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 25),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const EditProfilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('My Business'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const MyBusinessPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
          ),
          if (user != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();

                if (!context.mounted) return;

                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {
  late final TextEditingController name;
  late final TextEditingController email;

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

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': name.text.trim(),
        'email': user.email ?? email.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
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
      appBar:
          AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: email,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: save,
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

class MyBusinessPage extends StatelessWidget {
  const MyBusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar:
            AppBar(title: const Text('My Business')),
        body: const Center(
          child: Text('Please login first.'),
        ),
      );
    }

    return Scaffold(
      appBar:
          AppBar(title: const Text('My Business')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('businesses')
            .where(
              'ownerId',
              isEqualTo: user.uid,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AddBusinessPage(),
                    ),
                  );
                },
                icon:
                    const Icon(Icons.add_business),
                label:
                    const Text('Add Business'),
              ),
              const SizedBox(height: 15),
              if (docs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'You have no business listings yet.',
                    ),
                  ),
                ),
              ...docs.map((doc) {
                final d =
                    doc.data()
                        as Map<String, dynamic>;

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.business),
                    ),
                    title: Text(
                      d['name']?.toString() ??
                          'Business',
                    ),
                    subtitle: Text(
                      '${d['category'] ?? ''}\nStatus: ${d['status'] ?? 'pending'}',
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

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
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
            leading:
                const Icon(Icons.info_outline),
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

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Help & Support')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help?',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Use Search and Nearby to discover businesses and services. Login to create an account, submit businesses and write reviews.',
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
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
                'A platform for discovering local businesses and professional services.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 18),
              Text('Version 1.0'),
            ],
          ),
        ),
      ),
    );
  }
}
