import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;


class MonthlyExpensesChart extends StatelessWidget {
  final List<ExpenseData> data;

  const MonthlyExpensesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<ExpenseData, String>> series = [
      charts.Series(
        id: 'Expenses',
        data: data,
        domainFn: (ExpenseData expense, _) => expense.month,
        measureFn: (ExpenseData expense, _) => expense.amount,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: charts.BarChart(
        series,
        animate: true,
        domainAxis: const charts.OrdinalAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 12,
            ),
          ),
        ),
        primaryMeasureAxis: const charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class ExpenseData {
  final String month;
  final double amount;

  ExpenseData({required this.month, required this.amount});
}

