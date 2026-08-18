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
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      ),
      home: const HomePage(),
    );
  }
}

class Business {
  final String name;
  final String category;
  final String location;
  final String phone;
  final double rating;
  final String? id;
  final IconData icon;

  const Business({
    required this.name,
    required this.category,
    required this.location,
    required this.phone,
    required this.rating,
    this.id,
    required this.icon,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Business) return false;

    if (id != null && other.id != null) {
      return id == other.id;
    }

    return name == other.name && location == other.location;
  }

  @override
  int get hashCode => id?.hashCode ?? Object.hash(name, location);
}

class GooglePlacesService {
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
  );

  static const String endpoint =
      'https://places.googleapis.com/v1/places:searchText';

  Future<PlacesSearchResult> search({
    required String query,
    String? pageToken,
  }) async {
    final uri = Uri.parse(endpoint);

    final body = <String, dynamic>{
      'textQuery': query,
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
            'places.id,places.displayName,places.formattedAddress,'
            'places.primaryType,places.rating,places.nationalPhoneNumber,'
            'nextPageToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Google Places API error: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final places = data['places'] as List? ?? [];

    final businesses = places.map<Business>((place) {
      final map = place as Map<String, dynamic>;

      final displayName = map['displayName'];
      final name = displayName is Map
          ? (displayName['text'] ?? 'Unknown Business').toString()
          : 'Unknown Business';

      final address =
          map['formattedAddress']?.toString() ?? 'Location unavailable';

      final primaryType =
          map['primaryType']?.toString() ?? 'Business';

      final phone =
          map['nationalPhoneNumber']?.toString() ?? '';

      final ratingValue = map['rating'];
      final rating =
          ratingValue is num ? ratingValue.toDouble() : 0.0;

      final id = map['id']?.toString();

      return Business(
        name: name,
        category: primaryType,
        location: address,
        phone: phone,
        rating: rating,
        id: id,
        icon: _iconForCategory(primaryType),
      );
    }).toList();

    return PlacesSearchResult(
      businesses: businesses,
      nextPageToken: data['nextPageToken']?.toString(),
    );
  }

  IconData _iconForCategory(String category) {
    final value = category.toLowerCase();

    if (value.contains('restaurant') ||
        value.contains('food') ||
        value.contains('cafe')) {
      return Icons.restaurant;
    }

    if (value.contains('doctor') ||
        value.contains('hospital') ||
        value.contains('health')) {
      return Icons.local_hospital;
    }

    if (value.contains('electric')) {
      return Icons.electrical_services;
    }

    if (value.contains('plumb')) {
      return Icons.plumbing;
    }

    if (value.contains('car') ||
        value.contains('auto') ||
        value.contains('mechanic')) {
      return Icons.car_repair;
    }

    if (value.contains('store') ||
        value.contains('shop') ||
        value.contains('market')) {
      return Icons.store;
    }

    return Icons.business;
  }
}

class PlacesSearchResult {
  final List<Business> businesses;
  final String? nextPageToken;

  const PlacesSearchResult({
    required this.businesses,
    required this.nextPageToken,
  });
}

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
      SearchTab(
        favorites: favorites,
        onFavorite: toggleFavorite,
      ),
      NearbyTab(
        favorites: favorites,
        onFavorite: toggleFavorite,
      ),
      FavoritesTab(
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
                  builder: (_) => const NotificationsPage(),
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
      if (favorites.contains(business)) {
        favorites.remove(business);
      } else {
        favorites.add(business);
      }
    });
  }
}

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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.blue,
                Colors.indigo,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Local Businesses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Find businesses and services near you.',
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
          borderRadius: BorderRadius.circular(15),
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
              borderRadius: BorderRadius.circular(15),
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
              ],
            ),
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 20,
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
          'Search the real local businesses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Use Search to find real businesses, services, shops, restaurants and more.',
          style: TextStyle(
            color: Colors.grey,
          ),
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
            builder: (_) => CategoryPage(
              title: title,
            ),
          ),
        );
      },
      child: Container(
        width: 95,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
}

class SearchTab extends StatelessWidget {
  final List<Business> favorites;
  final Function(Business) onFavorite;

