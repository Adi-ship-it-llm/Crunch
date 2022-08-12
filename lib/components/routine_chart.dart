import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:koduko/models/routine.dart';
import 'package:koduko/services/routines_provider.dart';
import 'package:provider/provider.dart';

class RoutineChart extends StatelessWidget {
  RoutineChart({Key? key, required this.routine}) : super(key: key);

  final List<Color> gradientColors = [
    const Color(0xff6f7bf7),
    const Color(0xff9bf8f4),
  ];
  final Routine routine;
  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineModel>(builder: (context, value, child) {
      double maxX = value.getRoutineStartMaxDays(routine.id).toDouble();
      double maxY = value.getRoutineStats(routine.id).isNotEmpty
          ? value.getRoutineStats(routine.id).reduce(max).toDouble()
          : 10;
      Color c = Theme.of(context).brightness == Brightness.light
          ? Colors.black12
          : Colors.grey[800]!;

      final showChart = maxX >= 1 ? true : false;

      if (!showChart) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            'Complete some tasks and you will see a graph here',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: ((v, meta) => bottomTitleWidgets(
                          v, c, meta, value.getStartDate(routine.id))),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: ((v, meta) =>
                          leftTitleWidgets(v, c, meta)),
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: c,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: c,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                    show: true, border: Border.all(color: c, width: 1)),
                minX: 0,
                maxX: maxX,
                minY: -0.2,
                maxY: maxY + 2,
                lineBarsData: [
                  LineChartBarData(
                    spots: value
                        .getRoutineStats(routine.id)
                        .asMap()
                        .map((key, value) => MapEntry(
                            key, FlSpot(key.toDouble(), value.toDouble())))
                        .values
                        .toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: gradientColors
                            .map((color) => color.withOpacity(0.4))
                            .toList(),
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

Widget bottomTitleWidgets(
    double value, Color c, TitleMeta meta, DateTime start) {
  final style = TextStyle(
    color: c,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 8.0,
    child: Text(
        DateFormat('dd/MM').format(start.add(Duration(days: value.toInt()))),
        style: style),
  );
}

Widget leftTitleWidgets(double value, Color c, TitleMeta meta) {
  final style = TextStyle(
    color: c,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );
  if (value < 0) {
    return Container();
  }
  return Text(
    value.toInt().toString(),
    style: style,
    textAlign: TextAlign.center,
  );
}
