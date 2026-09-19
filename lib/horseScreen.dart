import 'package:flutter/material.dart';
import 'api_stuff.dart';

class Horsescreen extends StatefulWidget {
  const Horsescreen({super.key, required this.group, required this.onResourcesSpent});
  final Group? group;
  final Function(int) onResourcesSpent;

  @override
  _HorsescreenState createState() => _HorsescreenState();
}

class _HorsescreenState extends State<Horsescreen> {
  Future<List<Standing>> fetchStandingsData() async {
    if (widget.group == null) {
      throw Exception("Group is null");
    }
    return await fetchStandings(widget.group!.id);
  }

  // Open the dialog for creating a horse in the selected standing.
  void _showAddHorseDialog(BuildContext context, Standing standing) {
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
                      children: List.generate(standing.max_level_of_horse, (index) {
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
                      children: [0, 20, 40, 60, 80, 100].map((price) {
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
                      }).toList(),
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

                bool success = await insertHorse(
                  widget.group!.id,
                  standing.id,
                  finalLevel,
                  nameController.text,
                  finalPrice,
                  selectedGender,
                );

                if (success) {
                  setState(() {
                    fetchStandingsData();
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


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
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
          FutureBuilder<List<Standing>>(
            future: fetchStandingsData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No standings available'));
              } else {
                List<Standing> standings = snapshot.data!;
                return ListView.builder(
                  itemCount: standings.length,
                  itemBuilder: (context, index) {
                    Standing standing = standings[index];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: screenWidth - 32,
                        height: standing.horse != null ? screenHeight * 0.55 : screenHeight * 0.33,
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
                        child: Column(
                          children: [
                            Container(
                              height: screenHeight * 0.15,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: standing.horse != null
                                      ? AssetImage('assets/stefan.jpeg')
                                      : AssetImage('assets/empty_stable.jpg') as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    'Stání: ${standing.id}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),

                                  if (standing.horse != null) ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Úroveň stání: ${standing.level}/${standing.max_level_of_standing}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Text(
                                              'Cena zvýšení úrovně: ${standing.level_up_price}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Text(
                                              'Maximální úroveň koně: ${standing.max_level_of_horse}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            bool success = await levelUpStanding(widget.group!.id, standing.id);
                                            if (success) {
                                              setState(() {
                                                fetchStandingsData();
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Stání úspěšně vylepšeno')),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Nepodařilo se vylepšit stání')),
                                              );
                                            }
                                          },
                                          child: Text('Vylepšit stání'),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Jméno koně: ${standing.horse!.name}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Level: ${standing.horse!.level}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Pohlaví: ${standing.horse!.gender}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Cena nákupu: ${standing.horse!.price_buy}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Cena prodeje: ${standing.horse!.price_sell}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Jídlo za den: ${standing.horse!.food_eaten}/${standing.horse!.food_per_day}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Voda za den: ${standing.horse!.water_drunk}/${standing.horse?.water_per_day}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (widget.group != null && widget.group!.wheat < 6) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Nemáte dostatek potravin na nakrmení'),
                                                    ),
                                                  );
                                                }
                                                bool success = await feedHorse(widget.group!.id, standing.id, 6,6);
                                                if (success) {
                                                  setState(() {
                                                    widget.onResourcesSpent(6);
                                                    fetchStandingsData();
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Kůň úspěšně nakrmen')),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Nepodařilo se nakrmit koně')),
                                                  );
                                                }
                                              },
                                              style: ButtonStyle(
                                                foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                                              ),
                                              child: Text('Nakrmit'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                bool success = await levelUpHorse(widget.group!.id, standing.id, standing.horse!.id);
                                                if (success) {
                                                  setState(() {
                                                    fetchStandingsData();
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Kůň úspěšně vylepšen')),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Nepodařilo se vylepšit koně')),
                                                  );
                                                }
                                              },
                                              style: ButtonStyle(
                                                foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                                              ),
                                              child: Text('Trénovat'),
                                            ),
                                            SizedBox(height: 8), // Add some space between the buttons
                                            ElevatedButton(
                                              onPressed: () async {
                                                bool success = await releaseHorse(widget.group!.id, standing.id, standing.horse!.id);
                                                if (success) {
                                                  setState(() {
                                                    fetchStandingsData();
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Kůň úspěšně vypuštěn pryč')),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Nepodařilo se vypustit koně')),
                                                  );
                                                }
                                              },
                                              style: ButtonStyle(
                                                backgroundColor: WidgetStateProperty.all<Color>(Colors.redAccent),
                                                foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                                              ),
                                              child: Text('Vypustit'),
                                            ),
                                            SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: () async {
                                                bool success = await sellHorse(widget.group!.id, standing.id, standing.horse!.id);
                                                if (success) {
                                                  setState(() {
                                                    fetchStandingsData();
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Kůň úspěšně prodán')),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Nepodařilo se prodat koně')),
                                                  );
                                                }
                                              },
                                              style: ButtonStyle(
                                                backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                                                foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                                              ),
                                              child: Text(

                                                  'Prodat'
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),

                                  ] else ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Úroveň stání: ${standing.level}/${standing.max_level_of_standing}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Cena zvýšení úrovně: ${standing.level_up_price}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Maximální úroveň koně: ${standing.max_level_of_horse}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                bool success = await levelUpStanding(widget.group!.id, standing.id);
                                                if (success) {
                                                  setState(() {
                                                    fetchStandingsData();
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Stání úspěšně vylepšeno')),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Nepodařilo se vylepšit stání')),
                                                  );
                                                }
                                              },
                                              child: Text('Vylepšit stání'),
                                            ),
                                            SizedBox(height: 1),
                                            ElevatedButton(
                                              onPressed: () => _showAddHorseDialog(context, standing),
                                              child: Text('Přidat koně'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
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
            },
          ),
        ],
      ),
    );
  }
}