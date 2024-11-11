import 'package:flutter/material.dart';
import 'package:untitledflutter/horseScreen.dart';
import 'overviewScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.pink,
        appBarTheme: const AppBarTheme(
          color: Colors.pink,
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.brown,
        ).copyWith(
          secondary: Colors.amber,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

//screen for horses in the stable (2nd button)


//screen for horses in the stable (2nd button)
// class HorseScreen extends StatelessWidget {
//   const HorseScreen();
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: Text('horses screen')),
//     );
//   }
// }

//screen for horses in the stable (2nd button)
class MatingScreen extends StatelessWidget {
  const MatingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('mating screen')),
    );
  }
}

//screen for horses in the stable (2nd button)
class ShopScreen extends StatelessWidget {
  const ShopScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('shop screen')),
    );
  }
}

//screen for horses in the stable (2nd button)
class CoinScreen extends StatelessWidget {
  const CoinScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('coin screen')),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedScreen = 0;
  String message = 'Hello, Flutter!';
  int counter = 0;
  String teamName = "Turbo konici wroom"; // Default title
  Color teamColor = Colors.pink; // Default color

  void _changeMessage() {
    setState(() {
      message = message == 'HEYY CLICK ON SOME BUTTONS'
          ? 'ja te sezeru ty svine'
          : 'mnam mnam jsi sezran';
    });
  }

  void _incrementCounter() {
    setState(() {
      counter++;
    });
  }

  final List<Widget> _screens = [
    OverviewScreen(),
    Horsescreen(),
    MatingScreen(),
    ShopScreen(),
    CoinScreen(),
  ];

  void _openFullScreenMenu() {
    String teamname = "swag";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Menu Header with Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vyberte stáj',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context); // Closes the modal
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Grid of Colored Boxes
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMenuItem(teamname, Colors.pink),
                      _buildMenuItem("Tým ubrouscii", Colors.green),
                      _buildMenuItem("Tým kočičky", Colors.purple),
                      _buildMenuItem("Tým žereme šutry", Colors.blue),
                      _buildMenuItem("Tým ligma", Colors.deepOrange),
                      _buildMenuItem("+", Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to create a menu item with a fading color and text
  Widget _buildMenuItem(String text, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          teamName = text;
          teamColor = color;
        });
        Navigator.pop(context); // Close the bottom sheet after selection
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: teamColor, // Uses the color set by menu selection
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomButton('assets/home.png', 0),
          _buildDivider(),
          _buildBottomButton('assets/horse.png', 1),
          _buildDivider(),
          _buildBottomButton('assets/heart.png', 2),
          _buildDivider(),
          _buildBottomButton('assets/shop.png', 3),
          _buildDivider(),
          _buildBottomButton('assets/coins.png', 4),
        ],
      ),
    );
  }

// Helper method to create a vertical divider
  Widget _buildDivider() {
    return Container(
      width: 2, // Adjust width to control divider thickness
      height: 80, // Height to match icon size
      color:
          Colors.black.withOpacity(0.5), // Adjust color and opacity as needed
    );
  }

  // Helper method to create a bottom button with an icon and action
  Widget _buildBottomButton(String imagePath, int screen) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedScreen = screen;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Image.asset(
          imagePath,
          width: 42,
          height: 50,
          color: Colors.white,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.image_not_supported,
                color: Colors.red, size: 30); // Placeholder icon
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(teamName),
        backgroundColor: teamColor,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: _openFullScreenMenu,
        ),
      ),
      body: IndexedStack(
        index:
            selectedScreen, // Ensure this is defined somewhere, like in your state
        children: [
          ..._screens, // Your screen list

          // Additional screen that contains the message and counter
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _changeMessage,
                  child: const Text('Change Message'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Counter: $counter',
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: _incrementCounter,
                  child: const Text('Increment Counter'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(), // Bottom navigation bar
    );
  }
}
