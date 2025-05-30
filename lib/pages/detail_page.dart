import 'package:flutter/material.dart';
import '../widgets/navbar.dart'; // Import the NavBar widget
import '../theme/colors.dart'; // Import AppColors
import '../services/api_service.dart'; // Import ApiService

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> bodyData; // Données du corps céleste

  const DetailPage({super.key, required this.bodyData});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String typeName = 'Inconnu'; // Nom du type de corps céleste, initialisé à 'Inconnu'

  @override
  void initState() {
    super.initState();
    _fetchTypeName();
  }

  Future<void> _fetchTypeName() async {
    final typeUrl = widget.bodyData['type'];
    if (typeUrl != null) {
      final fetchedTypeName = await ApiService.fetchCelestialBodyTypeName(typeUrl);
      setState(() {
        typeName = fetchedTypeName;
      });
      print('Correct');
    }
    else {
      print('Nul');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors _colors = AppColors();

    // Récupère le nom de l'image depuis image_url ou imageUrl
    final imageName = widget.bodyData['image_url'] ?? widget.bodyData['imageUrl'];
    final imageUrl = (imageName != null && imageName.toString().isNotEmpty)
        ? 'https://std33.beaupeyrat.com/uploads/photos/$imageName'
        : null;

    return Scaffold(
      backgroundColor: _colors.backgroundColor,
      appBar: AppBar(
        title: Text(widget.bodyData['name'] ?? 'Corps céleste'),
        backgroundColor: _colors.cardColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: _colors.cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: imageUrl != null
                      ? ClipOval(
                          child: Image.network(
                            imageUrl,
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.public, size: 100, color: Colors.grey),
                          ),
                        )
                      : const Icon(Icons.public, size: 100, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                widget.bodyData['name'] ?? 'Nom du corps céleste',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _colors.textColorWhite,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.bodyData['description'] ?? 'Description du corps céleste...',
                style: TextStyle(
                  fontSize: 16,
                  color: _colors.textColorWhite.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Type : $typeName',
                style: TextStyle(
                  fontSize: 16,
                  color: _colors.textColorWhite.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masse : ${widget.bodyData['mass'] ?? 'Inconnue'} kg',
                style: TextStyle(
                  fontSize: 16,
                  color: _colors.textColorWhite.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Diamètre : ${widget.bodyData['radius'] ?? 'Inconnu'} km',
                style: TextStyle(
                  fontSize: 16,
                  color: _colors.textColorWhite.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Distance par rapport à la Terre : ${widget.bodyData['distance_from_earth'] ?? 'Inconnue'} km',
                style: TextStyle(
                  fontSize: 16,
                  color: _colors.textColorWhite.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Température : ${widget.bodyData['temperature'] ?? 'Inconnue'} K',
                style: TextStyle(
                  fontSize: 16,
                  color: _colors.textColorWhite.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 0, // À adapter selon la navigation
        onTap: (index) {
          // Gérer la navigation si besoin
        },
      ),
    );
  }
}