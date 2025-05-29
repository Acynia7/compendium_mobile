import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/navbar.dart';
import 'detail_page.dart';
import '../services/api_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: RefreshIndicator(
        color: colors.refreshIndicatorColor,
        onRefresh: () async {
        },
        child: const CelestialBodyList(),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }
}

class CelestialBodyList extends StatefulWidget {
  const CelestialBodyList({super.key});

  @override
  State<CelestialBodyList> createState() => _CelestialBodyListState();
}

class _CelestialBodyListState extends State<CelestialBodyList> {
  late Future<List<Map<String, dynamic>>> _futureBodies;

  @override
  void initState() {
    super.initState();
    _futureBodies = ApiService.fetchCelestialBodies();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureBodies = ApiService.fetchCelestialBodies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureBodies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun corps céleste trouvé.'));
        }

        final bodies = snapshot.data!;
        return RefreshIndicator(
          color: colors.refreshIndicatorColor,
          onRefresh: _refresh,
          child: ListView.builder(
            itemCount: bodies.length,
            itemBuilder: (context, index) {
              final body = bodies[index];
              final imageName = body['image_url'];
              final imageUrl = 'https://std33.beaupeyrat.com/uploads/photos/$imageName';
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: (imageName != null && imageName.toString().isNotEmpty)
                      ? ClipOval(
                          child: Image.network(
                            imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.public, size: 40, color: Colors.grey),
                          ),
                        )
                      : const Icon(Icons.public, size: 40),
                  title: Text(body['name'] ?? 'Nom inconnu'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(bodyData: body),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}