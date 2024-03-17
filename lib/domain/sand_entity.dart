import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sand/domain/cell_entity.dart';
import 'package:sand/domain/position_entity.dart';
import 'package:sand/presentation/home_screen.dart';

List<Color> sandColors = [
  Colors.amber,
  Colors.amberAccent,
  Colors.yellow,
  Colors.yellowAccent,
];

class SandEntity extends CellEntity {
  const SandEntity.basic({
    required super.position,
    required super.color,
  }) : super(
          isMoving: true,
        );
  const SandEntity({
    required super.position,
    required super.isMoving,
    required super.color,
  });

  @override
  SandEntity onUpdate(List<CellEntity> cellsToCollide) {
    if (position.row == rowCount.value - 1) {
      return copyWith(isMoving: false);
    }
    bool bottom = (position.row == rowCount.value - 1);
    bool left = (position.column == 0);
    bool right = (position.column == columnCount.value - 1);
    for (final cell in cellsToCollide) {
      if (cell is SandEntity && !cell.isMoving) {
        if (position.column == cell.position.column &&
            position.row + 1 == cell.position.row) {
          bottom = true;
        }
        if (!left &&
            position.row + 1 == cell.position.row &&
            position.column - 1 == cell.position.column) {
          left = true;
        }
        if (!right &&
            position.row + 1 == cell.position.row &&
            position.column + 1 == cell.position.column) {
          right = true;
        }
      }
    }
    if (bottom && left && right) {
      return copyWith(isMoving: false);
    }
    if (bottom && left) {
      return copyWith(
        newPosition: Position(
          position.row + 1,
          position.column + 1,
        ),
      );
    }
    if (bottom && right) {
      return copyWith(
        newPosition: Position(
          position.row + 1,
          position.column - 1,
        ),
      );
    }
    if (bottom) {
      final positionRandom = Random().nextBool() ? -1 : 1;
      return copyWith(
        newPosition: Position(
          position.row + 1,
          position.column + positionRandom,
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

  SandEntity copyWith({
    Position? newPosition,
    bool? isMoving,
  }) {
    return SandEntity(
      isMoving: isMoving ?? this.isMoving,
      position: newPosition ?? position,
      color: color,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SandEntity &&
        other.position == position &&
        other.color == color &&
        other.isMoving == isMoving;
  }

  @override
  int get hashCode => position.hashCode ^ color.hashCode ^ isMoving.hashCode;
}
