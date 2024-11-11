import 'package:flutter/material.dart';

class Horsescreen extends StatelessWidget {
  const Horsescreen({super.key});

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
                image: AssetImage('assets/background.jpg'), // Background image
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.5),
                  BlendMode.lighten,
                ),
              ),
            ),
          ),

          // List of Boxes
          ListView.builder(
            itemCount: 9, // Set to 9 to display 9 items, change to 4 for 4 items
            itemBuilder: (context, index) {
              // Adjust size and content dynamically based on the index (you can have different sizes or content for different items)
              bool isFirstBox = index == 0;
              bool isSecondBox = index == 1;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: screenWidth - 32, // Full width minus padding
                  height: isFirstBox ? screenHeight * 0.4 : screenHeight * 0.3, // Top box bigger, others smaller
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
                      // Image section (dynamically changing image based on index)
                      Container(
                        height: isFirstBox ? screenHeight * 0.2 : screenHeight * 0.15, // Different image height
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              isFirstBox
                                  ? 'assets/stefan.jpeg' // First box image
                                  : 'assets/empty_stable.jpg', // Second and others
                            ),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                      ),

                      // Content area for the box
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isFirstBox ? 'KUN STEFANN' : 'Volné stání', // Dynamic title based on the box
                              style: TextStyle(
                                fontSize: isFirstBox ? 24 : 20, // Larger text for the first box
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Vylepšit'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
