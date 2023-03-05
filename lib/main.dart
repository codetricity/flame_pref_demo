import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChannels;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(GameWidget(game: FlamePref()));
}

class FlamePref extends FlameGame with HasTappables {
  int counter = 0;
  TextComponent score = TextComponent();
  bool reset = false;
  late int maxFrogsInRow;
  int currentFrogsInRow = 0;
  late int row;
  double frogX = 0;
  double frogY = 300.0;
  late final SharedPreferences prefs;
  @override
  FutureOr<void> onLoad() async {
    prefs = await SharedPreferences.getInstance();
    maxFrogsInRow = (size.x ~/ 128);
    row = counter ~/ (maxFrogsInRow + 1);

    counter = prefs.getInt('counter') ?? 0;

    add(score
      ..textRenderer = TextPaint(
        style: const TextStyle(fontSize: 40, fontFamily: 'Arcade'),
      )
      ..position = Vector2(100, 30)
      ..anchor = Anchor.center);

    add(
      ButtonComponent(
          button: TextComponent(
            text: ' exit ',
            textRenderer: TextPaint(
                style: const TextStyle(fontFamily: 'Arcade', fontSize: 40)),
          ),
          position: Vector2(100, 200),
          onPressed: () {
            if (Platform.isAndroid) {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            } else if (Platform.isWindows) {
              exit(0);
            }
          }),
    );
    add(ButtonComponent(
        button: TextComponent(
            text: ' increment ',
            textRenderer: TextPaint(
                style: const TextStyle(
              backgroundColor: Colors.green,
              fontFamily: 'Arcade',
              fontSize: 40,
            ))),
        position: Vector2.all(100),
        onPressed: () async {
          counter = counter + 1;

          frogX = 128.0 * counter - 128;
          frogY = 300.0;
          debugPrint(
              'debug: max frogs in row: $maxFrogsInRow, screenX: ${size.x}');
          debugPrint('debug: current row: $row');
          if (currentFrogsInRow >= maxFrogsInRow) {
            frogX = 0;
            currentFrogsInRow = 0;
            row++;
          }
          frogX = currentFrogsInRow * 128;
          currentFrogsInRow++;
          // print('frog: ($frogX, $frogY), frog in row number: $frogsInRow');
          frogY = 300.0 + 150.0 * row;
          Frog frog = Frog()..position = Vector2(frogX, frogY);
          prefs.setInt('counter', counter);
          add(frog);
          // print("pressed button ${await prefs.getInt('counter')}");
        }));
    add(
      ButtonComponent(
          button: TextComponent(
              text: ' reset ',
              textRenderer: TextPaint(
                  style: const TextStyle(
                backgroundColor: Colors.yellow,
                color: Colors.red,
                fontFamily: 'Arcade',
                fontSize: 40,
              ))),
          position: Vector2(400, 100),
          onPressed: () {
            resetScreen();
            prefs.setInt('counter', counter);
          }),
    );
    showFrogs();

    return super.onLoad();
  }

  void resetScreen() async {
    maxFrogsInRow = (size.x ~/ 128);

    counter = 0;
    currentFrogsInRow = 0;
    row = 0;
    reset = true;

    // print("pressed button ${await prefs.getInt('counter')}");
  }

  void showFrogs() {
    counter = prefs.getInt('counter') ?? 0;

    for (int i = 0; i < counter; i++) {
      if (currentFrogsInRow >= maxFrogsInRow) {
        frogX = 0;
        currentFrogsInRow = 0;
        row++;
      }
      frogX = currentFrogsInRow * 128;
      currentFrogsInRow++;
      frogY = 300.0 + 150.0 * row;
      Frog frog = Frog()..position = Vector2(frogX, frogY);
      add(frog);
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    resetScreen();
    showFrogs();
    super.onGameResize(canvasSize);
  }

  @override
  void update(double dt) {
    score.text = 'frogs: $counter';

    if (reset) {
      final allFrogs = children.query<Frog>();
      // print('number of frogs: ${allFrogs.length}');
      removeAll(allFrogs);
      reset = false;
    }

    super.update(dt);
  }
}

class Frog extends SpriteComponent with HasGameRef {
  @override
  FutureOr<void> onLoad() async {
    sprite =
        await gameRef.loadSprite('frog32x32.png', srcSize: Vector2.all(32.0));
    size = Vector2.all(32) * 4;

    return super.onLoad();
  }
}
