import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_10/button.dart';
import 'package:flutter_application_10/pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int numberOfSquares = 130;
  List<int> piece = [];
  var direction = 'left';
  List<int> landed = [100000];
  int level = 0;
  int score = 0;
  int bestScore = 0;
  int gamesPlayed = 0;
  int speed = 250;
  bool showFlash = false;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    loadGameData();
  }

  void loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('bestScore') ?? 0;
      gamesPlayed = prefs.getInt('gamesPlayed') ?? 0;
    });
  }

  void saveGameData() async {
    final prefs = await SharedPreferences.getInstance();
    if (score > bestScore) {
      await prefs.setInt('bestScore', score);
    }
    await prefs.setInt('gamesPlayed', gamesPlayed);
  }

  void startGame() {
    resetGame();
    gamesPlayed++;

    piece = [
      numberOfSquares - 4,
      numberOfSquares - 3,
      numberOfSquares - 2,
      numberOfSquares - 1,
    ];

    gameTimer?.cancel();
    gameTimer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      if (checkWinner()) {
        saveGameData();
        _showDialog();
        timer.cancel();
      }

      if (piece.first % 10 == 0) {
        direction = 'right';
      } else if (piece.last % 10 == 9) {
        direction = 'left';
      }

      setState(() {
        if (direction == 'right') {
          for (int i = 0; i < piece.length; i++) {
            piece[i] += 1;
          }
        } else {
          for (int i = 0; i < piece.length; i++) {
            piece[i] -= 1;
          }
        }
      });
    });
  }

  bool checkWinner() {
    return landed.last < 10;
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text(
            'Score: $score\nBest: $bestScore\nGames Played: $gamesPlayed',
          ),
          actions: [
            TextButton(
              child: Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop();
                restartGame();
              },
            ),
          ],
        );
      },
    );
  }

  void stack() {
    setState(() {
      level++;
      for (int i = 0; i < piece.length; i++) {
        landed.add(piece[i]);
      }

      score += piece.length;

      if (level == 1) {
        piece = [
          numberOfSquares - 3 - level * 10,
          numberOfSquares - 2 - level * 10,
          numberOfSquares - 1 - level * 10,
        ];
      } else if (level == 2 || level == 3) {
        piece = [
          numberOfSquares - 2 - level * 10,
          numberOfSquares - 1 - level * 10,
        ];
      } else if (level >= 4) {
        piece = [numberOfSquares - 1 - level * 10];
      }

      if (level >= 7) {
        _showDialog();
        gameTimer?.cancel();
      }

      checkStack();
    });
  }

  void checkStack() {
    landed.removeWhere((element) {
      return !landed.contains(element + 10) &&
          (element + 10) < numberOfSquares - 1;
    });
  }

  void restartGame() {
    setState(() {
      resetGame();
      startGame();
    });
  }

  void resetGame() {
    gameTimer?.cancel();
    piece.clear();
    landed = [100000];
    level = 0;
    score = 0;
    speed = 250;
  }

  Color getColor(int index) {
    if (piece.contains(index)) {
      return level < 3
          ? Colors.white
          : level < 6
          ? Colors.blue
          : Colors.red;
    } else if (landed.contains(index)) {
      return Colors.grey[700]!;
    } else {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Score: $score',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    Text(
                      'Best: $bestScore',
                      style: TextStyle(color: Colors.orange, fontSize: 24),
                    ),
                    Text(
                      'Games: $gamesPlayed',
                      style: TextStyle(color: Colors.green, fontSize: 24),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: GridView.builder(
                  itemCount: numberOfSquares,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return MyPixel(color: getColor(index));
                  },
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyButton(
                      function: startGame,
                      child: Text(
                        'PLAY',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    MyButton(
                      function: stack,
                      child: Text(
                        'STOP',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    MyButton(
                      function: restartGame,
                      child: Text(
                        'RESTART',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
