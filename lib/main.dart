import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
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
  final String location;
  final String phone;
  final String mapsUrl;
  final double rating;

  const Business({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.phone,
    required this.mapsUrl,
    required this.rating,
  });

  factory Business.fromGoogle(Map<String, dynamic> place) {
    final displayName = place['displayName'];

    final name = displayName is Map
        ? (displayName['text'] ?? 'Unknown Business').toString()
        : 'Unknown Business';

    return Business(
      id: place['id']?.toString() ?? name,
      name: name,
      category: _formatCategory(
        place['primaryType']?.toString() ?? 'Business',
      ),
      location:
          place['formattedAddress']?.toString() ?? 'Location unavailable',
      phone: place['nationalPhoneNumber']?.toString() ?? '',
      mapsUrl: place['googleMapsUri']?.toString() ?? '',
      rating: place['rating'] is num
          ? (place['rating'] as num).toDouble()
          : 0.0,
    );
  }

  static String _formatCategory(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

// ============================================================
// GOOGLE PLACES SERVICE
// ============================================================

class PlacesService {
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
  );

  static const String endpoint =
      'https://places.googleapis.com/v1/places:searchText';

  static const String fieldMask =
      'places.id,'
      'places.displayName,'
      'places.formattedAddress,'
      'places.primaryType,'
      'places.rating,'
      'places.nationalPhoneNumber,'
      'places.googleMapsUri,'
      'nextPageToken';

  Future<SearchResult> search({
    required String query,
    String? pageToken,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception(
        'Google Places API key is missing.',
      );
    }

    final body = <String, dynamic>{
      'textQuery': query,
      'pageSize': 20,
    };

    if (pageToken != null && pageToken.isNotEmpty) {
      body['pageToken'] = pageToken;
    }

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': fieldMask,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      String message = 'Google Places error: ${response.statusCode}';

      try {
        final error = jsonDecode(response.body);

        if (error is Map && error['error'] is Map) {
          final errorData = error['error'];

          if (errorData['message'] != null) {
            message = errorData['message'].toString();
          }
        }
      } catch (_) {}

      throw Exception(message);
    }

    final data = jsonDecode(response.body);

    final places = data['places'];

    final list = places is List
        ? places
            .whereType<Map>()
            .map(
              (place) => Business.fromGoogle(
                Map<String, dynamic>.from(place),
              ),
            )
            .toList()
        : <Business>[];

    final nextPageToken = data['nextPageToken']?.toString();

    return SearchResult(
      businesses: list,
      nextPageToken: nextPageToken,
    );
  }
}

class SearchResult {
  final List<Business> businesses;
  final String? nextPageToken;

  const SearchResult({
    required this.businesses,
    required this.nextPageToken,
  });
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(
        favorites: favorites,
        onFavorite: toggleFavorite,
      ),
      SearchPage(
        favorites: favorites,
        onFavorite: toggleFavorite,
      ),
      const NearbyPage(),
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
                  builder: (_) => const NotificationsPage(),
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

  void toggleFavorite(Business business) {
    setState(() {
      final exists = favorites.any(
        (item) => item.id == business.id,
      );

      if (exists) {
        favorites.removeWhere(
          (item) => item.id == business.id,
        );
      } else {
        favorites.add(business);
      }
    });
  }
}

// ============================================================
// HOME TAB
// ============================================================

class HomeTab extends StatelessWidget {
  final List<Business> favorites;
  final Function(Business) onFavorite;

