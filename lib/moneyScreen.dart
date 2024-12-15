import 'package:flutter/material.dart';
import 'api_stuff.dart';

class moneyScreen extends StatefulWidget {
  final Function(int) onCoinsAdded;
  final Group? group;
  const moneyScreen({super.key, required this.onCoinsAdded, required this.group});

  @override
  _moneyScreenState createState() => _moneyScreenState();
}

class _moneyScreenState extends State<moneyScreen> {
  int coinAmount = 0;

  final TextEditingController _controller = TextEditingController();

  void _incrementCoins1() {
    setState(() {
      coinAmount += 1;
    });
  }

  void _decrementCoins1() {
    setState(() {
      if (coinAmount >= 1) {
        coinAmount -= 1;
      }
    });
  }

  void _incrementCoins5() {
    setState(() {
      coinAmount += 5;
    });
  }

  void _decrementCoins5() {
    setState(() {
      if (coinAmount >= 5) {
        coinAmount -= 5;
      }
    });
  }

  void _incrementCoins10() {
    setState(() {
      coinAmount += 10;
    });
  }

  void _decrementCoins10() {
    setState(() {
      if (coinAmount >= 10) {
        coinAmount -= 10;
      }
    });
  }

  void _resetCoins() {
    setState(() {
      coinAmount = 0;
    });
  }


  Widget buildCoinRow({
    required VoidCallback onDecrementPressed,
    required VoidCallback onIncrementPressed,
    int value = 10,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Minus Button
        ElevatedButton(
          onPressed: onDecrementPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
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
        // Plus Button
        ElevatedButton(
          onPressed: onIncrementPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
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

  @override
  Widget build(BuildContext context) {
    Group group;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    int groupID = widget.group?.id??0;
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

          Positioned(
            left: 0,
            right: 0,
            top: screenHeight * 0.08, // adjust this value to position vertically
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Počet peněz',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  //added offset
                  SizedBox(height: 40),
                  Text(
                    '$coinAmount',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 60),

                  buildCoinRow(
                    onDecrementPressed: _decrementCoins1,
                    onIncrementPressed: _incrementCoins1,
                    value: 1
                  ),


                  SizedBox(height: 20),

                  buildCoinRow(
                    onDecrementPressed: _decrementCoins5,
                    onIncrementPressed: _incrementCoins5,
                    value: 5
                  ),
                  SizedBox(height: 20),

                  buildCoinRow(
                    onDecrementPressed: _decrementCoins10,
                    onIncrementPressed: _incrementCoins10,
                    value: 10
                  ),

                  // buttons for minus and adding
                  //
                  SizedBox(height: 40),

                  // Add coins button
                  ElevatedButton(

                    onPressed: () async {
                      await addCoins(groupID, coinAmount);
                      widget.onCoinsAdded(coinAmount);
                      _resetCoins();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                    ),
                    child: Text(
                      'Přidat peníze',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),



                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}