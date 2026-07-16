import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/analytics_genre_entity.dart';

class EngagementByGenreCard extends StatelessWidget {
  const EngagementByGenreCard({super.key, required this.genres});

  final List<AnalyticsGenreEntity> genres;

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
            'Engagement by Genre',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
          16.ph,
          if (genres.isEmpty)
            SizedBox(
              height: 200.h,
              width: double.infinity,
              child: Center(
                child: Text(
                  'No genre data yet',
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
                painter: _GenreBarChartPainter(genres: genres),
              ),
            ),
        ],
      ),
    );
  }
}

class _GenreBarChartPainter extends CustomPainter {
  _GenreBarChartPainter({required this.genres});

  final List<AnalyticsGenreEntity> genres;

  static const double _leftPad = 40;
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
    if (genres.isEmpty) return;

    final chartW = size.width - _leftPad - _rightPad;
    final chartH = size.height - _topPad - _bottomPad;

    final dataMax = genres.map((g) => g.value).reduce((a, b) => a > b ? a : b);
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

    final barPaint = Paint()
      ..color = AppColors.listenerDislikeRed
      ..style = PaintingStyle.fill;

    final count = genres.length;
    final totalGap = count > 1 ? chartW * 0.4 : 0.0;
    final barWidth = (chartW - totalGap) / count;
    final gapWidth = count > 1 ? totalGap / (count - 1) : 0.0;
    const barRadius = Radius.circular(4);

    for (int i = 0; i < count; i++) {
      final barH = maxValue > 0 ? (genres[i].value / maxValue) * chartH : 0.0;
      final left = _leftPad + i * (barWidth + gapWidth);
      final top = _topPad + chartH - barH;

      canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          left,
          top,
          left + barWidth,
          _topPad + chartH,
          topLeft: barRadius,
          topRight: barRadius,
        ),
        barPaint,
      );

      tp.text = TextSpan(text: genres[i].genre, style: labelStyle);
      tp.layout();
      tp.paint(
        canvas,
        Offset(
          left + barWidth / 2 - tp.width / 2,
          size.height - _bottomPad + 6,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GenreBarChartPainter old) =>
      !identical(old.genres, genres);
}