  const HomeTab({
    super.key,
    required this.favorites,
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
                'Search businesses, shops and services around you.',
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
              vertical: 18,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.search),
                SizedBox(width: 12),
                Text(
                  'Search businesses or services...',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
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
          height: 105,
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
            ],
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          'Search Popular Places',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        categorySearchButton(
          context,
          'Restaurants',
          Icons.restaurant,
        ),

        categorySearchButton(
          context,
          'Doctors',
          Icons.local_hospital,
        ),

        categorySearchButton(
          context,
          'Mechanics',
          Icons.car_repair,
        ),

        categorySearchButton(
          context,
          'Electricians',
          Icons.electrical_services,
        ),

        categorySearchButton(
          context,
          'Plumbers',
          Icons.plumbing,
        ),

        categorySearchButton(
          context,
          'Shops',
          Icons.store,
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
            builder: (_) => SearchPage(
              initialQuery: title,
            ),
          ),
        );
      },
      child: Container(
        width: 95,
        margin: const EdgeInsets.only(
          right: 10,
        ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.blue,
            ),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categorySearchButton(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 17,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchPage(
                initialQuery: title,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// SEARCH PAGE
// ============================================================

class SearchPage extends StatefulWidget {
  final String? initialQuery;
  final List<Business>? favorites;
  final Function(Business)? onFavorite;

  const SearchPage({
    super.key,
    this.initialQuery,
    this.favorites,
    this.onFavorite,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final PlacesService placesService =
      PlacesService();

  late final TextEditingController controller;

  final List<Business> results = [];

  String? nextPageToken;

  String currentQuery = '';

  bool loading = false;
  bool loadingMore = false;

  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(
      text: widget.initialQuery ?? '',
    );

    if (widget.initialQuery != null &&
        widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          search();
        },
      );
    }
  }

  Future<void> search() async {
    final query = controller.text.trim();

    if (query.isEmpty) {
      setState(() {
        results.clear();
        errorMessage = '';
        nextPageToken = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      loadingMore = false;
      errorMessage = '';
      results.clear();
      nextPageToken = null;
      currentQuery = query;
    });

    try {
      final response =
          await placesService.search(
        query: query,
      );

      if (!mounted) return;

      setState(() {
        results.addAll(
          removeDuplicates(response.businesses),
        );

        nextPageToken =
            response.nextPageToken;

        loading = false;

        if (results.isEmpty) {
          errorMessage =
              'No businesses found.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage =
            friendlyError(e);
      });
    }
  }

  Future<void> loadMore() async {
    if (loadingMore ||
        nextPageToken == null ||
        nextPageToken!.isEmpty ||
        currentQuery.isEmpty) {
      return;
    }

    setState(() {
      loadingMore = true;
    });

    try {
      final response =
          await placesService.search(
        query: currentQuery,
        pageToken: nextPageToken,
      );

      if (!mounted) return;

      setState(() {
        final existingIds =
            results.map((b) => b.id).toSet();

        for (final business
            in response.businesses) {
          if (!existingIds.contains(
            business.id,
          )) {
            results.add(business);
            existingIds.add(business.id);
          }
        }

        nextPageToken =
            response.nextPageToken;

        loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingMore = false;
        errorMessage =
            friendlyError(e);
      });
    }
  }

  List<Business> removeDuplicates(
    List<Business> list,
  ) {
    final ids = <String>{};
    final output = <Business>[];

    for (final business in list) {
      if (ids.add(business.id)) {
        output.add(business);
      }
    }

    return output;
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

          if (results.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  '${results.length} results found',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            25,
                          ),
                          child: Text(
                            errorMessage,
                            textAlign:
                                TextAlign.center,
                          ),
                        ),
                      )
                    : results.isEmpty
                        ? const Center(
                            child: Text(
                              'Search for any business or service.',
                              textAlign:
                                  TextAlign.center,
                            ),
                          )
                        : NotificationListener<
                            ScrollNotification>(
                            onNotification:
                                (notification) {
                              if (notification
                                      is ScrollEndNotification &&
                                  notification
                                          .metrics
                                          .extentAfter <
                                      300) {
                                loadMore();
                              }

                              return false;
                            },
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets
                                      .all(16),
                              itemCount:
                                  results.length +
                                      (nextPageToken !=
                                              null
                                          ? 1
                                          : 0),
                              itemBuilder:
                                  (context, index) {
                                if (index >=
                                    results.length) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets
                                            .all(
                                      20,
                                    ),
                                    child: Center(
                                      child:
                                          loadingMore
                                              ? const CircularProgressIndicator()
                                              : const Text(
                                                  'Loading more results...',
                                                ),
                                    ),
                                  );
                                }

                                final business =
                                    results[index];

                                return BusinessCard(
                                  business: business,
                                  isFavorite:
                                      widget.favorites
                                              ?.any(
                                            (b) =>
                                                b.id ==
                                                business.id,
                                          ) ??
                                          false,
                                  onFavorite:
                                      widget
                                          .onFavorite !=
                                              null
                                          ? () {
                                              widget
                                                  .onFavorite!(
                                                business,
                                              );
                                            }
                                          : null,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  String friendlyError(Object error) {
    final text = error.toString();

    if (text.contains(
      'API key is missing',
    )) {
      return 'Google Places API key is missing.\n\n'
          'Make sure GOOGLE_PLACES_API_KEY is '
          'passed during the Flutter build.';
    }

    return 'Search could not be completed.\n\n$text';
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
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
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
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                child: Icon(
                  businessIcon(
                    business.category,
                  ),
                ),
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

                    const SizedBox(height: 4),

                    Text(
                      business.category,
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      business.location,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    if (business.rating > 0)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 5,
                        ),
                        child: Text(
                          '⭐ ${business.rating.toStringAsFixed(1)}',
                        ),
                      ),
                  ],
                ),
              ),

              if (onFavorite != null)
                IconButton(
                  onPressed: onFavorite,
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: isFavorite
                        ? Colors.red
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData businessIcon(
    String category,
  ) {
    final value =
        category.toLowerCase();

    if (value.contains('restaurant') ||
        value.contains('food') ||
        value.contains('cafe')) {
      return Icons.restaurant;
    }

    if (value.contains('doctor') ||
        value.contains('hospital') ||
        value.contains('medical')) {
      return Icons.local_hospital;
    }

    if (value.contains('electric')) {
      return Icons.electrical_services;
    }

    if (value.contains('plumb')) {
      return Icons.plumbing;
    }

    if (value.contains('mechanic') ||
        value.contains('car')) {
      return Icons.car_repair;
    }

    if (value.contains('shop') ||
        value.contains('store')) {
      return Icons.store;
    }

    return Icons.business;
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
        title:
            const Text('Business Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 55,
            child: Icon(
              Icons.business,
              size: 55,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            business.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            business.category,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          if (business.rating > 0)
            Padding(
              padding:
                  const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '⭐ ${business.rating.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 18,
                  ),
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
                callBusiness,
              ),
              actionButton(
                context,
                Icons.chat,
                'WhatsApp',
                openWhatsApp,
              ),
              actionButton(
                context,
                Icons.map,
                'Maps',
                openMaps,
              ),
            ],
          ),

          const SizedBox(height: 25),

          infoTile(
            Icons.location_on,
            business.location,
          ),

          if (business.phone.isNotEmpty)
            infoTile(
              Icons.phone,
              business.phone,
            ),

          const SizedBox(height: 25),

          const Text(
            'Business Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Text(
                'For accurate opening hours, '
                'reviews and additional business '
                'information, open the business '
                'on Google Maps.',
              ),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: () => openMaps(),
            icon: const Icon(Icons.map),
            label: const Text(
              'Open in Google Maps',
            ),
          ),

          const SizedBox(height: 30),
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

  Future<void> callBusiness() async {
    if (business.phone.isEmpty) {
      return;
    }

    final uri =
        Uri.parse('tel:${business.phone}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> openWhatsApp() async {
    if (business.phone.isEmpty) {
      return;
    }

    final phone = business.phone.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

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
    }
  }

  Future<void> openMaps() async {
    final uri = business.mapsUrl.isNotEmpty
        ? Uri.parse(business.mapsUrl)
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query='
            '${Uri.encodeComponent('${business.name}, ${business.location}')}',
          );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode:
            LaunchMode.externalApplication,
      );
    }
  }
}

