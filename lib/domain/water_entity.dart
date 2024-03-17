import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sand/domain/cell_entity.dart';
import 'package:sand/domain/position_entity.dart';
import 'package:sand/presentation/home_screen.dart';

List<Color> waterColors = [
  Colors.blue,
  Colors.blueAccent,
  Colors.cyan,
  Colors.cyanAccent,
];

class WaterEntity extends CellEntity {
  const WaterEntity.basic({
    required super.position,
    required super.color,
  }) : super(
          isMoving: true,
        );
  const WaterEntity({
    required super.position,
    required super.isMoving,
    required super.color,
  });

  @override
  WaterEntity onUpdate(List<CellEntity> cellsToCollide) {
    if (position.row == rowCount.value - 1) {
      return copyWith(isMoving: false);
    }
    bool bottom = (position.row == rowCount.value - 1);
    bool left = (position.column == 0);
    bool right = (position.column == columnCount.value - 1);
    for (final cell in cellsToCollide) {
      if (position.column == cell.position.column &&
          position.row + 1 == cell.position.row) {
        bottom = true;
      }
      if (!left &&
          position.row == cell.position.row &&
          position.column - 1 == cell.position.column) {
        left = true;
      }
      if (!right &&
          position.row == cell.position.row &&
          position.column + 1 == cell.position.column) {
        right = true;
      }
    }
    if (bottom && left && right) {
      return copyWith(isMoving: false);
    }
    if (bottom && left) {
      return copyWith(
        newPosition: Position(
          position.row,
          position.column + 1,
        ),
      );
    }
    if (bottom && right) {
      return copyWith(
        newPosition: Position(
          position.row,
          position.column - 1,
        ),
      );
    }
    if (bottom) {
      final randomDirection = Random().nextBool() ? -1 : 1;
      return copyWith(
        newPosition: Position(
          position.row,
          position.column + randomDirection,
        ),
      );
    }
    return copyWith(
      newPosition: Position(
        position.row + 1,
        position.column,
      ),
    );
  }

  WaterEntity copyWith({
    Position? newPosition,
    bool? isMoving,
  }) {
    return WaterEntity(
      isMoving: isMoving ?? this.isMoving,
      position: newPosition ?? position,
      color: color,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WaterEntity &&
        other.position == position &&
        other.color == color &&
        other.isMoving == isMoving;
  }

  @override
  int get hashCode => position.hashCode ^ color.hashCode ^ isMoving.hashCode;
}