  const SearchTab({
    super.key,
    required this.favorites,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SearchPage(),
              ),
            );
          },
          icon: const Icon(Icons.search),
          label: const Text('Search Real Businesses'),
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController =
      TextEditingController();

  final GooglePlacesService placesService =
      GooglePlacesService();

  final List<Business> results = [];

  String? nextPageToken;

  bool isLoading = false;
  bool isLoadingMore = false;

  String errorMessage = '';

  Future<void> searchBusinesses() async {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        results.clear();
        nextPageToken = null;
        errorMessage = 'Please enter a business or service.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      isLoadingMore = false;
      errorMessage = '';
      results.clear();
      nextPageToken = null;
    });

    try {
      final response = await placesService.search(
        query: query,
      );

      if (!mounted) return;

      setState(() {
        results.addAll(response.businesses);
        nextPageToken = response.nextPageToken;
        isLoading = false;

        if (results.isEmpty) {
          errorMessage = 'No businesses found.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        results.clear();
        errorMessage =
            'Search failed. Check your Google Places API setup.';
      });
    }
  }

  Future<void> loadMoreResults() async {
    if (nextPageToken == null ||
        nextPageToken!.isEmpty ||
        isLoadingMore) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await placesService.search(
        query: searchController.text.trim(),
        pageToken: nextPageToken,
      );

      if (!mounted) return;

      setState(() {
        results.addAll(response.businesses);
        nextPageToken = response.nextPageToken;
        isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingMore = false;
      });

      showMessage(
        context,
        'Could not load more results.',
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Businesses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => searchBusinesses(),
              decoration: InputDecoration(
                hintText:
                    'Business, service or location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: searchBusinesses,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : errorMessage.isNotEmpty &&
                          results.isEmpty
                      ? Center(
                          child: Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        )
                      : NotificationListener<
                          ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.pixels >=
                                notification.metrics.maxScrollExtent -
                                    300) {
                              loadMoreResults();
                            }

                            return false;
                          },
                          child: ListView.builder(
                            itemCount: results.length +
                                (nextPageToken != null ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= results.length) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.all(20),
                                  child: Center(
                                    child: isLoadingMore
                                        ? const CircularProgressIndicator()
                                        : ElevatedButton(
                                            onPressed:
                                                loadMoreResults,
                                            child: const Text(
                                              'Load More Results',
                                            ),
                                          ),
                                  ),
                                );
                              }

                              return BusinessCard(
                                business: results[index],
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}class NearbyTab extends StatelessWidget {
  final List<Business> favorites;
  final Function(Business) onFavorite;

  const NearbyTab({
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.location_on,
                size: 70,
                color: Colors.blue,
              ),
              SizedBox(height: 10),
              Text(
                'Find Businesses Near You',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Search for businesses in your city or area.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SearchPage(),
              ),
            );
          },
          icon: const Icon(Icons.search),
          label: const Text('Search Nearby Businesses'),
        ),
      ],
    );
  }
}

class FavoritesTab extends StatelessWidget {
  final List<Business> favorites;
  final Function(Business) onFavorite;

  const FavoritesTab({
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
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 15),
            Text(
              'No favorite businesses yet.',
              style: TextStyle(fontSize: 17),
            ),
            SizedBox(height: 8),
            Text(
              'Tap ❤️ on a business to save it here.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
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
              onFavorite: () => onFavorite(business),
            ),
          )
          .toList(),
    );
  }
}

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
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          child: Icon(
            business.icon,
            size: 28,
          ),
        ),
        title: Text(
          business.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                business.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '📍 ${business.location}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              if (business.rating > 0)
                Text('⭐ ${business.rating.toStringAsFixed(1)}'),
            ],
          ),
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'Favorite',
          icon: Icon(
            isFavorite
                ? Icons.favorite
                : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: onFavorite,
        ),
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

  Future<void> callBusiness(BuildContext context) async {
    if (business.phone.trim().isEmpty) {
      showMessage(
        context,
        'Phone number is not available.',
      );
      return;
    }

    final uri = Uri(
      scheme: 'tel',
      path: business.phone,
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
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

  Future<void> openWhatsApp(BuildContext context) async {
    if (business.phone.trim().isEmpty) {
      showMessage(
        context,
        'WhatsApp number is not available.',
      );
      return;
    }

    String phone =
        business.phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (phone.startsWith('+')) {
      phone = phone.substring(1);
    }

    final message = Uri.encodeComponent(
      'Hello, I found your business on Local Business & Services.',
    );

    final uri = Uri.parse(
      'https://wa.me/$phone?text=$message',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
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

  Future<void> openMaps(BuildContext context) async {
    final query = Uri.encodeComponent(
      '${business.name}, ${business.location}',
    );

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
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
        title: const Text('Business Profile'),
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
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 58,
            child: Icon(
              business.icon,
              size: 58,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            business.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            business.category,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 10),

          if (business.rating > 0)
            Center(
              child: Text(
                '⭐ ${business.rating.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              actionButton(
                Icons.call,
                'Call',
                () => callBusiness(context),
              ),
              actionButton(
                Icons.chat,
                'WhatsApp',
                () => openWhatsApp(context),
              ),
              actionButton(
                Icons.map,
                'Maps',
                () => openMaps(context),
              ),
              actionButton(
                Icons.report,
                'Report',
                () {
                  showMessage(
                    context,
                    'Report option selected.',
                  );
                },
              ),
            ],
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

          infoTile(
            Icons.location_on,
            business.location,
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
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: const Text('Customer Reviews'),
              subtitle: const Text(
                'Ratings are provided by Google Places.',
              ),
              trailing: business.rating > 0
                  ? Text(
                      '⭐ ${business.rating.toStringAsFixed(1)}',
                    )
                  : const Text('No rating'),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: () {
              showMessage(
                context,
                'Review form will be connected here.',
              );
            },
            icon: const Icon(Icons.rate_review),
            label: const Text('Write a Review'),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget actionButton(
    IconData icon,
    String title,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
          tooltip: title,
        ),
        const SizedBox(height: 4),
        Text(title),
      ],
    );
  }

  Widget infoTile(
    IconData icon,
    String text,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: Colors.blue,
      ),
      title: Text(text),
    );
  }
}

