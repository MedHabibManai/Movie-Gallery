import 'package:flutter/material.dart';
import 'package:testlearn/Models/list_item.dart';
import 'package:testlearn/Widgets/movie_grid.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<ListItem> items = [
    ListItem(text: "Most Popular"),
    ListItem(text: "Top Rated"),
    ListItem(text: "Upcoming", padding: const EdgeInsets.only(right: 0)),
    ListItem(text: "Favorite Movies"),
    // Add more items as needed
  ];

  bool isAtEnd = false; // Track if the scroll is at the end

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        // Update the `isAtEnd` state based on the scroll position
        isAtEnd = _scrollController.offset >= _scrollController.position.maxScrollExtent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = MediaQuery.of(context).size.width - 80; // Width of each item minus padding

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Movie Gallerie"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 100,
            right: 100,
            child: Image.asset('assets/reel-icon-removebg-preview.png'),
          ),
          // Search Bar
          Positioned(
            top: 200,
            left: 50,
            right: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search movies...",
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Colors.green,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Colors.green,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Colors.green,
                      width: 2.0,
                    ),
                  ),
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieGrid(
                          category: "search",
                          query: query,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          Positioned(
            top: 270, // Adjusted position to be below the search bar
            left: 170,
            right: 170,
            child: ElevatedButton(
              onPressed: () {
                String query = _searchController.text.trim();
                if (query.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieGrid(
                        category: "search",
                        query: query,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded edges
                ),
              ),
              child: const Text(
                "GO",
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
            ),
          ),

          // Horizontal ListView with items
          Positioned(
            top: 500,
            left: 5,
            right: 5,
            child: SizedBox(
              height: 300,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: itemWidth, // Slightly narrower than screen width
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0), // Rounded corners
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  switch (index) {
                                    case 0:
                                      return const MovieGrid(category: "popular");
                                    case 1:
                                      return const MovieGrid(category: "top_rated");
                                    case 2:
                                      return const MovieGrid(category: "upcoming");
                                    case 3:
                                      return const MovieGrid(category: "favorites"); // Handle Favorite Movies
                                    default:
                                      return HomePage(); // Fallback in case something goes wrong
                                  }
                                },
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  items[index].text,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20),
                                Icon(
                                  index == 0
                                      ? Icons.emoji_events // Trophy
                                      : index == 1
                                      ? Icons.star // Star
                                      : index == 2
                                      ? Icons.calendar_today // Calendar
                                      : Icons.favorite, // Heart
                                  color: index == 0
                                      ? Colors.amber // Gold for Trophy
                                      : index == 1
                                      ? Colors.yellow // Yellow for Star
                                      : index == 2
                                      ? Colors.blue // Blue for Calendar
                                      : Colors.red, // Red for Heart
                                  size: 150, // Bigger size
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Navigation button to scroll to the next item or back to the beginning
          Positioned(
            bottom: 30, // Adjust position as needed
            right: 10,  // Adjust position as needed
            child: FloatingActionButton(
              onPressed: () {
                if (_scrollController.hasClients) {
                  if (isAtEnd) {
                    // Scroll back to the beginning
                    _scrollController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    // Scroll to the next item
                    double currentScroll = _scrollController.offset;
                    double targetScroll = (currentScroll / itemWidth).round() * itemWidth + itemWidth;

                    if (targetScroll <= _scrollController.position.maxScrollExtent) {
                      _scrollController.animateTo(
                        targetScroll,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                }
              },
              child: AnimatedRotation(
                turns: isAtEnd ? 0.5 : 0.0, // Rotate the icon 180 degrees when at the end
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.arrow_forward),
              ),
              backgroundColor: isAtEnd ? Colors.red : Colors.green, // Change color if needed
            ),
          ),
        ],
      ),
    );
  }
}
