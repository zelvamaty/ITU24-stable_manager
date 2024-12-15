import 'package:flutter/material.dart';
import 'api_stuff.dart';

class matingScreen extends StatefulWidget {
  const matingScreen({super.key, required this.group});
  final Group? group;

  @override
  _matingScreenState createState() => _matingScreenState();
}

class _matingScreenState extends State<matingScreen> {
  Horse? selectedMaleHorse;
  Horse? selectedFemaleHorse;

  Future<void> fetchStandingsData() async {
    if (widget.group == null) {
      throw Exception("Group is null");
    }
    final tmp = await fetchStandings(widget.group!.id);
    setState(() {
      standing = tmp;
    });
  }

  List<Standing> standing = [];

  @override
  void initState() {
    super.initState();
    fetchStandingsData();
  }

  @override
  void didUpdateWidget(covariant matingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group != widget.group) {
      fetchStandingsData();
    }
  }

  void _showAddHorseDialog(BuildContext context, int level, String gender) {
    final nameController = TextEditingController();
    String selectedGender = gender == 'male' ? 'muž' : 'žena';
    int finalPrice = 0;
    int finalLevel = level;
    Standing? selectedStanding;

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
                        onSelected: null,
                      ),
                      SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Žena'),
                        selected: selectedGender == 'žena',
                        onSelected: null,
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
                            onSelected: null,
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
                            onSelected: null,
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

                // Perform horse insertion
                bool success = await addHorseToShop(
                    finalLevel,
                    nameController.text,
                    finalPrice, // Default price
                    selectedGender);

                if (success) {
                  // Refresh the standings
                  setState(() {
                    fetchShopItems();
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Nepodařilo se přidat koně')),
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

  void _calculateDuplicatingChance() async {
    if (selectedMaleHorse != null && selectedFemaleHorse != null) {
      final data = await getDuplicatingChance(selectedMaleHorse!.level, selectedFemaleHorse!.level);
      _showAddHorseDialog(context, data.level == 0 ? 1 : data.level, data.gender);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prosím vyberte oba koně')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (standing.isEmpty) {
      fetchStandingsData();
    }

    // Filter available male and female horses
    List<Horse> availableMaleHorses = standing
        .where((s) => s.horse != null && s.horse!.gender == 'muž')
        .map((s) => s.horse!)
        .toList();

    List<Horse> availableFemaleHorses = standing
        .where((s) => s.horse != null && s.horse!.gender == 'žena')
        .map((s) => s.horse!)
        .toList();

    print('availableMaleHorses: $availableMaleHorses');
    print('availableFemaleHorses: $availableFemaleHorses');

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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Male Horse Dropdown
                DropdownButton<Horse>(
                  hint: Text(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,),
                      'Zvolit koně'
                  ),
                  value: selectedMaleHorse,
                  items: availableMaleHorses.map((Horse horse) {
                    return DropdownMenuItem<Horse>(
                      value: horse,
                      child: Text(style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,),horse.name),
                    );
                  }).toList(),
                  onChanged: (Horse? newValue) {
                    setState(() {
                      selectedMaleHorse = newValue;
                    });
                  },
                ),
                SizedBox(height: 20),
                // Female Horse Dropdown
                DropdownButton<Horse>(
                  hint: Text(
                    style: TextStyle(
                      color: Colors.black,
                    fontSize: 30,),
                      'Zvolit klisnu'
                  ),
                  value: selectedFemaleHorse,
                  items: availableFemaleHorses.map((Horse horse) {
                    return DropdownMenuItem<Horse>(
                      value: horse,
                      child: Text(style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,),horse.name),
                    );
                  }).toList(),
                  onChanged: (Horse? newValue) {
                    setState(() {
                      selectedFemaleHorse = newValue;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _calculateDuplicatingChance,
                  child: Text('Vypočítat staty na duplikaci a vytvořit koně'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}