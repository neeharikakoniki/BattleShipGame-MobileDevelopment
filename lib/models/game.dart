import 'package:flutter/material.dart';

class GameInfo {
  int id;
  int status;
  int position;
  int turn;
  String player1;
  String player2;
  Set<String> ships;
  Set<String> wrecks;
  Set<String> shots;
  Set<String> sunk;

  GameInfo({
    required this.id,
    required this.status,
    required this.position,
    required this.turn,
    required this.player1,
    required this.player2,
    required this.ships,
    required this.wrecks,
    required this.shots,
    required this.sunk,
  });

  factory GameInfo.fromJson(Map<String, dynamic> json) {
    return GameInfo(
      id: json['id'],
      status: json['status'],
      position: json['position'],
      turn: json['turn'],
      player1: json['player1'],
      player2: json['player2'],
      ships: (json['ships'] as List).map((ship) => ship.toString()).toSet(),
      wrecks: (json['wrecks'] as List).map((wreck) => wreck.toString()).toSet(),
      shots: (json['shots'] as List).map((shot) => shot.toString()).toSet(),
      sunk: (json['sunk'] as List).map((sunk) => sunk.toString()).toSet(),
    );
  }

  int getNumOfImages(String position) {
    int num = 0;
    if (ships.contains(position) || wrecks.contains(position)) {
      num++;
    }

    if (sunk.contains(position) || shots.contains(position)) {
      num++;
    }

    return num;
  }

  Widget getWidgetForPosition(String position, double itemWidth) {
    //, double height, double width) {
    List<Image> li = [];
    int numOfImages = getNumOfImages(position);

    if (ships.contains(position)) {
      li.add(Image.asset(
        'assets/images/ship.png',
        width: itemWidth / numOfImages,
        height: itemWidth / numOfImages,
        fit: BoxFit.fitWidth,
      ));
    } else if (wrecks.contains(position)) {
      li.add(Image.asset(
        'assets/images/bubbles.png',
        width: itemWidth / numOfImages,
        height: itemWidth / numOfImages,
        fit: BoxFit.fitWidth,
      ));
    }

    if (sunk.contains(position)) {
      li.add(Image.asset(
        'assets/images/shipwreck.png',
        width: itemWidth / numOfImages,
        height: itemWidth / numOfImages,
        fit: BoxFit.fitWidth,
      ));
    } else if (shots.contains(position)) {
      li.add(Image.asset(
        'assets/images/bomb.jpg',
        width: itemWidth / numOfImages,
        height: itemWidth / numOfImages,
        fit: BoxFit.fitWidth,
      ));
    }

    return Row(
      children: li,
    );
  }
}
