import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BottomNavigationLayout(
        initialIndex: 0,
        onTabTapped: (index) {},
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImageSearchScreen extends StatefulWidget {
  @override
  _ImageSearchScreenState createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {


  String apiKey = "COLOQUE SUA CHAVE API AQUI"; 


  
  TextEditingController searchController = TextEditingController();
  List<String> imageUrls = [];

  Future<void> searchImages(String query) async {
    final response = await http.get(
      Uri.parse(
          "https://api.unsplash.com/search/photos?query=$query&client_id=$apiKey"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<String> imageUrls = [];
      for (var item in data["results"]) {
        imageUrls.add(item["urls"]["regular"]);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(imageUrls: imageUrls),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pesquisa de Imagens com API do Unsplash"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ImageSearchDelegate(searchImages),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(230, 89, 122, 192),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'Unisapiens-principal.png',
              width: 200,
            ),
            Image.asset(
              'assets/unsplash-logo.png',
              width: 300,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Pesquisa de Imagens com API do Unsplash',
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}

class ImageSearchDelegate extends SearchDelegate<String> {
  final Function(String) searchFunction;

  ImageSearchDelegate(this.searchFunction);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    searchFunction(query);
    close(context, query);
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView();
  }
}

class ResultPage extends StatefulWidget {
  final List<String> imageUrls;

  ResultPage({required this.imageUrls});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<String> favorites = [];

  void addToFavorites(String imageUrl) {
    setState(() {
      favorites.add(imageUrl);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Imagem salva nos favoritos'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados da Pesquisa'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = widget.imageUrls[index];
          return GestureDetector(
            onTap: () {
              addToFavorites(imageUrl);
            },
            child: Image.network(imageUrl),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FavoritesPage(favorites: favorites),
            ),
          );
        },
        child: Icon(Icons.favorite),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final List<String> favorites;

  FavoritesPage({required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Image.network(favorites[index]),
          );
        },
      ),
    );
  }
}

class BottomNavigationLayout extends StatefulWidget {
  final int initialIndex;
  final Function(int) onTabTapped;

  BottomNavigationLayout(
      {required this.initialIndex, required this.onTabTapped});

  @override
  _BottomNavigationLayoutState createState() => _BottomNavigationLayoutState();
}

class _BottomNavigationLayoutState extends State<BottomNavigationLayout> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _handleItemTapped(int index) {
    widget.onTabTapped(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? ImageSearchScreen()
          : FavoritesPage(favorites: []),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _handleItemTapped,
      ),
    );
  }
}
