import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sand/domain/cell_entity.dart';
import 'package:sand/domain/position_entity.dart';
import 'package:sand/domain/sand_entity.dart';
import 'package:sand/domain/water_entity.dart';
import 'package:signals_flutter/signals_flutter.dart';

final rowCount = signal(100);
final columnCount = signal(100);
final isDebugging = signal(false);
final generateSpeed = signal(100);
final isWater = signal(false);

final movingCell = signal<List<CellEntity>>([]);
final inertCell = signal<List<CellEntity>>([]);
final allCells = computed<List<CellEntity>>(
  () => [
    ...movingCell.value,
    ...inertCell.value,
  ],
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Ticker ticker;
  int time = 0;
  int lastUpdate = 0;
  bool isHolding = false;
  Offset currentPosition = Offset.zero;
  double cellSize = 0;
  int lastGenerate = 0;

  generateSand(Offset localPosition) {
    final column = (localPosition.dx / cellSize).floor();
    final row = (localPosition.dy / cellSize).floor();
    final cell = isWater.value
        ? WaterEntity.basic(
            position: Position(row, column),
            color: waterColors[Random().nextInt(
              waterColors.length,
            )],
          )
        : SandEntity.basic(
            position: Position(
              row,
              column,
            ),
            color: sandColors[Random().nextInt(
              sandColors.length,
            )],
          );
    movingCell.set([...movingCell.value, cell]);
  }

  @override
  void initState() {
    super.initState();
    ticker = Ticker((dt) {
      final milliseconds = dt.inMilliseconds;
      setState(() {
        if ((milliseconds - lastUpdate) >= 1) {
          lastUpdate = milliseconds;
          for (final cellMoving in [...movingCell.value]) {
            final newCell = cellMoving.onUpdate(allCells.value);
            if (newCell.isMoving) {
              var cells = [...movingCell.value];
              cells.remove(cellMoving);
              cells.add(newCell);
              movingCell.set(cells);
            } else {
              var cells = [...movingCell.value];
              cells.remove(cellMoving);
              movingCell.set(cells);
              inertCell.set([...inertCell.value, newCell]);
            }
          }
        }
        if ((milliseconds - lastGenerate) >= generateSpeed.value) {
          if (isHolding) {
            generateSand(currentPosition);
          }
          lastGenerate = milliseconds;
        }
        time = milliseconds;
      });
    });
    ticker.start();
    Future(() => setSizeListener());
  }

  setSizeListener() {
    rowCount.listen(context, () {
      untracked(() {
        batch(() {
          movingCell.set([
            ...movingCell.value,
            ...inertCell.value,
          ]);
          inertCell.set([]);
        });
      });
    });
    columnCount.listen(context, () {
      untracked(() {
        batch(() {
          movingCell.set([
            ...movingCell.value,
            ...inertCell.value,
          ]);
          inertCell.set([]);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth / columnCount.value;
                final height = constraints.maxHeight / rowCount.value;
                cellSize = min(width, height);
                return Center(
                  child: SizedBox(
                    width: cellSize * columnCount.value,
                    height: cellSize * rowCount.value,
                    child: GestureDetector(
                      onTapDown: (details) {
                        generateSand(details.localPosition);
                        currentPosition = details.localPosition;
                        isHolding = true;
                      },
                      onTapUp: (details) {
                        isHolding = false;
                      },
                      onPanStart: (details) {
                        isHolding = true;
                      },
                      onPanCancel: () {
                        isHolding = false;
                      },
                      onPanEnd: (details) {
                        isHolding = false;
                      },
                      onPanUpdate: (details) {
                        currentPosition = details.localPosition;
                      },
                      child: Container(
                        color: Colors.black,
                        width: cellSize * columnCount.value,
                        height: cellSize * rowCount.value,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const SizedBox.expand(),
                            if (isDebugging.value)
                              for (var y = 0; y < rowCount.value; y++)
                                Positioned(
                                  top: y * cellSize,
                                  child: SizedBox(
                                    width: double.maxFinite,
                                    child: Divider(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                            if (isDebugging.value)
                              for (var x = 0; x < columnCount.value; x++)
                                Positioned(
                                  left: x * cellSize,
                                  child: SizedBox(
                                    height: double.maxFinite,
                                    child: VerticalDivider(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                            for (final cell in allCells.value)
                              Positioned(
                                left: cell.position.column * cellSize,
                                top: cell.position.row * cellSize,
                                child: Container(
                                  width: cellSize,
                                  height: cellSize,
                                  decoration: BoxDecoration(
                                    color: cell.color,
                                    border: Border.all(
                                      color: cell.color,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text('Debug'),
                        Switch(
                          value: isDebugging.value,
                          onChanged: (value) {
                            isDebugging.set(value);
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    ToggleButtons(
                      color: Colors.black,
                      fillColor: isWater.value ? Colors.blue : Colors.amber,
                      borderRadius: BorderRadius.circular(90),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      borderColor: Colors.deepPurple,
                      isSelected: [!isWater.value, isWater.value],
                      children: const [
                        Text('Areia'),
                        Text('Água'),
                      ],
                      onPressed: (index) {
                        isWater.set(index == 1);
                      },
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        movingCell.set([]);
                        inertCell.set([]);
                      },
                      child: const Icon(
                        Icons.refresh,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Velocidade de geração'),
                          Slider(
                            value: 500 - (generateSpeed.value / 1),
                            min: 10,
                            max: 500,
                            onChanged: (value) {
                              generateSpeed.set(500 - value.floor());
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Linhas'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  rowCount.set(rowCount.value - 10);
                                },
                                icon: const Icon(Icons.remove),
                              ),
                              Text(
                                rowCount.value.toStringAsFixed(0),
                              ),
                              IconButton(
                                onPressed: () {
                                  rowCount.set(rowCount.value + 10);
                                },
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Colunas'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  columnCount.set(columnCount.value - 10);
                                },
                                icon: const Icon(Icons.remove),
                              ),
                              Text(
                                columnCount.value.toStringAsFixed(0),
                              ),
                              IconButton(
                                onPressed: () {
                                  columnCount.set(columnCount.value + 10);
                                },
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
