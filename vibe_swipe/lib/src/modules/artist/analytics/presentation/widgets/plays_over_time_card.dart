import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/analytics_chart_data_entity.dart';

class PlaysOverTimeCard extends StatelessWidget {
  const PlaysOverTimeCard({super.key, required this.chartData});

  final AnalyticsChartDataEntity chartData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: 16.circular,
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plays Over Time',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
          16.ph,
          if (chartData.values.isEmpty || (chartData.values.length == 1 && chartData.values.first == 0))
            SizedBox(
              height: 200.h,
              width: double.infinity,
              child: Center(
                child: Text(
                  'No plays data yet',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.huegrey,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 200.h,
              width: double.infinity,
              child: CustomPaint(
                painter: _PlaysChartPainter(
                  values: chartData.values,
                  xLabels: chartData.xLabels,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaysChartPainter extends CustomPainter {
  _PlaysChartPainter({required this.values, required this.xLabels});

  final List<double> values;
  final List<String> xLabels;

  static const double _leftPad = 34;
  static const double _rightPad = 8;
  static const double _topPad = 6;
  static const double _bottomPad = 26;

  double _niceMax(double rawMax) {
    if (rawMax <= 0) return 10;
    if (rawMax <= 10) return 10;
    final magnitude = (rawMax / 4).ceil();
    final snapped = (magnitude / _snapUnit(magnitude)).ceil() * _snapUnit(magnitude);
    return snapped.toDouble();
  }

  double _snapUnit(int magnitude) {
    if (magnitude <= 1) return 1;
    if (magnitude <= 2) return 1;
    if (magnitude <= 5) return 5;
    if (magnitude <= 10) return 10;
    if (magnitude <= 20) return 20;
    if (magnitude <= 50) return 50;
    if (magnitude <= 100) return 100;
    return (magnitude / 100).ceil() * 100;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final chartW = size.width - _leftPad - _rightPad;
    final chartH = size.height - _topPad - _bottomPad;

    final dataMax = values.reduce((a, b) => a > b ? a : b);
    final maxValue = _niceMax(dataMax);
    final ySteps = <double>[];
    final stepCount = 4;
    for (int i = 0; i <= stepCount; i++) {
      ySteps.add(maxValue * i / stepCount);
    }

    final labelStyle = TextStyle(
      color: AppColors.huegrey,
      fontSize: 10,
      fontWeight: FontWeight.w400,
    );
    final tp = TextPainter(textDirection: TextDirection.ltr);

    final gridPaint = Paint()
      ..color = AppColors.primaryWhite.withValues(alpha: 0.07)
      ..strokeWidth = 0.8;

    for (final yVal in ySteps) {
      final y = _topPad + chartH - (yVal / maxValue) * chartH;
      canvas.drawLine(
        Offset(_leftPad, y),
        Offset(_leftPad + chartW, y),
        gridPaint,
      );
      final label = yVal >= 1000
          ? '${(yVal / 1000).toStringAsFixed(1)}K'
          : yVal.toInt().toString();
      tp.text = TextSpan(text: label, style: labelStyle);
      tp.layout();
      tp.paint(canvas, Offset(_leftPad - tp.width - 6, y - tp.height / 2));
    }

    final xStep = values.length > 1 ? chartW / (values.length - 1) : chartW;
    final points = <Offset>[
      for (int i = 0; i < values.length; i++)
        Offset(
          _leftPad + i * xStep,
          _topPad + chartH - (values[i] / maxValue) * chartH,
        ),
    ];

    final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath
      ..lineTo(points.last.dx, _topPad + chartH)
      ..lineTo(points.first.dx, _topPad + chartH)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.listenerActiveTab.withValues(alpha: 0.25),
            AppColors.listenerActiveTab.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(_leftPad, _topPad, chartW, chartH))
        ..style = PaintingStyle.fill,
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.listenerActiveTab
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (int i = 0; i < points.length; i++) {
      final p = points[i];

      canvas.drawCircle(p, 4, Paint()..color = AppColors.listenerActiveTab);
      canvas.drawCircle(p, 2, Paint()..color = AppColors.listenerChipBg);

      if (i < xLabels.length) {
        tp.text = TextSpan(text: xLabels[i], style: labelStyle);
        tp.layout();
        tp.paint(
          canvas,
          Offset(p.dx - tp.width / 2, size.height - _bottomPad + 6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PlaysChartPainter old) =>
      !identical(old.values, values);
}
