import 'package:flutter/material.dart';
import 'api_stuff.dart';
import 'horseScreen.dart';

class OverviewScreen extends StatefulWidget {
  final Function(int) onCoinsLost;
  Group? group;
  OverviewScreen({super.key, this.group, required this.onCoinsLost}) {
    print('OverviewScreen constructor - group: ${group?.id}'); // Debug print
  }

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  void updateGroup(Group newGroup) {
    setState(() {
      widget.group = newGroup;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      body: Stack(
        children: [
          // Background image for the entire screen
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

          // Larger box container (for stable) (smaller one for trainer)
          Positioned(
            top: screenHeight * 0.01,
            left: 16,
            right: 16,
            child: Container(
              width: screenWidth - 32, // Full width minus padding
              height: screenHeight * 0.38, // Slightly smaller than before
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
                  // Image that overlaps into the text section
                  Container(
                    height: screenHeight * 0.2, // Image height (smaller part)
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/stable.jpg'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                  ),

                  // Box for the stable content
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stáj',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Úroveň: ${widget.group?.stable.level ?? 0}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Cena zvýšení úrovně: ${widget.group?.stable.level_up_cost ?? 0}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Počet stání: '
                                    '${widget.group?.stable.number_of_full_standings ?? 0}'
                                    '/'
                                    '${widget.group?.stable.number_of_standings ?? 0}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (widget.group != null) {
                              final success = await levelUpStable(widget.group!.id);

                              if (success) {
                                if (widget.group!.stable.level < 5) {
                                  await widget.onCoinsLost(widget.group!.stable.level_up_cost);
                                }
                                // If the level-up was successful
                                final updatedGroup = await fetchGroupById(widget.group!.id);
                                setState(() {
                                  if (widget.group!.stable.level < 5) {
                                    widget.group!.stable.level += 1;
                                  }
                                  widget.group = updatedGroup;
                                });

                              } else {
                                // Optionally show an error message if the level-up failed
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('stáj nejde více vylepšit'),
                                  ),
                                );

                              }
                            }
                          },
                          child: const Text(
                              'Vylepšit',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Smaller box container below the first one
          Positioned(
            top: screenHeight * 0.44, // Position below the first box
            left: 16,
            right: 16,
            child: Container(
              width: screenWidth - 32, // Full width minus padding
              height: screenHeight * 0.33, // Smaller height
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
                  // Smaller image or content can go here
                  Container(
                    height: screenHeight * 0.15, // Smaller image height
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/trainer.jpg'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                  ),

                  // Content area for the second box
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trenér',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Úroveň: ${widget.group?.trainer.level ?? 0}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Cena zvýšení úrovně: ${widget.group?.trainer.level_up_cost ?? 0}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Počet trénování dnes: ${widget.group?.trainer.number_of_trained_horses ?? 0}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (widget.group != null &&
                                widget.group!.coins <= widget.group!.trainer.level_up_cost) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Nemáte peníze na vylepšení trenéra'),
                                ),
                              );
                            }else{
                              final success = await levelUpTrainer(widget.group!.id);
                              if (success) {
                                // If the level-up was successful
                                setState(() {
                                  if (widget.group!.trainer.level < 7) {
                                    widget.group!.trainer.level += 1;
                                  }
                                });
                                if (widget.group!.trainer.level < 7) {
                                  await widget.onCoinsLost(widget.group!.trainer.level_up_cost);
                                }
                              } else {
                                // Optionally show an error message if the level-up failed
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('trener nejde více vylepšit'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Vylepšit',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
