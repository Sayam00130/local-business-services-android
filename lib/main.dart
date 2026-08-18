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
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================
// BUSINESS MODEL
// ============================================================

class Business {
  final String id;
  final String name;
  final String category;
  final String address;
  final String phone;
  final String mapsUrl;
  final double rating;
  final int reviewCount;
  final bool openNow;

  const Business({
    this.id = '',
    required this.name,
    required this.category,
    required this.address,
    required this.phone,
    required this.mapsUrl,
    required this.rating,
    required this.reviewCount,
    required this.openNow,
  });
}

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Business> favorites = [];

  void toggleFavorite(Business business) {
    setState(() {
      final exists = favorites.any((item) => item.id == business.id);

      if (exists) {
        favorites.removeWhere((item) => item.id == business.id);
      } else {
        favorites.add(business);
      }
    });
  }

  bool isFavorite(Business business) {
    return favorites.any((item) => item.id == business.id);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(
        favorites: favorites,
        isFavorite: isFavorite,
        onFavorite: toggleFavorite,
      ),
      SearchPage(
        favorites: favorites,
        isFavorite: isFavorite,
        onFavorite: toggleFavorite,
      ),
      NearbyPage(
        favorites: favorites,
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
            tooltip: 'Notifications',
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
            tooltip: 'Account',
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
        label: const Text('Add Business'),
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
  final List<Business> favorites;
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const HomeTab({
    super.key,
    required this.favorites,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.blue,
                Colors.indigo,
              ],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Local Businesses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Search real businesses and services near any location.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SearchPage(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                    'Search businesses, services or locations...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              category(
                context,
                Icons.restaurant,
                'Restaurants',
              ),
              category(
                context,
                Icons.local_hospital,
                'Doctors',
              ),
              category(
                context,
                Icons.electrical_services,
                'Electrician',
              ),
              category(
                context,
                Icons.plumbing,
                'Plumber',
              ),
              category(
                context,
                Icons.car_repair,
                'Mechanic',
              ),
              category(
                context,
                Icons.store,
                'Shops',
              ),
              category(
                context,
                Icons.school,
                'Schools',
              ),
              category(
                context,
                Icons.hotel,
                'Hotels',
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          'How it works',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        const InfoCard(
          icon: Icons.search,
          title: 'Search',
          text: 'Search real businesses using Google Places.',
        ),

        const InfoCard(
          icon: Icons.phone,
          title: 'Contact',
          text: 'Call or contact a business through WhatsApp.',
        ),

        const InfoCard(
          icon: Icons.map,
          title: 'Find on Maps',
          text: 'Open the business location directly in Google Maps.',
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget category(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    return GestureDetector(
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
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
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
              size: 32,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SEARCH PAGE
// ============================================================

class SearchPage extends StatefulWidget {
  final List<Business> favorites;
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const SearchPage({
    super.key,
    this.favorites = const [],
    this.isFavorite = _falseFavorite,
    this.onFavorite = _emptyFavorite,
  });

  static bool _falseFavorite(Business business) => false;

  static void _emptyFavorite(Business business) {}

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController controller =
      TextEditingController();

  List<Business> results = [];

  bool loading = false;
  bool loadingMore = false;

  String error = '';

  String? nextPageToken;

  // API key is supplied through:
  // --dart-define=GOOGLE_PLACES_API_KEY=YOUR_KEY
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
  );

  Future<List<Business>> requestPlaces({
    String? pageToken,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception(
        'Google Places API key is missing.',
      );
    }

    final uri = Uri.parse(
      'https://places.googleapis.com/v1/places:searchText',
    );

    final body = <String, dynamic>{
      'textQuery': controller.text.trim(),
      'pageSize': 20,
    };

    if (pageToken != null && pageToken.isNotEmpty) {
      body['pageToken'] = pageToken;
    }

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'places.id,places.displayName,places.formattedAddress,places.primaryType,places.rating,places.userRatingCount,places.nationalPhoneNumber,places.googleMapsUri,places.currentOpeningHours,nextPageToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      String message = 'Places API error';

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map &&
            decoded['error'] is Map &&
            decoded['error']['message'] != null) {
          message =
              decoded['error']['message'].toString();
        }
      } catch (_) {}

      throw Exception(
        '$message (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);

    final places = decoded['places'];

    if (places is! List) {
      nextPageToken = null;
      return [];
    }

    nextPageToken =
        decoded['nextPageToken']?.toString();

    return places.map<Business>((place) {
      final displayName = place['displayName'];

      final name = displayName is Map
          ? (displayName['text'] ??
                  'Unknown Business')
              .toString()
          : 'Unknown Business';

      final address =
          place['formattedAddress']
                  ?.toString() ??
              'Address unavailable';

      final category =
          place['primaryType']
                  ?.toString()
                  .replaceAll('_', ' ') ??
              'Business';

      final phone =
          place['nationalPhoneNumber']
                  ?.toString() ??
              '';

      final ratingValue = place['rating'];

      final rating = ratingValue is num
          ? ratingValue.toDouble()
          : 0.0;

      final reviewValue =
          place['userRatingCount'];

      final reviewCount = reviewValue is num
          ? reviewValue.toInt()
          : 0;

      final mapsUrl =
          place['googleMapsUri']
                  ?.toString() ??
              '';

      bool openNow = false;

      final opening =
          place['currentOpeningHours'];

      if (opening is Map) {
        final value = opening['openNow'];

        if (value is bool) {
          openNow = value;
        }
      }

      return Business(
        id: place['id']?.toString() ?? name,
        name: name,
        category: category,
        address: address,
        phone: phone,
        mapsUrl: mapsUrl,
        rating: rating,
        reviewCount: reviewCount,
        openNow: openNow,
      );
    }).toList();
  }

  Future<void> search() async {
    final query = controller.text.trim();

    if (query.isEmpty) {
      setState(() {
        results = [];
        error = '';
        nextPageToken = null;
      });
      return;
    }

    setState(() {
      loading = true;
      error = '';
      results = [];
      nextPageToken = null;
    });

    try {
      final firstPage = await requestPlaces();

      if (!mounted) return;

      setState(() {
        results = firstPage;
        loading = false;

        if (firstPage.isEmpty) {
          error = 'No businesses found.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        results = [];
        error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  Future<void> loadMore() async {
    if (loadingMore ||
        nextPageToken == null ||
        nextPageToken!.isEmpty) {
      return;
    }

    setState(() {
      loadingMore = true;
    });

    try {
      final oldToken = nextPageToken;

      final moreResults = await requestPlaces(
        pageToken: oldToken,
      );

      if (!mounted) return;

      setState(() {
        final existingIds =
            results.map((e) => e.id).toSet();

        results.addAll(
          moreResults.where(
            (item) => !existingIds.contains(item.id),
          ),
        );

        loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loadingMore = false;
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
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => search(),
              decoration: InputDecoration(
                hintText:
                    'Business, service or location...',
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: search,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
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
                              const EdgeInsets.all(25),
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
                        : NotificationListener<
                            ScrollNotification>(
                            onNotification:
                                (notification) {
                              if (notification
                                  is ScrollEndNotification) {
                                final metrics =
                                    notification.metrics;

                                if (metrics.pixels >=
                                    metrics.maxScrollExtent -
                                        300) {
                                  loadMore();
                                }
                              }

                              return false;
                            },
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.all(
                                      16),
                              itemCount:
                                  results.length +
                                      (loadingMore
                                          ? 1
                                          : 0),
                              itemBuilder:
                                  (context, index) {
                                if (index >=
                                    results.length) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.all(
                                            20),
                                    child: Center(
                                      child:
                                          CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final business =
                                    results[index];

                                return BusinessCard(
                                  business:
                                      business,
                                  isFavorite:
                                      widget.isFavorite(
                                    business,
                                  ),
                                  onFavorite: () =>
                                      widget.onFavorite(
                                    business,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NEARBY PAGE
// ============================================================

class NearbyPage extends StatefulWidget {
  final List<Business> favorites;
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const NearbyPage({
    super.key,
    required this.favorites,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  final TextEditingController locationController =
      TextEditingController();

  List<Business> results = [];
  bool loading = false;

  static const String apiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
  );

  Future<void> searchNearby() async {
    final location =
        locationController.text.trim();

    if (location.isEmpty) {
      showMessage(
        context,
        'Enter a city or area first.',
      );
      return;
    }

    setState(() {
      loading = true;
      results = [];
    });

    try {
      final uri = Uri.parse(
        'https://places.googleapis.com/v1/places:searchText',
      );

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask':
              'places.id,places.displayName,places.formattedAddress,places.primaryType,places.rating,places.userRatingCount,places.nationalPhoneNumber,places.googleMapsUri,places.currentOpeningHours',
        },
        body: jsonEncode({
          'textQuery':
              'businesses and services in $location',
          'pageSize': 20,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Nearby search failed.');
      }

      final data = jsonDecode(response.body);

      final places =
          data['places'] as List? ?? [];

      final converted =
          places.map<Business>((place) {
        final displayName =
            place['displayName'];

        final name = displayName is Map
            ? (displayName['text'] ??
                    'Unknown Business')
                .toString()
            : 'Unknown Business';

        final address =
            place['formattedAddress']
                    ?.toString() ??
                'Address unavailable';

        final category =
            place['primaryType']
                    ?.toString()
                    .replaceAll('_', ' ') ??
                'Business';

        final phone =
            place['nationalPhoneNumber']
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

        return Business(
          id: place['id']?.toString() ??
              name,
          name: name,
          category: category,
          address: address,
          phone: phone,
          mapsUrl:
              place['googleMapsUri']
                      ?.toString() ??
                  '',
          rating: rating,
          reviewCount: reviewCount,
          openNow: false,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        results = converted;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        context,
        'Could not load nearby businesses.',
      );
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          locationController,
                      textInputAction:
                          TextInputAction.search,
                      onSubmitted: (_) =>
                          searchNearby(),
                      decoration: InputDecoration(
                        hintText:
                            'Enter city / area',
                        prefixIcon:
                            const Icon(
                          Icons.location_on,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: searchNearby,
                    icon:
                        const Icon(Icons.search),
                  ),
                ],
              ),
            ),

            Expanded(
              child: loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : results.isEmpty
                      ? const Center(
                          child: Text(
                            'Enter an area to find businesses.',
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.all(
                                  16),
                          itemCount:
                              results.length,
                          itemBuilder:
                              (context, index) {
                            final business =
                                results[index];

                            return BusinessCard(
                              business: business,
                              isFavorite:
                                  widget.isFavorite(
                                business,
                              ),
                              onFavorite: () =>
                                  widget.onFavorite(
                                business,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
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
  List<Business> results = [];
  bool loading = true;

  static const String apiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
  );

  @override
  void initState() {
    super.initState();
    searchCategory();
  }

  Future<void> searchCategory() async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://places.googleapis.com/v1/places:searchText',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask':
              'places.id,places.displayName,places.formattedAddress,places.primaryType,places.rating,places.userRatingCount,places.nationalPhoneNumber,places.googleMapsUri,places.currentOpeningHours',
        },
        body: jsonEncode({
          'textQuery':
              '${widget.title} near me',
          'pageSize': 20,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception();
      }

      final data = jsonDecode(response.body);

      final places =
          data['places'] as List? ?? [];

      final converted =
          places.map<Business>((place) {
        final displayName =
            place['displayName'];

        final name = displayName is Map
            ? (displayName['text'] ??
                    'Unknown Business')
                .toString()
            : 'Unknown Business';

        final ratingValue =
            place['rating'];

        return Business(
          id: place['id']?.toString() ??
              name,
          name: name,
          category:
              place['primaryType']
                      ?.toString()
                      .replaceAll('_', ' ') ??
                  widget.title,
          address:
              place['formattedAddress']
                      ?.toString() ??
                  'Address unavailable',
          phone:
              place['nationalPhoneNumber']
                      ?.toString() ??
                  '',
          mapsUrl:
              place['googleMapsUri']
                      ?.toString() ??
                  '',
          rating: ratingValue is num
              ? ratingValue.toDouble()
              : 0,
          reviewCount:
              place['userRatingCount']
                      is num
                  ? (place['userRatingCount']
                          as num)
                      .toInt()
                  : 0,
          openNow: false,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        results = converted;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
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
              child:
                  CircularProgressIndicator(),
            )
          : results.isEmpty
              ? const Center(
                  child: Text(
                    'No businesses found.',
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder:
                      (context, index) {
                    return BusinessCard(
                      business: results[index],
                    );
                  },
                ),
    );
  }
}

// ============================================================
// BUSINESS CARD
// ============================================================

class BusinessCard extends StatelessWidget {
  final Business business;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  const BusinessCard({
    super.key,
    required this.business,
    this.isFavorite = false,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      elevation: 1,
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
          padding:
              const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                child:
                    const Icon(Icons.business),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      business.category,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      business.address,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          business.rating > 0
                              ? business.rating
                                  .toStringAsFixed(
                                      1)
                              : 'No rating',
                        ),
                        if (business
                                .reviewCount >
                            0)
                          Text(
                            ' (${business.reviewCount})',
                            style:
                                const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite
                      ? Colors.red
                      : null,
                ),
                onPressed: onFavorite,
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

class BusinessDetailsPage
    extends StatelessWidget {
  final Business business;

  const BusinessDetailsPage({
    super.key,
    required this.business,
  });

  Future<void> callBusiness(
    BuildContext context,
  ) async {
    if (business.phone.isEmpty) {
      showMessage(
        context,
        'Phone number is not available.',
      );
      return;
    }

    final uri =
        Uri.parse('tel:${business.phone}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showMessage(
        context,
        'Could not open phone dialer.',
      );
    }
  }

  Future<void> openWhatsApp(
    BuildContext context,
  ) async {
    if (business.phone.isEmpty) {
      showMessage(
        context,
        'WhatsApp number is not available.',
      );
      return;
    }

    final phone = business.phone
        .replaceAll(RegExp(r'[^0-9]'), '');

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(
        'Hello ${business.name}',
      )}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode:
            LaunchMode.externalApplication,
      );
    } else {
      showMessage(
        context,
        'WhatsApp could not be opened.',
      );
    }
  }

  Future<void> openMaps(
    BuildContext context,
  ) async {
    Uri uri;

    if (business.mapsUrl.isNotEmpty) {
      uri = Uri.parse(business.mapsUrl);
    } else {
      final query = Uri.encodeComponent(
        '${business.name}, ${business.address}',
      );

      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$query',
      );
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode:
            LaunchMode.externalApplication,
      );
    } else {
      showMessage(
        context,
        'Google Maps could not be opened.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Business Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              showMessage(
                context,
                'Share option selected.',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 55,
            child: const Icon(
              Icons.business,
              size: 55,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            business.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            business.category,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Text(
              business.rating > 0
                  ? '⭐ ${business.rating.toStringAsFixed(1)}'
                  : 'No rating',
              style:
                  const TextStyle(fontSize: 17),
            ),
          ),

          if (business.reviewCount > 0)
            Center(
              child: Text(
                '${business.reviewCount} reviews',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              actionButton(
                context,
                Icons.call,
                'Call',
                () => callBusiness(context),
              ),
              actionButton(
                context,
                Icons.chat,
                'WhatsApp',
                () => openWhatsApp(context),
              ),
              actionButton(
                context,
                Icons.map,
                'Maps',
                () => openMaps(context),
              ),
              actionButton(
                context,
                Icons.report_outlined,
                'Report',
                () => showMessage(
                  context,
                  'Report option selected.',
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          infoTile(
            Icons.location_on,
            business.address,
          ),

          if (business.phone.isNotEmpty)
            infoTile(
              Icons.phone,
              business.phone,
            ),

          infoTile(
            Icons.business,
            business.category,
          ),

          const SizedBox(height: 25),

          const Text(
            'Reviews & Ratings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading:
                  const CircleAvatar(
                child: Icon(Icons.star),
              ),
              title: const Text(
                'Google rating',
              ),
              subtitle: Text(
                business.rating > 0
                    ? 'Rated ${business.rating.toStringAsFixed(1)} out of 5'
                    : 'No rating available',
              ),
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: () {
              showMessage(
                context,
                'Review form will be connected here.',
              );
            },
            icon: const Icon(
              Icons.rate_review,
            ),
            label:
                const Text('Write a Review'),
          ),
        ],
      ),
    );
  }

  Widget actionButton(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
        ),
        Text(title),
      ],
    );
  }

  Widget infoTile(
    IconData icon,
    String text,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.blue,
      ),
      title: Text(text),
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
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'No favorite businesses yet.',
              style: TextStyle(fontSize: 17),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding:
          const EdgeInsets.all(16),
      children: favorites
          .map(
            (business) => BusinessCard(
              business: business,
              isFavorite: true,
              onFavorite: () =>
                  onFavorite(business),
            ),
          )
          .toList(),
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
  final nameController =
      TextEditingController();

  final categoryController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final locationController =
      TextEditingController();

  final hoursController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  bool submitting = false;

  Future<void> submit() async {
    if (nameController.text.trim().isEmpty ||
        categoryController.text
            .trim()
            .isEmpty ||
        phoneController.text
            .trim()
            .isEmpty ||
        locationController.text
            .trim()
            .isEmpty) {
      showMessage(
        context,
        'Please fill the required fields.',
      );
      return;
    }

    setState(() {
      submitting = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    setState(() {
      submitting = false;
    });

    showMessage(
      context,
      'Business submitted successfully.',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    phoneController.dispose();
    locationController.dispose();
    hoursController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Add Your Business'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          const Text(
            'Business Information',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          field(
            controller: nameController,
            label: 'Business Name',
            icon: Icons.store,
          ),

          field(
            controller: categoryController,
            label: 'Category',
            icon: Icons.category,
          ),

          field(
            controller: phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            keyboardType:
                TextInputType.phone,
          ),

          field(
            controller: locationController,
            label: 'Location',
            icon: Icons.location_on,
          ),

          field(
            controller: hoursController,
            label: 'Opening Hours',
            icon: Icons.access_time,
          ),

          field(
            controller:
                descriptionController,
            label: 'Description',
            icon: Icons.description,
            maxLines: 4,
          ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () {
              showMessage(
                context,
                'Photo picker can be connected here.',
              );
            },
            icon: const Icon(Icons.photo),
            label:
                const Text('Add Photos'),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed:
                  submitting ? null : submit,
              child: submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Submit Business',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget field({
    required TextEditingController
        controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOGIN
// ============================================================

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Login / Sign Up'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.account_circle,
            size: 100,
            color: Colors.blue,
          ),

          const SizedBox(height: 20),

          const TextField(
            keyboardType:
                TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon:
                  Icon(Icons.email),
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon:
                  Icon(Icons.lock),
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                showMessage(
                  context,
                  'Login system ready.',
                );
              },
              child:
                  const Text('Login'),
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
              'Create New Account',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SIGN UP
// ============================================================

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Create Account'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon:
                  Icon(Icons.person),
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          const TextField(
            keyboardType:
                TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon:
                  Icon(Icons.email),
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon:
                  Icon(Icons.lock),
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                showMessage(
                  context,
                  'Account creation ready.',
                );
              },
              child:
                  const Text('Sign Up'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NOTIFICATIONS
// ============================================================

class NotificationsPage
    extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Notifications'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'No new notifications',
              style:
                  TextStyle(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INFO CARD
// ============================================================

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
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
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(text),
      ),
    );
  }
}

// ============================================================
// MESSAGE
// ============================================================

void showMessage(
  BuildContext context,
  String message,
) {
  ScaffoldMessenger.of(context)
      .hideCurrentSnackBar();

  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}
