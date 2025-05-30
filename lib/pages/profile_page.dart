import 'package:flutter/material.dart';
import '../services/token_service.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widgets/navbar.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<Map<String, dynamic>> _userData;
  late Future<List<Map<String, dynamic>>> _favoritesData;
  final AppColors colors = AppColors();

  @override
  void initState() {
    super.initState();
    _userData = fetchUserData();
    _favoritesData = fetchFavorites();
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    final String? token = await TokenService.getToken();
    if (token == null) {
      throw Exception('Token non disponible');
    }
    final userDetails = await ApiService.fetchUserDetails(token);
    if (userDetails == null) {
      throw Exception('User details not found');
    }
    return userDetails;
  }

  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    final String? token = await TokenService.getToken();
    if (token == null) {
      throw Exception('Token non disponible');
    }
    final userDetails = await ApiService.fetchUserDetails(token);
    if (userDetails == null) {
      throw Exception('User details not found');
    }
    final favoritesIris = userDetails['favorites'] ?? [];
    final favorites = <Map<String, dynamic>>[];
    for (final iri in favoritesIris) {
      final fav = await ApiService.fetchFavoriteByIri(iri, token);
      if (fav != null) favorites.add(fav);
    }
    return favorites;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        title: const Text('Profil utilisateur'),
        backgroundColor: colors.cardColor,
      ),
      body: Column(
        children: [
          // Boîte contenant les informations utilisateur
          FutureBuilder<Map<String, dynamic>>(
            future: _userData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur : ${snapshot.error}'));
              } else {
                final user = snapshot.data!;

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colors.cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user['username'] ?? 'Nom d\'utilisateur',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.textColor,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user['email'] ?? 'Email non disponible',
                        style: TextStyle(
                          color: colors.textColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          // Titre pour la section des favoris
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mes favoris',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.textColor,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _favoritesData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                } else {
                  final favorites = snapshot.data ?? [];

                  if (favorites.isEmpty) {
                    return const Center(child: Text('Aucun favori trouvé.'));
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      itemCount: favorites.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final favorite = favorites[index];
                        final imageName = favorite['image_url'] ?? favorite['imageUrl'];
                        final imageUrl = (imageName != null && imageName.toString().isNotEmpty)
                            ? 'https://std33.beaupeyrat.com/uploads/photos/$imageName'
                            : null;

                        return Card(
                          color: colors.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.only(top: 16, bottom: 8),
                                decoration: BoxDecoration(
                                  color: colors.backgroundColor,
                                  shape: BoxShape.circle,
                                ),
                                child: imageUrl != null
                                    ? ClipOval(
                                        child: Image.network(
                                          imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.public, size: 40, color: Colors.grey),
                                        ),
                                      )
                                    : const Icon(Icons.public, size: 40, color: Colors.grey),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  favorite['name'] ?? 'Corps céleste inconnu',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colors.textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 2,
        onTap: (index) {
        },
      ),
    );
  }
}