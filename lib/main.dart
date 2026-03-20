import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zaplab_design/zaplab_design.dart';
import 'package:go_router/go_router.dart';
import 'screens/calculator_screen.dart';
import 'src/providers/color_themes.dart';

void main() {
  runApp(const ProviderScope(child: CalculazorApp()));
}

class CalculazorApp extends StatelessWidget {
  const CalculazorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const CalculatorScreen(),
        ),
      ],
    );

    return LabBase(
      title: 'Calculazor',
      routerConfig: router,
      colorsOverride: ColorThemes.getOverride('Ocean'),
    );
  }
}
