class Position {
  final int row;
  final int column;
  const Position(
    this.row,
    this.column,
  );

  Position copyWith({
    int? row,
    int? column,
  }) {
    return Position(
      row ?? this.row,
      column ?? this.column,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Position && other.row == row && other.column == column;
  }

  @override
  int get hashCode => row.hashCode ^ column.hashCode;
}
