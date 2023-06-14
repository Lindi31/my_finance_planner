import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'expense_data.dart';

class MonthlyExpensesChart extends StatelessWidget {
  final List<ExpenseData> data;

  const MonthlyExpensesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <ChartSeries>[
          ColumnSeries<ExpenseData, String>(
            dataSource: data,
            xValueMapper: (ExpenseData expense, _) => expense.month,
            yValueMapper: (ExpenseData expense, _) => expense.amount,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
