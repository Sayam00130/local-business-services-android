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
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      ),
      home: const HomePage(),
    );
  }
}

/* ============================================================
   MODEL
============================================================ */

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
    return favorites.any((b) => b.id == business.id);
  }

  void toggleFavorite(Business business) {
    setState(() {
      if (isFavorite(business)) {
        favorites.removeWhere((b) => b.id == business.id);
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
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.indigo],
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
                'Find businesses, services, shops and more.',
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
            padding: const EdgeInsets.all(17),
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
              _category(
                context,
                Icons.restaurant,
                'Restaurants',
              ),
              _category(
                context,
                Icons.local_hospital,
                'Doctors',
              ),
              _category(
                context,
                Icons.electrical_services,
                'Electrician',
              ),
              _category(
                context,
                Icons.plumbing,
                'Plumber',
              ),
              _category(
                context,
                Icons.car_repair,
                'Mechanic',
              ),
              _category(
                context,
                Icons.store,
                'Shops',
              ),
              _category(
                context,
                Icons.school,
                'Schools',
              ),
              _category(
                context,
                Icons.hotel,
                'Hotels',
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        _quickCard(
          context,
          Icons.search,
          'Search Businesses',
          'Find real businesses using Google Places.',
          const SearchPage(),
        ),

        _quickCard(
          context,
          Icons.location_on,
          'Nearby',
          'Find services around your area.',
          const NearbyPage(),
        ),

        _quickCard(
          context,
          Icons.favorite,
          'Favorites',
          'Save businesses for quick access.',
          const FavoritesPage(
            favorites: [],
            onFavorite: _emptyFavorite,
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  static void _emptyFavorite(Business business) {}

  Widget _category(
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

  Widget _quickCard(
    BuildContext context,
    IconData icon,
    String title,
    String text,
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
        subtitle: Text(text),
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
   PLACES SERVICE
============================================================ */

class PlacesService {
  static const String apiKey = String.fromEnvironment(
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
            'places.id,places.displayName,places.formattedAddress,places.primaryType,places.rating,places.userRatingCount,places.nationalPhoneNumber,places.googleMapsUri,places.currentOpeningHours',
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
      final displayName = place['displayName'];

      final name = displayName is Map
          ? (displayName['text'] ?? 'Unknown Business')
              .toString()
          : 'Unknown Business';

      final category =
          (place['primaryType'] ?? 'Business')
              .toString()
              .replaceAll('_', ' ');

      final address =
          place['formattedAddress']?.toString() ??
              'Address unavailable';

      final phone =
          place['nationalPhoneNumber']?.toString() ??
              '';

      final mapsUrl =
          place['googleMapsUri']?.toString() ?? '';

      final ratingValue = place['rating'];

      final rating = ratingValue is num
          ? ratingValue.toDouble()
          : 0.0;

      final reviewValue =
          place['userRatingCount'];

      final reviewCount = reviewValue is num
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
}

/* ============================================================
   SEARCH
============================================================ */

class SearchPage extends StatefulWidget {
  final bool Function(Business) isFavorite;
  final void Function(Business) onFavorite;

  const SearchPage({
    super.key,
    this.isFavorite = _defaultFavorite,
    this.onFavorite = _defaultOnFavorite,
  });

  static bool _defaultFavorite(Business business) {
    return false;
  }

  static void _defaultOnFavorite(Business business) {}

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
                    child: CircularProgressIndicator(),
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
                        : ListView.builder(
                            padding:
                                const EdgeInsets.all(16),
                            itemCount: results.length,
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
    this.isFavorite = SearchPage._defaultFavorite,
    this.onFavorite = SearchPage._defaultOnFavorite,
  });

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  final locationController = TextEditingController();

  List<Business> results = [];
  bool loading = false;
  String error = '';

  Future<void> findNearby() async {
    final location =
        locationController.text.trim();

    if (location.isEmpty) {
      setState(() {
        error = 'Enter a city or area first.';
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
      final data = await PlacesService.search(
        'businesses and services near $location',
      );

      if (!mounted) return;

      setState(() {
        results = data;
        loading = false;

        if (data.isEmpty) {
          error = 'No businesses found nearby.';
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
        title: const Text('Nearby Businesses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: locationController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => findNearby(),
              decoration: InputDecoration(
                hintText: 'Enter city or area...',
                prefixIcon:
                    const Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: findNearby,
                ),
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
                    child: CircularProgressIndicator(),
                  )
                : error.isNotEmpty
                    ? Center(
                        child: Text(
                          error,
                          textAlign:
                              TextAlign.center,
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
                                const EdgeInsets.all(16),
                            itemCount: results.length,
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
    );
  }
}

/* ============================================================
   CATEGORY SEARCH
============================================================ */

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
  String error = '';

  @override
  void initState() {
    super.initState();
    loadCategory();
  }

  Future<void> loadCategory() async {
    try {
      final data = await PlacesService.search(
        '${widget.title} near Rawalpindi Pakistan',
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
              child: CircularProgressIndicator(),
            )
          : error.isNotEmpty
              ? Center(
                  child: Text(
                    error,
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return BusinessCard(
                      business: results[index],
                    );
                  },
                ),
    );
  }
}

/* ============================================================
   BUSINESS CARD
============================================================ */

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
      margin: const EdgeInsets.only(bottom: 12),
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
            Text(business.category),
            const SizedBox(height: 3),
            Text(
              '📍 ${business.address}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
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
                if (business.reviewCount > 0)
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
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(
            isFavorite
                ? Icons.favorite
                : Icons.favorite_border,
            color:
                isFavorite ? Colors.red : null,
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
      final query =
          Uri.encodeComponent(
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
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
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Text(
              '⭐ ${business.rating.toStringAsFixed(1)}'
              '  (${business.reviewCount} reviews)',
            ),
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              ActionButton(
                icon: Icons.call,
                title: 'Call',
                onPressed: () =>
                    callBusiness(context),
              ),
              ActionButton(
                icon: Icons.chat,
                title: 'WhatsApp',
                onPressed: () =>
                    openWhatsApp(context),
              ),
              ActionButton(
                icon: Icons.map,
                title: 'Maps',
                onPressed: () =>
                    openMaps(context),
              ),
            ],
          ),

          const SizedBox(height: 25),

          InfoTile(
            icon: Icons.location_on,
            text: business.address,
          ),

          InfoTile(
            icon: Icons.phone,
            text: business.phone.isEmpty
                ? 'Phone unavailable'
                : business.phone,
          ),

          InfoTile(
            icon: business.openNow
                ? Icons.check_circle
                : Icons.cancel,
            text: business.openNow
                ? 'Open now'
                : 'Currently closed',
          ),

          const SizedBox(height: 25),

          const Text(
            'Reviews & Ratings',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

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

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () {
              showMessage(
                context,
                'Review feature will be connected in the next stage.',
              );
            },
            icon:
                const Icon(Icons.rate_review),
            label:
                const Text('Write a Review'),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
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
        Text(title),
      ],
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoTile({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.blue,
      ),
      title: Text(text),
    );
  }
}

/* ============================================================
   FAVORITES
============================================================ */

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
          padding: EdgeInsets.all(25),
          child: Text(
            'No favorite businesses yet.\n\n'
            'Tap ❤️ on a business to save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final business = favorites[index];

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
    phoneController.dispose();
    addressController.dispose();
    hoursController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void submit() {
    if (nameController.text.trim().isEmpty ||
        categoryController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      showMessage(
        context,
        'Please fill all required fields.',
      );
      return;
    }

    showMessage(
      context,
      'Business submitted successfully.',
    );
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

          _field(
            nameController,
            'Business Name',
            Icons.store,
          ),

          _field(
            categoryController,
            'Category',
            Icons.category,
          ),

          _field(
            phoneController,
            'Phone Number',
            Icons.phone,
            keyboard:
                TextInputType.phone,
          ),

          _field(
            addressController,
            'Location / Address',
            Icons.location_on,
          ),

          _field(
            hoursController,
            'Opening Hours',
            Icons.access_time,
          ),

          _field(
            descriptionController,
            'Description',
            Icons.description,
            maxLines: 4,
          ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () {
              showMessage(
                context,
                'Photo upload will be connected in the next stage.',
              );
            },
            icon:
                const Icon(Icons.photo),
            label:
                const Text('Add Photos'),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: submit,
              child:
                  const Text('Submit Business'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
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

/* ============================================================
   LOGIN
============================================================ */

class LoginPage extends StatefulWidget {
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showMessage(
        context,
        'Please enter email and password.',
      );
      return;
    }

    showMessage(
      context,
      'Login system is ready for backend connection.',
    );
  }

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

          TextField(
            controller: emailController,
            keyboardType:
                TextInputType.emailAddress,
            decoration:
                const InputDecoration(
              labelText: 'Email',
              prefixIcon:
                  Icon(Icons.email),
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller:
                passwordController,
            obscureText: true,
            decoration:
                const InputDecoration(
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
              onPressed: login,
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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signup() {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showMessage(
        context,
        'Please complete all fields.',
      );
      return;
    }

    showMessage(
      context,
      'Account form is ready for backend connection.',
    );
  }

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
          TextField(
            controller: nameController,
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
            controller: emailController,
            keyboardType:
                TextInputType.emailAddress,
            decoration:
                const InputDecoration(
              labelText: 'Email',
              prefixIcon:
                  Icon(Icons.email),
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller:
                passwordController,
            obscureText: true,
            decoration:
                const InputDecoration(
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
              onPressed: signup,
              child:
                  const Text('Sign Up'),
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
      body: const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 15),
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

/* ============================================================
   HELPERS
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
      ),
    );
}
