// ============================================================
// ACCOUNT
// ============================================================

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    if (!AppData.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupPage(),
                      ),
                    );

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = AppData.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
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
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 38,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ??
                            AppData.currentUserName ??
                            'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user?.email ??
                            AppData.currentUserEmail ??
                            '',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          accountTile(
            context,
            Icons.person_outline,
            'Profile',
            'View and edit your profile',
            const ProfilePage(),
          ),
          accountTile(
            context,
            Icons.business,
            'My Business',
            'Manage your listed businesses',
            const MyBusinessPage(),
          ),
          accountTile(
            context,
            Icons.workspace_premium,
            'Premium',
            'Manage premium business requests',
            const PremiumPage(),
          ),
          accountTile(
            context,
            Icons.admin_panel_settings,
            'Admin Panel',
            'Business approval management',
            const AdminPanelPage(),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: () {
              AppData.logout();

              setState(() {});

              showMessage(
                context,
                'Logged out successfully.',
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget accountTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
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
// LOGIN
// ============================================================
