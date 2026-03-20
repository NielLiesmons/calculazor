import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zaplab_design/zaplab_design.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../widgets/basic_calculator_tab.dart';
import '../widgets/geometry_calculator_tab.dart';

class CalculatorScreen extends HookConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useState(LabTabController(length: 2));

    final viewPadding = MediaQuery.viewPaddingOf(context);
    final bottomPadding = LabPlatformUtils.isMobile ? viewPadding.bottom + 12 : 0.0;

    return LabScaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: LabPlatformUtils.isMobile ? viewPadding.top + 8 : 28,
          bottom: bottomPadding,
        ),
        child: LabTabView(
          controller: tabController.value,
          tabs: [
            TabData(
              label: 'Calculator',
              icon: LabIcon.s20(
                LabTheme.of(context).icons.characters.plus,
                color: LabTheme.of(context).colors.white66,
              ),
              content: const BasicCalculatorTab(),
            ),
            TabData(
              label: 'Geometry',
              icon: LabIcon.s20(
                LabTheme.of(
                  context,
                ).icons.characters.plus, // Using plus as placeholder
                color: LabTheme.of(context).colors.white66,
              ),
              content: const GeometryCalculatorTab(),
            ),
          ],
        ),
      ),
    );
  }
}