// ============================================================
// NEARBY
// ============================================================

class NearbyPage extends StatelessWidget {
  const NearbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(
          Icons.location_on,
          size: 80,
          color: Colors.blue,
        ),

        const SizedBox(height: 15),

        const Text(
          'Businesses Near You',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Search Google Maps for businesses '
          'near your current area.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 25),

        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SearchPage(
                  initialQuery:
                      'businesses near me',
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.search,
          ),
          label: const Text(
            'Find Businesses Near Me',
          ),
        ),

        const SizedBox(height: 15),

        OutlinedButton.icon(
          onPressed: () async {
            final uri = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=businesses+near+me',
            );

            if (await canLaunchUrl(uri)) {
              await launchUrl(
                uri,
                mode:
                    LaunchMode.externalApplication,
              );
            }
          },
          icon: const Icon(Icons.map),
          label: const Text(
            'Open Google Maps',
          ),
        ),
      ],
    );
  }
}

// ============================================================
// FAVORITES
// ============================================================

class FavoritesPage
    extends StatelessWidget {
  final List<Business> favorites;
  final Function(Business) onFavorite;

  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          'No favorite businesses yet.',
          style: TextStyle(
            fontSize: 17,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
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

class AddBusinessPage
    extends StatefulWidget {
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
        padding: const EdgeInsets.all(20),
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
            nameController,
            'Business Name',
            Icons.store,
          ),

          field(
            categoryController,
            'Category',
            Icons.category,
          ),

          field(
            phoneController,
            'Phone Number',
            Icons.phone,
          ),

          field(
            locationController,
            'Location',
            Icons.location_on,
          ),

          field(
            hoursController,
            'Opening Hours',
            Icons.access_time,
          ),

          field(
            descriptionController,
            'Description',
            Icons.description,
            maxLines: 4,
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              if (nameController.text
                  .trim()
                  .isEmpty) {
                showMessage(
                  context,
                  'Business name is required.',
                );
                return;
              }

              showMessage(
                context,
                'Business submitted successfully.',
              );
            },
            child: const Text(
              'Submit Business',
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
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
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
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.account_circle,
            size: 100,
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

          ElevatedButton(
            onPressed: () {
              showMessage(
                context,
                'Login system is ready.',
              );
            },
            child:
                const Text('Login'),
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

class SignupPage
    extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Create Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
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

          ElevatedButton(
            onPressed: () {
              showMessage(
                context,
                'Account creation system is ready.',
              );
            },
            child:
                const Text('Sign Up'),
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
  const NotificationsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Notifications'),
      ),
      body: const Center(
        child: Text(
          'No new notifications',
          style:
              TextStyle(fontSize: 17),
        ),
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

void showMessage(
  BuildContext context,
  String message,
) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}
