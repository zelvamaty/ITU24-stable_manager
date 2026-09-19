import 'package:flutter/material.dart';
import 'package:untitledflutter/horseScreen.dart';
import 'overviewScreen.dart';
import 'matingScreen.dart';
import 'shopScreen.dart';
import 'moneyScreen.dart';
import 'api_stuff.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  int selectedScreen = 0;
  String teamName = "Turbo konici wroom";
  Color teamColor = Colors.pink;
  Group? group;

  @override
  void initState() {
    super.initState();
    _openFullScreenMenu();
  }

  // Fetch available groups and open the selection modal.
  void _openFullScreenMenu() async {
    List<Group> groups = [];

    try {
      groups = await fetchGroups();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba při načítání dat: ${e.toString()}')),
        );
      }
      return;
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
                        Navigator.pop(context);
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

  // Open the dialog for creating a new group.
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
                  // Adjust the RGB values to choose the group color.
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
                      // Preview the selected color.
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
                      _openFullScreenMenu();
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


  // Build a selectable card for a group from the modal list.
  Widget _buildMenuItem(Group group) {
    final color = Color(int.parse(group.color.replaceFirst('#', '0xff')));
    return GestureDetector(
      onTap: () {
        setState(() {
          teamName = group.name;
          teamColor = color;
          this.group = group;
        });
        Navigator.pop(context);
      },
      child: Stack(
        children: [
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


          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () async {
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

                if (confirm == true) {
                  await deleteGroup(group.id);
                  Navigator.pop(context);
                  _openFullScreenMenu();
                }
              },
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

  // Build the main bottom navigation bar.
  Widget _buildBottomBar() {
    return BottomAppBar(
      color: teamColor,
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

  // Add a subtle separator between bottom-bar icons.
  Widget _buildDivider() {
    return Container(
      width: 2,
      height: 80,
      color: Colors.black.withOpacity(0.5),
    );
  }

  // Build a single bottom-bar action button.
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
        index: selectedScreen,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}
