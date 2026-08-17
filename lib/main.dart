import 'package:flutter/material.dart';
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
  final IconData icon;

  const Business({
    required this.name,
    required this.category,
    required this.location,
    required this.phone,
    required this.rating,
    required this.icon,
  });
}

const businesses = [
  Business(
    name: 'City Electronics',
    category: 'Electronics',
    location: 'Saddar',
    phone: '+92 300 0000000',
    rating: 4.7,
    icon: Icons.electrical_services,
  ),
  Business(
    name: 'Quick Fix Mechanics',
    category: 'Mechanic',
    location: 'Commercial Market',
    phone: '+92 301 0000000',
    rating: 4.5,
    icon: Icons.car_repair,
  ),
  Business(
    name: 'Royal Restaurant',
    category: 'Restaurant',
    location: 'Main Market',
    phone: '+92 302 0000000',
    rating: 4.8,
    icon: Icons.restaurant,
  ),
  Business(
    name: 'Home Electrician',
    category: 'Electrician',
    location: 'Nearby',
    phone: '+92 303 0000000',
    rating: 4.6,
    icon: Icons.bolt,
  ),
];

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
          setState(() => currentIndex = index);
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
              colors: [Colors.blue, Colors.indigo],
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
                'Find trusted businesses and services near you.',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        TextField(
          readOnly: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            );
          },
          decoration: InputDecoration(
            hintText: 'Search businesses or services...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 25),
        const Text(
          'Categories',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 105,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              category(context, Icons.restaurant, 'Restaurants'),
              category(context, Icons.local_hospital, 'Doctors'),
              category(context, Icons.electrical_services, 'Electrician'),
              category(context, Icons.plumbing, 'Plumber'),
              category(context, Icons.car_repair, 'Mechanic'),
              category(context, Icons.store, 'Shops'),
            ],
          ),
        ),

        const SizedBox(height: 25),
        const Text(
          'Popular Businesses',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ...businesses.map(
          (business) => BusinessCard(
            business: business,
            isFavorite: favorites.contains(business),
            onFavorite: () => onFavorite(business),
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget category(BuildContext context, IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryPage(title: title),
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
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...businesses.map(
          (b) => BusinessCard(
            business: b,
            isFavorite: favorites.contains(b),
            onFavorite: () => onFavorite(b),
          ),
        ),
      ],
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search business or service...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...businesses.map((b) => BusinessCard(business: b)),
        ],
      ),
    );
  }
}

class NearbyTab extends StatelessWidget {
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
        const Text(
          'Businesses Near You',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Icon(Icons.map, size: 80, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 20),
        ...businesses.map(
          (b) => BusinessCard(
            business: b,
            isFavorite: favorites.contains(b),
            onFavorite: () => onFavorite(b),
          ),
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
        child: Text(
          'No favorite businesses yet.',
          style: TextStyle(fontSize: 17),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: favorites
          .map(
            (b) => BusinessCard(
              business: b,
              isFavorite: true,
              onFavorite: () => onFavorite(b),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          child: Icon(business.icon),
        ),
        title: Text(
          business.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${business.category}\n📍 ${business.location}\n⭐ ${business.rating}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: onFavorite,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BusinessDetailsPage(business: business),
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
    final uri = Uri.parse('tel:${business.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showMessage(context, 'Could not open phone dialer');
    }
  }

  Future<void> openWhatsApp(BuildContext context) async {
    final phone = business.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse(
      'https://wa.me/$phone?text=Hello%20${Uri.encodeComponent(business.name)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
            child: Icon(business.icon, size: 55),
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

          Text(
            business.category,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          Center(
            child: Text('⭐ ${business.rating}'),
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
                  showMessage(context, 'Report option selected');
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
            business.phone,
          ),

          infoTile(
            Icons.access_time,
            'Open today: 9:00 AM - 9:00 PM',
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

          const Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text('Customer Review'),
              subtitle: Text(
                'Great service and friendly staff.',
              ),
              trailing: Text('⭐ 5.0'),
            ),
          ),

          const SizedBox(height: 10),

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

  Widget infoTile(IconData icon, String text) {
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

  const CategoryPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final filtered = businesses.where(
      (b) => b.category.toLowerCase().contains(
            title.toLowerCase().replaceAll('s', ''),
          ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...filtered.map((b) => BusinessCard(business: b)),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text('No businesses found in this category.'),
              ),
            ),
        ],
      ),
    );
  }
}

class AddBusinessPage extends StatelessWidget {
  const AddBusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Your Business')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Business Information',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          field('Business Name', Icons.store),
          field('Category', Icons.category),
          field('Phone Number', Icons.phone),
          field('Location', Icons.location_on),
          field('Opening Hours', Icons.access_time),
          field('Description', Icons.description, maxLines: 4),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: () {
              showMessage(context, 'Photo picker will open here');
            },
            icon: const Icon(Icons.photo),
            label: const Text('Add Photos'),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              showMessage(context, 'Business submitted successfully');
            },
            child: const Text('Submit Business'),
          ),
        ],
      ),
    );
  }

  Widget field(String hint, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Sign Up')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.account_circle, size: 100),
          const SizedBox(height: 20),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              showMessage(context, 'Login system will be connected');
            },
            child: const Text('Login'),
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
            child: const Text('Create New Account'),
          ),
        ],
      ),
    );
  }
}

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              showMessage(context, 'Account creation system ready');
            },
            child: const Text('Sign Up'),
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
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(
        child: Text(
          'No new notifications',
          style: TextStyle(fontSize: 17),
        ),
      ),
    );
  }
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
