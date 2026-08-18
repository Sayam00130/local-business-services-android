import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
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
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      ),
      home: const HomePage(),
    );
  }
}

/* ============================================================
   BUSINESS MODEL
============================================================ */

class Business {
  final String id;
  final String name;
  final String category;
  final String address;
  final String phone;
  final String mapsUrl;
  final String description;
  final String openingHours;
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
    this.description = '',
    this.openingHours = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.openNow = false,
  });
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
            tooltip: 'Account',
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
    return ListView(
      padding: const EdgeInsets.all(16),
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
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Discover Local Businesses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Find businesses, services, shops, restaurants and more around the world.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.4,
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
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
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

        const SizedBox(height: 12),

        SizedBox(
          height: 112,
          child: ListView(
            scrollDirection: Axis.horizontal,
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
          'Find real businesses using Google Places.',
          const SearchPage(),
        ),

        quickCard(
          context,
          Icons.location_on,
          'Nearby Businesses',
          'Search businesses around your city or area.',
          const NearbyPage(),
        ),

        quickCard(
          context,
          Icons.add_business,
          'List Your Business',
          'Create a professional business profile.',
          const AddBusinessPage(),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget categoryItem(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CategorySearchPage(title: title),
          ),
        );
      },
      child: Container(
        width: 105,
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
          mainAxisAlignment:
              MainAxisAlignment.center,
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
   GOOGLE PLACES SERVICE
============================================================ */

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
            'places.id,places.displayName,places.formattedAddress,places.primaryType,places.rating,places.userRatingCount,places.nationalPhoneNumber,places.internationalPhoneNumber,places.googleMapsUri,places.currentOpeningHours',
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
          message =
              data['error']['message'].toString();
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

      // International phone number preferred.
      final internationalPhone =
          place['internationalPhoneNumber']
              ?.toString();

      final nationalPhone =
          place['nationalPhoneNumber']
              ?.toString();

      final phone =
          (internationalPhone != null &&
                  internationalPhone.isNotEmpty)
              ? internationalPhone
              : (nationalPhone ?? '');

      final mapsUrl =
          place['googleMapsUri']
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
        rating: rating,
        reviewCount: reviewCount,
        openNow: openNow,
      );
    }).toList();
  }
}

/* ============================================================
   SEARCH PAGE
============================================================ */

class SearchPage extends StatefulWidget {
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const SearchPage({
    super.key,
    this.isFavorite = _defaultFavorite,
    this.onFavorite = _defaultFavoriteAction,
  });

