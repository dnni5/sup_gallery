import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(const GalleryApp());
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GalleryScreen(),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _selectedTabIndex = 0;
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    String url =
        'https://api.giphy.com/v1/gifs/trending?api_key=AA9FajAUV4LqBChNjEVki0ttJaRbWQUI&limit=15&offset=0&rating=g&bundle=messaging_non_clips';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> fetchedImages = [];
        for (var image in data['data']) {
          fetchedImages.add(image['images']['original']['url']);
        }
        setState(() {
          images = fetchedImages;
        });
      } else {
        debugPrint('Failed to fetch images');
      }
    } catch (error) {
      debugPrint('Error: $error');
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  Widget _buildNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedTabIndex,
      onTap: _onTabTapped,
      elevation: 8.0, // Add shadow
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black, // Change icon color to black
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.image),
          label: 'Imágenes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_album),
          label: 'Álbumes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Historias',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Menú',
        ),
      ],
    );
  }

  Widget _buildImagesGrid() {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 2,
      itemCount: images.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageScreen(imageUrl: images[index]),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
      staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        centerTitle: true,
        title: const Align(
          alignment: Alignment.topCenter,
          child: Text(
            'DS Gallery',
            style: TextStyle(fontSize: 24.0),
          ),
        ),
      ),
      body: _selectedTabIndex == 0 ? _buildImagesGrid() : Container(),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }
}

class ImageScreen extends StatelessWidget {
  final String imageUrl;

  const ImageScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image'),
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
