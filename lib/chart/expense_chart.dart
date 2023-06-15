import 'package:easy_localization/easy_localization.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'expense_data.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class MonthlyExpensesChart extends StatelessWidget {
  final List<ExpenseData> data;

  const MonthlyExpensesChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: 8,
          intensity: 0.6,
          surfaceIntensity: 0.25,
          shadowLightColor: Colors.white,
          shadowDarkColor: Colors.black87,
          color: Colors.grey[100],
        ),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          series: _buildChartSeries(),
          tooltipBehavior: TooltipBehavior(enable: true),
          title: ChartTitle(
            text: 'monthlyexpenses'.tr(),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          legend: Legend(
            isVisible: false,
          ),
        ),
      ),
    );
  }

  List<ChartSeries<ExpenseData, String>> _buildChartSeries() {
    return [
      ColumnSeries<ExpenseData, String>(
        dataSource: data,
        xValueMapper: (ExpenseData expense, _) => expense.month,
        yValueMapper: (ExpenseData expense, _) => expense.amount,
        color: Colors.blue.shade200,
      ),
    ];
  }
}