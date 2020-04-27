import 'package:expense_tracker/pie_chart/lib/pie_chart.dart';
import 'package:flutter/material.dart';


BuildPieChart(BuildContext context, Map<String, double> dataMap, List<Color> colorList) {

  return PieChart(
    dataMap: dataMap,
    animationDuration: Duration(milliseconds: 800),
    chartLegendSpacing: 32.0,
    chartRadius: MediaQuery.of(context).size.width / 2.7,
    showChartValuesInPercentage: true,
    showChartValues: true,
    showChartValuesOutside: false,
    chartValueBackgroundColor: Colors.grey[200],
    colorList: colorList,
    showLegends: true,
    legendPosition: LegendPosition.right,
    decimalPlaces: 1,
    showChartValueLabel: true,
    initialAngle: 0,
    chartValueStyle: defaultChartValueStyle.copyWith(
      color: Colors.blueGrey[900].withOpacity(0.9),
    ),
    chartType: ChartType.ring,
  );
}