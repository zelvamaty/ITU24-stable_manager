import 'package:flutter/material.dart';
import 'package:untitledflutter/horseScreen.dart';
import 'overviewScreen.dart';
import 'matingScreen.dart';
import 'shopScreen.dart';
import 'moneyScreen.dart';
import 'api_stuff.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

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
// class MatingScreen extends StatelessWidget {
//   const MatingScreen();
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: Text('mating screen')),
//     );
//   }
// }
//
// //screen for horses in the stable (2nd button)
// class ShopScreen extends StatelessWidget {
//   const ShopScreen();
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: Text('shop screen')),
//     );
//   }
// }
//
// //screen for horses in the stable (2nd button)
// class CoinScreen extends StatelessWidget {
//   const CoinScreen();
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: Text('coin screen')),
//     );
//   }
// }


class _HomeScreenState extends State<HomeScreen> {
  int selectedScreen = 0;
  String message = 'Hello, Flutter!';
  int counter = 0;
  String teamName = "Turbo konici wroom"; // Default title
  Color teamColor = Colors.pink; // Default color
  Group? group;
  _HomeScreenState({this.group});

  void initState() {
    super.initState();
    _openFullScreenMenu();
  }

// Update and show the menu
  void _openFullScreenMenu() async {
    List<Group> groups = [];
    String? errorMessage;

    try {
      groups = await fetchGroups(); // Attempt to fetch groups
    } catch (e) {
      errorMessage = 'Chyba při načítání dat: ${e.toString()}';
    }
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vyberte stáj',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                ElevatedButton(
                  onPressed: () => _showAddGroupDialog(),
                  child: Text('Přidat skupinu'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: groups.length,
                    itemBuilder: (BuildContext context, int index) {
                      Group group = groups[index];
                      return _buildMenuItem(group);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Show dialog to add a new group
  void _showAddGroupDialog() {
    TextEditingController nameController = TextEditingController();
    double red = 0, green = 0, blue = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Color selectedColor = Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1);

            return AlertDialog(
              title: Text('Přidat skupinu'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Název skupiny'),
                  ),
                  const SizedBox(height: 8),
                  // RGB Sliders
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Červená: ${red.toInt()}'),
                      Slider(
                        value: red,
                        min: 0,
                        max: 255,
                        onChanged: (value) {
                          setState(() {
                            red = value;
                          });
                        },
                      ),
                      Text('Zelená: ${green.toInt()}'),
                      Slider(
                        value: green,
                        min: 0,
                        max: 255,
                        onChanged: (value) {
                          setState(() {
                            green = value;
                          });
                        },
                      ),
                      Text('Modrá: ${blue.toInt()}'),
                      Slider(
                        value: blue,
                        min: 0,
                        max: 255,
                        onChanged: (value) {
                          setState(() {
                            blue = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Display selected color
                      Container(
                        width: double.infinity,
                        height: 28,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Zrušit'),
                ),
                TextButton(
                  onPressed: () async {
                    String name = nameController.text;
                    String colorHex = '#${selectedColor.value.toRadixString(16).substring(2)}';

                    if (name.isNotEmpty) {
                      await addGroup(colorHex, name);
                      Navigator.pop(context);
                      Navigator.of(context).pop();
                      _openFullScreenMenu(); // Refresh the menu to show new group
                    }
                  },
                  child: Text('Přidat'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  // Helper method to create a menu item with a fading color and text
  Widget _buildMenuItem(Group group) {
    final color = Color(int.parse(group.color.replaceFirst('#', '0xff')));
    return GestureDetector(
      onTap: () {
        setState(() {
          teamName = group.name;
          teamColor = color;
          this.group = group;
        });
        Navigator.pop(context); // Close the bottom sheet after selection


      },
      child: Stack(  // Wrap in Stack to overlay the delete button
        children: [
          // boxes with the name of the group
          Container(
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
                group.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1.5, 1.5),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),


          // Delete button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () async {
                // Show confirmation dialog
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Smazat ${group.name}?'),
                      content: Text('Opravdu chcete smazat tuto skupinu?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Ne'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Ano'),
                        ),
                      ],
                    );
                  },
                );

                // If confirmed, delete the group
                if (confirm == true) {
                  await deleteGroup(group.id);
                  Navigator.pop(context); //
                  _openFullScreenMenu(); // Refresh the menu
                  // setState(() {
                  //   groups.remove(group);
                  // });
                }
              },
              //shadow for the delete button
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create the bottom navigation bar
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

// Helper method to create a vertical divider between the buttons
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
    bool isSelected = selectedScreen == screen;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedScreen = screen;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        //shadow around the icon
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.black.withOpacity(0.01) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 19,
                blurRadius: 8,
                offset: Offset(0, 5),
              ),
            ] : [],
          ),
          // shadow around the icon and adding the icon itself
          child: Container(
            decoration: BoxDecoration(
              boxShadow: isSelected  ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Image.asset(
              imagePath,
              width: 42,
              height: 50,
              color: Colors.white,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported,
                  color: Colors.red,
                  size: 30,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      OverviewScreen(
          group: group,
          onCoinsLost: (int coins) {
            setState(() {
              group?.coins -= coins;
            });
          }
      ),
      Horsescreen(
        group: group,
        onResourcesSpent: (int resources) {
          setState(() {
            group?.water -= resources;
            group?.wheat -= resources;
          });
        },

      ),
      matingScreen(
        group: group,
      ),
      shopScreen(
        group: group,
        onCoinsSpent: (int coins) {
          setState(() {
            group?.coins -= coins;
          });
        },
        onResourcesAdded: (int resources) {
          setState(() {
            group?.water += resources;
            group?.wheat += resources;
          });
        },
      ),
      moneyScreen(
        group: group,
        onCoinsAdded: (int coins) {
        setState(() {
          group?.coins += coins;
        });
      }),
    ];

    return Scaffold(
      // Top of the screen bar
      appBar: AppBar(
        title: Text(teamName),
        backgroundColor: teamColor,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: _openFullScreenMenu,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(50),
              ),

              // coins icon and its number
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.yellow[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${group?.coins ?? 0}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.fastfood,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${group?.water ?? 0}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index:
            selectedScreen, //
        children: [
          ..._screens, // Your screen list
        ],
      ),
      bottomNavigationBar: _buildBottomBar(), // Bottom navigation bar
    );
  }
}