  static bool _defaultFavorite(
    Business business,
  ) {
    return false;
  }

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
        title:
            const Text('Search Businesses'),
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
              onSubmitted: (_) => search(),
              decoration: InputDecoration(
                hintText:
                    'Business, service or location...',
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon:
                    IconButton(
                  icon:
                      const Icon(Icons.search),
                  onPressed: search,
                ),
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(
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
                              const EdgeInsets.all(
                            25,
                          ),
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
                                const EdgeInsets.all(
                              16,
                            ),
                            itemCount:
                                results.length,
                            itemBuilder:
                                (context, index) {
                              final business =
                                  results[index];

                              return BusinessCard(
                                business:
                                    business,
                                isFavorite:
                                    widget.isFavorite(
                                  business,
                                ),
                                onFavorite:
                                    () => widget
                                        .onFavorite(
                                  business,
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
   NEARBY PAGE
============================================================ */

class NearbyPage extends StatefulWidget {
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const NearbyPage({
    super.key,
    this.isFavorite =
        SearchPage._defaultFavorite,
    this.onFavorite =
        SearchPage._defaultFavoriteAction,
  });

  @override
  State<NearbyPage> createState() =>
      _NearbyPageState();
}

class _NearbyPageState
    extends State<NearbyPage> {
  final locationController =
      TextEditingController();

  List<Business> results = [];
  bool loading = false;
  String error = '';

  Future<void> findNearby() async {
    final location =
        locationController.text.trim();

    if (location.isEmpty) {
      setState(() {
        error =
            'Enter a city or area first.';
        results = [];
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
        'businesses and services near $location',
      );

      if (!mounted) return;

      setState(() {
        results = data;
        loading = false;

        if (data.isEmpty) {
          error =
              'No businesses found nearby.';
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
    locationController.dispose();
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
            padding:
                const EdgeInsets.all(16),
            child: TextField(
              controller:
                  locationController,
              textInputAction:
                  TextInputAction.search,
              onSubmitted: (_) =>
                  findNearby(),
              decoration: InputDecoration(
                hintText:
                    'Enter city or area...',
                prefixIcon: const Icon(
                  Icons.location_on,
                ),
                suffixIcon:
                    IconButton(
                  icon: const Icon(
                    Icons.search,
                  ),
                  onPressed:
                      findNearby,
                ),
                border:
                    OutlineInputBorder(
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
                              const EdgeInsets.all(
                            20,
                          ),
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
                              'Enter an area to find nearby businesses.',
                              textAlign:
                                  TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.all(
                              16,
                            ),
                            itemCount:
                                results.length,
                            itemBuilder:
                                (context, index) {
                              final business =
                                  results[index];

                              return BusinessCard(
                                business:
                                    business,
                                isFavorite:
                                    widget.isFavorite(
                                  business,
                                ),
                                onFavorite:
                                    () => widget
                                        .onFavorite(
                                  business,
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
   CATEGORY SEARCH
============================================================ */

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
  List<Business> results = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadCategory();
  }

  Future<void> loadCategory() async {
    try {
      final data =
          await PlacesService.search(
        widget.title,
      );

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
          : error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),
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
                        'No businesses found.',
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      itemCount:
                          results.length,
                      itemBuilder:
                          (context, index) {
                        return BusinessCard(
                          business:
                              results[index],
                        );
                      },
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
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          child: const Icon(
            Icons.business,
          ),
        ),
        title: Text(
          business.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              business.category,
            ),
            const SizedBox(height: 3),
            Text(
              business.address,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                Text(
                  ' ${business.rating.toStringAsFixed(1)}',
                ),
                if (business.reviewCount >
                    0)
                  Text(
                    ' (${business.reviewCount})',
                  ),
                const SizedBox(width: 8),
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
        ),
        trailing: IconButton(
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

    try {
      final launched =
          await launchUrl(uri);

      if (!launched) {
        showMessage(
          context,
          'Could not open phone dialer.',
        );
      }
    } catch (_) {
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

    final phone =
        business.phone.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (phone.isEmpty) {
      showMessage(
        context,
        'Invalid international phone number.',
      );
      return;
    }

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(
        'Hello ${business.name}',
      )}',
    );

    try {
      final launched =
          await launchUrl(
        uri,
        mode:
            LaunchMode.externalApplication,
      );

      if (!launched) {
        showMessage(
          context,
          'WhatsApp could not be opened.',
        );
      }
    } catch (_) {
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
      uri = Uri.parse(
        business.mapsUrl,
      );
    } else {
      final query =
          Uri.encodeComponent(
        '${business.name}, ${business.address}',
      );

      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$query',
      );
    }

    try {
      final launched =
          await launchUrl(
        uri,
        mode:
            LaunchMode.externalApplication,
      );

      if (!launched) {
        showMessage(
          context,
          'Google Maps could not be opened.',
        );
      }
    } catch (_) {
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
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
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
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor:
                      Colors.white,
                  child: Icon(
                    Icons.business,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  business.name,
                  textAlign:
                      TextAlign.center,
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
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              ActionButton(
                icon: Icons.call,
                title: 'Call',
                onPressed: () =>
                    callBusiness(
                  context,
                ),
              ),
              ActionButton(
                icon: Icons.chat,
                title: 'WhatsApp',
                onPressed: () =>
                    openWhatsApp(
                  context,
                ),
              ),
              ActionButton(
                icon: Icons.map,
                title: 'Maps',
                onPressed: () =>
                    openMaps(
                  context,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                children: [
                  infoRow(
                    Icons.location_on,
                    'Address',
                    business.address,
                  ),
                  infoRow(
                    Icons.phone,
                    'Phone',
                    business.phone.isEmpty
                        ? 'Not available'
                        : business.phone,
                  ),
                  infoRow(
                    Icons.access_time,
                    'Opening Hours',
                    business.openingHours.isEmpty
                        ? 'Not provided'
                        : business.openingHours,
                  ),
                  infoRow(
                    business.openNow
                        ? Icons.check_circle
                        : Icons.info_outline,
                    'Status',
                    business.openNow
                        ? 'Open now'
                        : 'Currently closed',
                  ),
                ],
              ),
            ),
          ),

          if (business.description
              .trim()
              .isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'About This Business',
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Text(
                  business.description,
                  style:
                      const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          const Text(
            'Ratings & Reviews',
            style: TextStyle(
              fontSize: 21,
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
              title: Text(
                '${business.rating.toStringAsFixed(1)} Rating',
              ),
              subtitle: Text(
                '${business.reviewCount} customer ratings',
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 50,
            child:
                OutlinedButton.icon(
              onPressed: () {
                showMessage(
                  context,
                  'Review feature will be connected to the backend in the next stage.',
                );
              },
              icon: const Icon(
                Icons.rate_review,
              ),
              label: const Text(
                'Write a Review',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.blue,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   ACTION BUTTON
============================================================ */

class ActionButton
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
        ),
        const SizedBox(height: 4),
        Text(title),
      ],
    );
  }
}

/* ============================================================
   FAVORITES
============================================================ */

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
          padding:
              EdgeInsets.all(25),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border,
                size: 70,
                color: Colors.grey,
              ),
              SizedBox(height: 15),
              Text(
                'No favorite businesses yet.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Tap the ❤️ button on a business to save it here.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(color: Colors.grey),
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
      itemBuilder:
          (context, index) {
        final business =
            favorites[index];

        return BusinessCard(
          business: business,
          isFavorite: true,
          onFavorite: () =>
              onFavorite(business),
        );
      },
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
  State<AddBusinessPage>
      createState() =>
          _AddBusinessPageState();
}

class _AddBusinessPageState
    extends State<AddBusinessPage> {
  final nameController =
      TextEditingController();

  final categoryController =
      TextEditingController();

  final countryCodeController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final addressController =
      TextEditingController();

  final hoursController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    countryCodeController.dispose();
    phoneController.dispose();
    addressController.dispose();
    hoursController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void submitBusiness() {
    final name =
        nameController.text.trim();
    final category =
        categoryController.text.trim();
    final countryCode =
        countryCodeController.text.trim();
    final phone =
        phoneController.text.trim();
    final address =
        addressController.text.trim();
    final hours =
        hoursController.text.trim();
    final description =
        descriptionController.text.trim();

    if (name.isEmpty ||
        category.isEmpty ||
        phone.isEmpty ||
        address.isEmpty) {
      showMessage(
        context,
        'Please complete the required business information.',
      );
      return;
    }

    String finalPhone = phone;

    if (countryCode.isNotEmpty &&
        !phone.startsWith('+')) {
      final cleanCode =
          countryCode.replaceAll(
        RegExp(r'[^0-9+]'),
        '',
      );

      final cleanPhone =
          phone.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      if (cleanCode.isNotEmpty) {
        finalPhone =
            '$cleanCode$cleanPhone';
      }
    }

    final business =
        Business(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: category,
      address: address,
      phone: finalPhone,
      mapsUrl: '',
      description: description,
      openingHours: hours,
      rating: 0,
      reviewCount: 0,
      openNow: false,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BusinessDetailsPage(
          business: business,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('List Your Business'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          const Text(
            'Create Your Business Profile',
            style: TextStyle(
              fontSize: 25,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Add your business information so customers can discover and contact you.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 25),

          businessField(
            nameController,
            'Business Name',
            Icons.store,
          ),

          businessField(
            categoryController,
            'Business Category',
            Icons.category,
          ),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: businessField(
                  countryCodeController,
                  'Code',
                  Icons.public,
                  keyboard:
                      TextInputType.phone,
                  hint:
                      '+92',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: businessField(
                  phoneController,
                  'Phone Number',
                  Icons.phone,
                  keyboard:
                      TextInputType.phone,
                  hint:
                      '3001234567',
                ),
              ),
            ],
          ),

          businessField(
            addressController,
            'Business Address',
            Icons.location_on,
          ),

          businessField(
            hoursController,
            'Opening Hours',
            Icons.access_time,
            hint:
                'Example: Mon-Sat, 10 AM - 8 PM',
          ),

          businessField(
            descriptionController,
            'Business Description',
            Icons.description,
            maxLines: 5,
            hint:
                'Tell customers about your business...',
          ),

          const SizedBox(height: 10),

          Container(
            padding:
                const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.blue
                  .withValues(alpha: 0.06),
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue
                    .withValues(alpha: 0.15),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: Colors.blue,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Business photos can be connected when the online storage/backend is added.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed:
                  submitBusiness,
              icon: const Icon(
                Icons.check_circle_outline,
              ),
              label: const Text(
                'Create Business Profile',
                style:
                    TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget businessField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboard,
    String? hint,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration:
            InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon:
              Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              15,
            ),
          ),
        ),
      ),
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
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    final email =
        emailController.text.trim();
    final password =
        passwordController.text;

    if (email.isEmpty ||
        password.isEmpty) {
      showMessage(
        context,
        'Please enter your email and password.',
      );
      return;
    }

    showMessage(
      context,
      'Login will be connected to the secure backend.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Welcome Back'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(22),
        children: [
          const SizedBox(height: 20),

          Container(
            padding:
                const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.indigo,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(25),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor:
                      Colors.white,
                  child: Icon(
                    Icons.business_center,
                    size: 42,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Local Business & Services',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Sign in to manage your account and businesses.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          TextField(
            controller:
                emailController,
            keyboardType:
                TextInputType.emailAddress,
            decoration:
                InputDecoration(
              labelText: 'Email Address',
              prefixIcon:
                  const Icon(
                Icons.email_outlined,
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

          const SizedBox(height: 15),

          TextField(
            controller:
                passwordController,
            obscureText: hidePassword,
            decoration:
                InputDecoration(
              labelText: 'Password',
              prefixIcon:
                  const Icon(
                Icons.lock_outline,
              ),
              suffixIcon:
                  IconButton(
                icon: Icon(
                  hidePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    hidePassword =
                        !hidePassword;
                  });
                },
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

          const SizedBox(height: 22),

          SizedBox(
            height: 54,
            child:
                ElevatedButton(
              onPressed: login,
              child: const Text(
                'Sign In',
                style:
                    TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: TextButton(
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
                'New here? Create an account',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   SIGN UP
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
  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmController =
      TextEditingController();

  bool hidePassword = true;
  bool hideConfirm = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void createAccount() {
    final name =
        nameController.text.trim();
    final email =
        emailController.text.trim();
    final password =
        passwordController.text;
    final confirm =
        confirmController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      showMessage(
        context,
        'Please complete all fields.',
      );
      return;
    }

    if (password != confirm) {
      showMessage(
        context,
        'Passwords do not match.',
      );
      return;
    }

    if (password.length < 6) {
      showMessage(
        context,
        'Password must contain at least 6 characters.',
      );
      return;
    }

    showMessage(
      context,
      'Account details are ready for secure backend connection.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Create Your Account'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(22),
        children: [
          const SizedBox(height: 15),

          const Text(
            'Join Local Business & Services',
            style: TextStyle(
              fontSize: 25,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Create your account to discover businesses or manage your own business profile.',
            style: TextStyle(
              color: Colors.grey,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 25),

          TextField(
            controller:
                nameController,
            decoration:
                InputDecoration(
              labelText: 'Full Name',
              prefixIcon:
                  const Icon(
                Icons.person_outline,
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

          const SizedBox(height: 15),

          TextField(
            controller:
                emailController,
            keyboardType:
                TextInputType.emailAddress,
            decoration:
                InputDecoration(
              labelText: 'Email Address',
              prefixIcon:
                  const Icon(
                Icons.email_outlined,
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

          const SizedBox(height: 15),

          TextField(
            controller:
                passwordController,
            obscureText: hidePassword,
            decoration:
                InputDecoration(
              labelText: 'Password',
              prefixIcon:
                  const Icon(
                Icons.lock_outline,
              ),
              suffixIcon:
                  IconButton(
                icon: Icon(
                  hidePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    hidePassword =
                        !hidePassword;
                  });
                },
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

          const SizedBox(height: 15),

          TextField(
            controller:
                confirmController,
            obscureText: hideConfirm,
            decoration:
                InputDecoration(
              labelText:
                  'Confirm Password',
              prefixIcon:
                  const Icon(
                Icons.verified_user_outlined,
              ),
              suffixIcon:
                  IconButton(
                icon: Icon(
                  hideConfirm
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    hideConfirm =
                        !hideConfirm;
                  });
                },
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

          const SizedBox(height: 24),

          SizedBox(
            height: 54,
            child:
                ElevatedButton(
              onPressed:
                  createAccount,
              child: const Text(
                'Create Account',
                style:
                    TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Your account will be connected to a secure backend when authentication is added.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   NOTIFICATIONS
============================================================ */

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
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 15),
            const Text(
              'No new notifications',
              style:
                  TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'You are all caught up.',
              style:
                  TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   MESSAGE HELPER
============================================================ */

void showMessage(
  BuildContext context,
  String message,
) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
}