class CategoryPage extends StatefulWidget {
  final String title;

  const CategoryPage({
    super.key,
    required this.title,
  });

  @override
  State<CategoryPage> createState() =>
      _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final GooglePlacesService placesService =
      GooglePlacesService();

  List<Business> results = [];
  String? nextPageToken;

  bool isLoading = true;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    searchCategory();
  }

  Future<void> searchCategory() async {
    try {
      final response = await placesService.search(
        query: widget.title,
      );

      if (!mounted) return;

      setState(() {
        results = response.businesses;
        nextPageToken = response.nextPageToken;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadMore() async {
    if (nextPageToken == null ||
        nextPageToken!.isEmpty ||
        isLoadingMore) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await placesService.search(
        query: widget.title,
        pageToken: nextPageToken,
      );

      if (!mounted) return;

      setState(() {
        results.addAll(response.businesses);
        nextPageToken = response.nextPageToken;
        isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : results.isEmpty
              ? const Center(
                  child: Text(
                    'No businesses found.',
                  ),
                )
              : NotificationListener<
                  ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent -
                            300) {
                      loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length +
                        (nextPageToken != null ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= results.length) {
                        return Padding(
                          padding:
                              const EdgeInsets.all(20),
                          child: Center(
                            child: isLoadingMore
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: loadMore,
                                    child: const Text(
                                      'Load More',
                                    ),
                                  ),
                          ),
                        );
                      }

                      return BusinessCard(
                        business: results[index],
                      );
                    },
                  ),
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
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final hoursController = TextEditingController();
  final descriptionController = TextEditingController();

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

  void submitBusiness() {
    if (nameController.text.trim().isEmpty ||
        categoryController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
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
        title: const Text('Add Your Business'),
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
            keyboardType: TextInputType.phone,
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
            controller: descriptionController,
            label: 'Description',
            icon: Icons.description,
            maxLines: 4,
          ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () {
              showMessage(
                context,
                'Photo picker will be connected here.',
              );
            },
            icon: const Icon(Icons.photo),
            label: const Text('Add Photos'),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: submitBusiness,
              child: const Text(
                'Submit Business',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
      'Login system is ready to connect.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login / Sign Up'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.account_circle,
            size: 100,
            color: Colors.blue,
          ),

          const SizedBox(height: 20),

          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: login,
              child: const Text('Login'),
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
            child: const Text(
              'Create New Account',
            ),
          ),
        ],
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() =>
      _SignupPageState();
}

class _SignupPageState
    extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
        'Please fill all fields.',
      );
      return;
    }

    showMessage(
      context,
      'Account creation system is ready.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: signup,
              child: const Text('Sign Up'),
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
      appBar: AppBar(
        title: const Text('Notifications'),
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
              style: TextStyle(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}

void showMessage(
  BuildContext context,
  String message,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}class BusinessDetailsPage extends StatelessWidget {
  final Business business;

  const BusinessDetailsPage({
    super.key,
    required this.business,
  });

  Future<void> callBusiness(BuildContext context) async {
    if (business.phone.trim().isEmpty) {
      showMessage(context, 'Phone number not available');
      return;
    }

    final uri = Uri.parse('tel:${business.phone}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showMessage(context, 'Could not open phone dialer');
    }
  }

  Future<void> openWhatsApp(BuildContext context) async {
    if (business.phone.trim().isEmpty) {
      showMessage(context, 'WhatsApp number not available');
      return;
    }

    String phone = business.phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.startsWith('0')) {
      phone = '92${phone.substring(1)}';
    }

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(
        'Hello, I found your business on Local Business & Services.',
      )}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      showMessage(context, 'WhatsApp could not be opened');
    }
  }

  Future<void> openMaps(BuildContext context) async {
    final query = Uri.encodeComponent(
      '${business.name}, ${business.location}',
    );

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      showMessage(context, 'Google Maps could not be opened');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              showMessage(context, 'Share option selected');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 55,
            child: Icon(
              business.icon,
              size: 55,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            business.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            business.category,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Text(
              '⭐ ${business.rating.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                Icons.directions,
                'Maps',
                () => openMaps(context),
              ),
              actionButton(
                context,
                Icons.report,
                'Report',
                () {
                  showMessage(
                    context,
                    'Report option selected',
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 25),

          infoTile(
            Icons.location_on,
            business.location,
          ),

          infoTile(
            Icons.phone,
            business.phone.isEmpty
                ? 'Phone not available'
                : business.phone,
          ),

          infoTile(
            Icons.access_time,
            'Business hours available in profile',
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
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: const Text('Customer Review'),
              subtitle: const Text(
                'Great service and friendly staff.',
              ),
              trailing: Text(
                '⭐ ${business.rating.toStringAsFixed(1)}',
              ),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: () {
              showMessage(
                context,
                'Review form will open here',
              );
            },
            icon: const Icon(Icons.rate_review),
            label: const Text('Write a Review'),
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
          tooltip: title,
        ),
        const SizedBox(height: 4),
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

class CategoryPage extends StatelessWidget {
  final String title;

  const CategoryPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Business>>(
        future: searchCategory(title),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load businesses.',
                style: const TextStyle(fontSize: 17),
              ),
            );
          }

          final results = snapshot.data ?? [];

          if (results.isEmpty) {
            return const Center(
              child: Text(
                'No businesses found.',
                style: TextStyle(fontSize: 17),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return BusinessCard(
                business: results[index],
              );
            },
          );
        },
      ),
    );
  }
}

