import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      home: const GameSetupScreen(),
    );
  }
}

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();
  bool isSinglePlayer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tic Tac Toe"),
        centerTitle: true,
        backgroundColor: Colors.pink.shade50,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text("Single Player vs AI"),
                value: isSinglePlayer,
                onChanged: (val) {
                  setState(() => isSinglePlayer = val);
                },
              ),
              TextField(
                controller: _player1Controller,
                decoration: const InputDecoration(labelText: "Player 1 Name"),
              ),
              if (!isSinglePlayer)
                TextField(
                  controller: _player2Controller,
                  decoration:
                      const InputDecoration(labelText: "Player 2 Name"),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  String player1 = _player1Controller.text.trim();
                  String player2 = isSinglePlayer
                      ? "AI"
                      : _player2Controller.text.trim();

                  if (player1.isEmpty || player2.isEmpty) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GameScreen(player1: player1, player2: player2, isAI: isSinglePlayer),
                    ),
                  );
                },
                child: const Text("Start Game"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String player1;
  final String player2;
  final bool isAI;

  const GameScreen({
    super.key,
    required this.player1,
    required this.player2,
    required this.isAI,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String winner = '';
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
  }

  void playMove(int index) {
    if (board[index] != '' || gameOver) return;

    setState(() {
      board[index] = currentPlayer;
      if (checkWin(currentPlayer)) {
        winner = currentPlayer == 'X' ? widget.player1 : widget.player2;
        gameOver = true;
      } else if (!board.contains('')) {
        winner = 'Draw';
        gameOver = true;
      } else {
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      }
    });

    if (widget.isAI && currentPlayer == 'O' && !gameOver) {
      Future.delayed(const Duration(milliseconds: 300), aiMove);
    }
  }

  void aiMove() {
    List<int> empty = [];
    for (int i = 0; i < 9; i++) {
      if (board[i] == '') empty.add(i);
    }
    if (empty.isNotEmpty) {
      int move = empty[Random().nextInt(empty.length)];
      playMove(move);
    }
  }

  bool checkWin(String symbol) {
    List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]] == symbol &&
          board[pattern[1]] == symbol &&
          board[pattern[2]] == symbol) {
        return true;
      }
    }
    return false;
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      winner = '';
      gameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    double boxSize = size > 400 ? 100 : size / 3.5;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("${widget.player1} vs ${widget.player2}"),
        centerTitle: true,
        backgroundColor: Colors.pink.shade50,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!gameOver)
              Text(
                "${currentPlayer == 'X' ? widget.player1 : widget.player2}'s Turn",
                style: const TextStyle(fontSize: 20),
              ),
            if (gameOver)
              Text(
                winner == 'Draw' ? "It's a Draw!" : "$winner Wins!",
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: boxSize * 3,
              height: boxSize * 3,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => playMove(index),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        board[index],
                        style: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: resetGame, child: const Text("Restart")),
          ],
        ),
      ),
    );
  }
}
