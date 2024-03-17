import 'package:flutter/material.dart';
import 'package:sand/domain/position_entity.dart';

abstract class CellEntity {
  final Position position;
  final Color color;
  final bool isMoving;
  const CellEntity({
    required this.position,
    required this.color,
    required this.isMoving,
  });

  CellEntity onUpdate(List<CellEntity> cellsToCollide);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CellEntity &&
        other.position == position &&
        other.color == color &&
        other.isMoving == isMoving;
  }

  @override
  int get hashCode => position.hashCode ^ color.hashCode ^ isMoving.hashCode;

  @override
  String toString() => 'CellEntity(position: $position, color: $color)';
}