Future<List<Business>> searchCategory(String category) async {
  const apiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
  );

  if (apiKey.isEmpty) {
    return [];
  }

  final response = await http.post(
    Uri.parse(
      'https://places.googleapis.com/v1/places:searchText',
    ),
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          'places.displayName,places.formattedAddress,places.primaryType,places.rating,places.nationalPhoneNumber,places.id',
    },
    body: jsonEncode({
      'textQuery': category,
      'pageSize': 20,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Places API error: ${response.statusCode}',
    );
  }

  final data = jsonDecode(response.body);
  final places = data['places'] as List? ?? [];

  return places.map<Business>((place) {
    final displayName = place['displayName'];

    final name = displayName is Map
        ? (displayName['text'] ?? 'Unknown Business').toString()
        : 'Unknown Business';

    final address =
        place['formattedAddress']?.toString() ??
            'Location unavailable';

    final primaryType =
        place['primaryType']?.toString() ??
            'Business';

    final phone =
        place['nationalPhoneNumber']?.toString() ?? '';

    final ratingValue = place['rating'];

    final rating = ratingValue is num
        ? ratingValue.toDouble()
        : 0.0;

    return Business(
      name: name,
      category: primaryType,
      location: address,
      phone: phone,
      rating: rating,
      icon: Icons.business,
    );
  }).toList();
}

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
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final hoursController = TextEditingController();
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

  void submitBusiness() {
    if (nameController.text.trim().isEmpty ||
        categoryController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      showMessage(
        context,
        'Please fill all required fields',
      );
      return;
    }

    showMessage(
      context,
      'Business submitted successfully',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Business'),
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
            keyboardType: TextInputType.phone,
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

          OutlinedButton.icon(
            onPressed: () {
              showMessage(
                context,
                'Photo picker will open here',
              );
            },
            icon: const Icon(Icons.photo),
            label: const Text('Add Photos'),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: submitBusiness,
              child: const Text(
                'Submit Business',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget field(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
        'Please enter email and password',
      );
      return;
    }

    showMessage(
      context,
      'Login successful',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.account_circle,
            size: 100,
          ),

          const SizedBox(height: 20),

          const Text(
            'Welcome Back',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: login,
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 10),

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
              'Create New Account',
            ),
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

class _SignupPageState
    extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
        'Please fill all fields',
      );
      return;
    }

    showMessage(
      context,
      'Account created successfully',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.person_add,
            size: 90,
          ),

          const SizedBox(height: 20),

          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: signup,
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsPage
    extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showMessage(
  BuildContext context,
  String message,
) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
