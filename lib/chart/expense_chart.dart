import 'package:easy_localization/easy_localization.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tests/theme/theme_constants.dart';
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
          intensity: 0.7,
          surfaceIntensity: 0.25,
          shadowLightColor: Theme.of(context).brightness == Brightness.light
              ? const NeumorphicStyle().shadowLightColor
              : grey600,
          shadowDarkColor: Theme.of(context).brightness == Brightness.dark
              ? const NeumorphicStyle().shadowDarkColor
              : grey400,
          color: Theme.of(context).brightness == Brightness.light
              ? grey200
              : grey800,
        ),
        child: SfCartesianChart(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? grey200
              : grey700,
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
