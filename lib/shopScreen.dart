import 'package:flutter/material.dart';
import 'package:untitledflutter/api_stuff.dart';

class shopScreen extends StatefulWidget {
  final Function(int) onResourcesAdded;
  final Function(int) onCoinsSpent;
  final Group? group;

  const shopScreen({
    super.key,
    required this.onResourcesAdded,
    required this.onCoinsSpent,
    required this.group,
  });

  @override
  _shopScreenState createState() => _shopScreenState();
}

class _shopScreenState extends State<shopScreen> {
  Future<void> fetchStandingsData() async {
    if (widget.group == null) {
      throw Exception("Group is null");
    }
    standing = await fetchStandings(widget.group!.id);
  }

  int resourceAmount = 0;
  int resourcePrice = 0;
  List<Standing> standing = [];

  @override
  void initState() {
    super.initState();
    fetchStandingsData();
  }

  void _incrementResources1() {
    setState(() {
      resourceAmount += 1;
      resourcePrice += 3;
    });
  }

  void _decrementResources1() {
    setState(() {
      if (resourceAmount >= 1) {
        resourceAmount -= 1;
        resourcePrice -= 3;
      }
    });
  }

  void _incrementResources5() {
    setState(() {
      resourceAmount += 5;
      resourcePrice += 15;
    });
  }

  void _decrementResources5() {
    setState(() {
      if (resourceAmount >= 5) {
        resourceAmount -= 5;
        resourcePrice -= 15;
      }
    });
  }

  void resetResources() {
    setState(() {
      resourceAmount = 0;
      resourcePrice = 0;
    });
  }

  Widget buildResourceRow({
    required VoidCallback onDecrementPressed,
    required VoidCallback onIncrementPressed,
    int value = 10,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Decrease selected resource quantity.
        ElevatedButton(
          onPressed: onDecrementPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: Text(
            '-',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 40),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 40),
        // Increase selected resource quantity.
        ElevatedButton(
          onPressed: onIncrementPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: Text(
            '+',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddHorseDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedGender = 'muž';
    int finalPrice = 20;
    int finalLevel = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Přidat koně'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Jméno koně',
                      hintText: 'Zadejte jméno',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Pohlaví'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text('Muž'),
                        selected: selectedGender == 'muž',
                        onSelected: (bool selected) {
                          setState(() {
                            selectedGender = selected ? 'muž' : selectedGender;
                          });
                        },
                      ),
                      SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Žena'),
                        selected: selectedGender == 'žena',
                        onSelected: (bool selected) {
                          setState(() {
                            selectedGender = selected ? 'žena' : selectedGender;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('Level koně'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        int level = index + 1;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text('$level'),
                            selected: finalLevel == level,
                            onSelected: (bool selected) {
                              setState(() {
                                finalLevel = selected ? level : finalLevel;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Cena koně'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        int price = (index) * 20;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text('$price'),
                            selected: finalPrice == price,
                            onSelected: (bool selected) {
                              setState(() {
                                finalPrice = selected ? price : finalPrice;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Prosím zadejte jméno')),
                  );
                  return;
                }

                // Add a horse definition to the shop catalogue.
                bool success = await addHorseToShop(
                  finalLevel,
                  nameController.text,
                  finalPrice,
                  selectedGender,
                );

                if (success) {
                  setState(() {
                    fetchShopItems();
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add horse')),
                  );
                }
              },
              child: Text('Add Horse'),
            ),
          ],
        );
      },
    );
  }

  void _showSelectStandingDialog(
      BuildContext context, int groupID, int itemID, List<Standing> standing) {
    Standing? selectedStanding;
    List<Standing> availableStandings = standing.where((s) => s.horse == null).toList();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vyberte postavení'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: availableStandings.map((standing) {
                  return ListTile(
                    title: Text('${standing.id} max kúň lvl ${standing.max_level_of_horse}'),
                    leading: Radio<Standing>(
                      value: standing,
                      groupValue: selectedStanding,
                      onChanged: (Standing? value) {
                        setState(() {
                          selectedStanding = value;
                        });
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStanding != null) {
                  bool success = await buyHorseFromShop(
                    groupID,
                    selectedStanding!.id,
                    itemID,
                  );

                  if (success) {
                    setState(() {
                      fetchShopItems();
                    });
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add horse')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Prosím vyberte postavení')),
                  );
                }
              },
              child: Text('Buy'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    int groupID = widget.group?.id ?? 0;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen background image for the shop UI.
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.5),
                  BlendMode.lighten,
                ),
              ),
            ),
          ),

          // Resource purchase panel.
          Positioned(
            left: 0,
            right: 0,
            top: screenHeight * 0.02,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Množství jídla/vody',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '$resourceAmount',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 40),
                      Column(
                        children: [
                          Text(
                            'Cena',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '$resourcePrice',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          buildResourceRow(
                            onDecrementPressed: _decrementResources1,
                            onIncrementPressed: _incrementResources1,
                            value: 1,
                          ),
                          SizedBox(height: 20),
                          buildResourceRow(
                            onDecrementPressed: _decrementResources5,
                            onIncrementPressed: _incrementResources5,
                            value: 5,
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (widget.group != null && widget.group!.coins < resourcePrice) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Nemáte peníze na koupi zdrojů'),
                              ),
                            );
                          } else {
                            final success = await buyResources(groupID, resourceAmount);
                            if (success) {
                              setState(() {
                                widget.onResourcesAdded(resourceAmount);
                                widget.onCoinsSpent(resourcePrice);
                              });
                              resetResources();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Nákup se nezdařil'),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 13),
                        ),
                        child: Text(
                          'Koupit',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Shop inventory and horse list.
          Positioned(
            top: screenHeight * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: FutureBuilder<List<ShopItem>>(
              future: fetchShopItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<dynamic> combinedItems = [];
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    combinedItems.addAll(snapshot.data!);
                  }
                  combinedItems.add('AddHorseItem');

                  return ListView.builder(
                    itemCount: combinedItems.length,
                    itemBuilder: (context, index) {
                      if (combinedItems[index] == 'AddHorseItem') {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: screenWidth - 32,
                            height: screenHeight * 0.2,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: screenWidth * 0.4,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/stable.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: ElevatedButton(
                                      onPressed: () => _showAddHorseDialog(context),
                                      child: Text('Add Horse'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      ShopItem item = combinedItems[index];
                      bool hasHorse = item.name.isNotEmpty;
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: screenWidth - 32,
                          height: screenHeight * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: screenWidth * 0.4,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(hasHorse
                                        ? 'assets/stefan.jpeg'
                                        : 'assets/empty_stable.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: hasHorse
                                        ? [
                                            Text(
                                              'Jméno: ${item.name}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Úroveň: ${item.level}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Pohlaví: ${item.gender}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Cena: ${item.price_buy}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => _showSelectStandingDialog(
                                                context,
                                                groupID,
                                                item.id,
                                                standing,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor: Colors.white,
                                              ),
                                              child: Text('Koupit koně'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                bool success = await deleteHorseFromShop(item.id);
                                                if (success) {
                                                  setState(() {
                                                    fetchShopItems();
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Kůň úspěšně smazán')),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Nepodařilo se smazat koně')),
                                                  );
                                                }
                                              },
                                              style: ButtonStyle(
                                                backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                                                foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                                              ),
                                              child: Text('Smazat koně'),
                                            ),
                                          ]
                                        : [
                                            Text(
                                              'No horse available',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

