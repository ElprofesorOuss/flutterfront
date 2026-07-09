import 'package:flutter/material.dart';


class PhotoDetailScreen extends StatelessWidget {
  final String photoId;

  const PhotoDetailScreen({super.key, required this.photoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Photo $photoId'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 280,
              height: 380,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text('Photo $photoId', style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 4),
                  const Text('Simulation médicale', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Comparaison avant / après', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Container(width: 80, height: 100, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.image_outlined, color: Colors.white24)),
                            const SizedBox(height: 4),
                            const Text('Avant', style: TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                        const Icon(Icons.arrow_forward, color: Colors.white38),
                        Column(
                          children: [
                            Container(width: 80, height: 100, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.image_outlined, color: Colors.white24)),
                            const SizedBox(height: 4),
                            const Text('Après', style: TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}