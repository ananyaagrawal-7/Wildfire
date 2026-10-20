import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wildfire_app/widgets/app_logo.dart';
import 'package:wildfire_app/widgets/risk_gauge.dart';
import 'package:wildfire_app/widgets/weather_metric_card.dart';
import 'package:wildfire_app/widgets/disclaimer_banner.dart';

void main() {
  testWidgets('WildFire AI - Components render properly', (WidgetTester tester) async {
    // 1. Test AppLogo with India Badge
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLogo(size: 100, showBadge: true),
        ),
      ),
    );
    expect(find.text('INDIA'), findsOneWidget);

    // 2. Test DisclaimerBanner
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DisclaimerBanner(),
        ),
      ),
    );
    expect(find.text('Academic & Educational Early-Warning Notice'), findsOneWidget);

    // 3. Test WeatherMetricCard
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WeatherMetricCard(
            icon: Icons.thermostat_rounded,
            label: 'Ambient Temp',
            value: '32.4°',
            unit: 'C',
          ),
        ),
      ),
    );
    expect(find.text('Ambient Temp'), findsOneWidget);
    expect(find.text('32.4°'), findsOneWidget);

    // 4. Test RiskGauge
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RiskGauge(score: 82, category: 'Very High'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('VERY HIGH'), findsOneWidget);
  });
}
