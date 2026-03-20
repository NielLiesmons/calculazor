import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zaplab_design/zaplab_design.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tap_builder/tap_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math' as math;

class BasicCalculatorTab extends HookConsumerWidget {
  const BasicCalculatorTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expression = useState<String>('');
    final result = useState<String>('');
    final recentResults = useState<List<double>>([]);
    final calculationHistory = useState<List<String>>([]);
    final showCursor = useState(true);
    final scrollController = useScrollController();
    final isAtBottom = useState(true);

    Future<List<double>> loadRecentResults() async {
      final prefs = await SharedPreferences.getInstance();
      final results = prefs.getStringList('recent_results') ?? [];
      return results.map((e) => double.parse(e)).toList();
    }

    Future<void> saveRecentResults(List<double> results) async {
      final prefs = await SharedPreferences.getInstance();
      final stringResults = results.map((e) => e.toString()).toList();
      await prefs.setStringList('recent_results', stringResults);
    }

    Future<List<String>> loadCalculationHistory() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('calculation_history') ?? [];
    }

    Future<void> saveCalculationHistory(List<String> history) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('calculation_history', history);
    }

    // Load recent results and calculation history on init
    useEffect(() {
      loadRecentResults().then((results) {
        recentResults.value = results;
      });
      loadCalculationHistory().then((history) {
        calculationHistory.value = history;
      });
      return null;
    }, []);

    // Cursor blinking timer
    useEffect(() {
      final timer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) => showCursor.value = !showCursor.value,
      );
      return timer.cancel;
    }, []);

    // Scroll to show newest (at bottom of reverse list) when history changes
    useEffect(() {
      if (calculationHistory.value.isNotEmpty && scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
      return null;
    }, [calculationHistory.value]);

    // Track scroll position (for reverse list, 0 = bottom = newest)
    useEffect(() {
      void onScroll() {
        if (scrollController.hasClients) {
          final position = scrollController.position;
          final atNewest = position.pixels <= 2;
          if (isAtBottom.value != atNewest) {
            isAtBottom.value = atNewest;
          }
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, []);

    void addToExpression(String value) {
      expression.value += value;
    }

    void clearExpression() {
      expression.value = '';
      result.value = '';
    }

    void deleteLast() {
      if (expression.value.isNotEmpty) {
        expression.value = expression.value.substring(
          0,
          expression.value.length - 1,
        );
      }
    }

    void loadFromHistory(String historyExpression) {
      expression.value = historyExpression; // Load the expression
      result.value = ''; // Clear result
    }

    void calculate() {
      try {
        if (expression.value.isEmpty) return;

        // Replace display symbols with math symbols
        String mathExpression = expression.value
            .replaceAll('×', '*')
            .replaceAll('÷', '/')
            .replaceAll('π', '${math.pi}')
            .replaceAll('φ', '${(1 + math.sqrt(5)) / 2}') // Golden ratio
            .replaceAll('e', '${math.e}');

        final parser = ShuntingYardParser();
        final exp = parser.parse(mathExpression);
        final context = ContextModel();
        final evalResult = exp.evaluate(EvaluationType.REAL, context);

        if (evalResult is double) {
          final formattedResult = _formatNumber(evalResult);

          // Add ONLY the expression to calculation history (ONE line)
          final newHistory = [
            ...calculationHistory.value,
            expression.value, // Just the expression string
          ];
          calculationHistory.value = newHistory;
          saveCalculationHistory(newHistory);

          // Add to recent results
          final newRecentResults = [
            evalResult,
            ...recentResults.value.take(99),
          ];
          recentResults.value = newRecentResults;
          saveRecentResults(newRecentResults);

          // Replace current expression with result
          expression.value = formattedResult;
          result.value = ''; // Clear result since it's now in expression
        }
      } catch (e) {
        expression.value = 'Error';
        result.value = '';
      }
    }

    void useRecentResult(double value) {
      expression.value += _formatNumber(value); // APPEND to current expression
    }

    return LabScaffold(
      body: Column(
        children: [
          Expanded(
            child: LabContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calculation history zone (expandable and scrollable)
                  Expanded(
                    child: LabContainer(
                      padding: const LabEdgeInsets.all(LabGapSize.s12),
                      child: LabContainer(
                        width: double.infinity,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: LabTheme.of(context).colors.gray33,
                          borderRadius: LabTheme.of(
                            context,
                          ).radius.asBorderRadius().rad16,
                          border: Border.all(
                            color: LabTheme.of(context).colors.white33,
                            width: LabLineThicknessData.normal().thin,
                          ),
                        ),
                        child: Column(
                          children: [
                            // 1. Previous calculations (scrollable, newest at bottom above current line)
                            if (calculationHistory.value.isNotEmpty) ...[
                              Expanded(
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        LabTheme.of(context).colors.black,
                                        LabTheme.of(
                                          context,
                                        ).colors.black.withValues(alpha: 0.0),
                                        LabTheme.of(
                                          context,
                                        ).colors.black.withValues(alpha: 0.0),
                                        isAtBottom.value
                                            ? LabTheme.of(context).colors.black
                                                  .withValues(alpha: 0.0)
                                            : LabTheme.of(context).colors.black,
                                      ],
                                      stops: const [0.0, 0.15, 0.85, 1.0],
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.dstOut,
                                  child: ListView.builder(
                                    controller: scrollController,
                                    reverse: true,
                                    itemCount: calculationHistory.value.length,
                                    itemBuilder: (context, index) {
                                      final historyExpression =
                                          calculationHistory.value[
                                              calculationHistory.value.length -
                                                  1 -
                                                  index];
                                      return TapBuilder(
                                        onTap: () =>
                                            loadFromHistory(historyExpression),
                                        builder: (context, state, hasFocus) {
                                          return LabContainer(
                                            padding: LabEdgeInsets.only(
                                              left: LabGapSize.s12,
                                              right: LabGapSize.s12,
                                              top: LabGapSize.s2,
                                              bottom: LabGapSize.s2,
                                            ),
                                            child: LabText.med14(
                                              _formatNumberForDisplay(
                                                historyExpression,
                                                maxDecimals: 8,
                                              ),
                                              color: LabTheme.of(
                                                context,
                                              ).colors.white66,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ] else ...[
                              const Spacer(),
                            ],

                            // 2. Current calculation line (LARGE FONT, WHITE)
                            LabContainer(
                              padding: const LabEdgeInsets.symmetric(
                                horizontal: LabGapSize.s12,
                              ),
                              child: Row(
                                children: [
                                  LabCrossButton.s24(
                                    onTap: clearExpression,
                                    isLight: false,
                                  ),
                                  const LabGap.s8(),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      reverse: true,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          LabText.h1(
                                            result.value.isNotEmpty
                                                ? _formatNumberForDisplay(
                                                    result.value,
                                                    maxDecimals: 8,
                                                  )
                                                : expression.value.isEmpty
                                                    ? '0'
                                                    : _formatNumberForDisplay(
                                                        expression.value,
                                                        maxDecimals: 8,
                                                      ),
                                            color: LabTheme.of(
                                              context,
                                            ).colors.white,
                                            textOverflow: TextOverflow.ellipsis,
                                          ),
                                          if (result.value.isEmpty) ...[
                                            const LabGap.s4(),
                                            _buildCursor(
                                              LabTheme.of(context),
                                              showCursor.value,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 3. Recent results (left-aligned row)
                            LabContainer(
                              padding: const LabEdgeInsets.all(LabGapSize.s12),
                              alignment: Alignment.centerLeft,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (final recentResult
                                        in recentResults.value)
                                      LabContainer(
                                        margin: const LabEdgeInsets.only(
                                          right: LabGapSize.s8,
                                        ),
                                        child: LabSmallButton(
                                          onTap: () =>
                                              useRecentResult(recentResult),
                                          color: LabTheme.of(
                                            context,
                                          ).colors.white8,
                                          children: [
                                            LabText.med12(
                                              _formatNumberForDisplay(
                                                recentResult.toString(),
                                                maxDecimals: 4,
                                              ),
                                              color: LabTheme.of(
                                                context,
                                              ).colors.white66,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const LabDivider(),
                  // Recent results

                  // Math functions row
                  LabContainer(
                    padding: const LabEdgeInsets.all(LabGapSize.s12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          _buildMathFunctionButton(
                            context,
                            'π',
                            () => addToExpression('π'),
                          ),
                          const LabGap.s8(),
                          _buildMathFunctionButton(
                            context,
                            'φ',
                            () => addToExpression('φ'),
                          ),
                          const LabGap.s8(),
                          _buildMathFunctionButton(
                            context,
                            'e',
                            () => addToExpression('e'),
                          ),
                          const LabGap.s8(),
                          _buildMathFunctionButton(
                            context,
                            '√',
                            () => addToExpression('√('),
                          ),
                          const LabGap.s8(),
                          _buildMathFunctionButton(
                            context,
                            'x²',
                            () => addToExpression('²'),
                          ),
                          const LabGap.s8(),
                          _buildMathFunctionButton(
                            context,
                            'x³',
                            () => addToExpression('³'),
                          ),
                          const LabGap.s8(),
                          _buildMathFunctionButton(
                            context,
                            'x^y',
                            () => addToExpression('^'),
                          ),
                          const LabGap.s8(),
                          _buildMathFunctionButton(
                            context,
                            'sin',
                            () => addToExpression('sin('),
                          ),
                          const LabGap.s8(),
                          _buildMathFunctionButton(
                            context,
                            'cos',
                            () => addToExpression('cos('),
                          ),
                          const LabGap.s8(),
                          _buildMathFunctionButton(
                            context,
                            'tan',
                            () => addToExpression('tan('),
                          ),
                          const LabGap.s8(),
                          _buildMathFunctionButton(
                            context,
                            'log',
                            () => addToExpression('log('),
                          ),
                          const LabGap.s8(),
                          _buildMathFunctionButton(
                            context,
                            'ln',
                            () => addToExpression('ln('),
                          ),
                          const LabGap.s8(),
                          _buildMathFunctionButton(
                            context,
                            '!',
                            () => addToExpression('!'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const LabDivider(),
                  // Calculator keyboard
                  _buildCalculatorKeyboard(
                    context,
                    addToExpression,
                    clearExpression,
                    deleteLast,
                    calculate,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMathFunctionButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    final theme = LabTheme.of(context);

    return LabSmallButton(
      onTap: onTap,
      color: theme.colors.white8,
      children: [LabText.med14(label, color: theme.colors.white66)],
    );
  }

  Widget _buildCalculatorKeyboard(
    BuildContext context,
    Function(String) addToExpression,
    VoidCallback clearExpression,
    VoidCallback deleteLast,
    VoidCallback calculate,
  ) {
    final theme = LabTheme.of(context);

    return LabContainer(
      padding: const LabEdgeInsets.all(LabGapSize.s12),
      child: Column(
        children: [
          // Row 1: ⌫, ±, %, ÷
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildKey(
                        context,
                        '(',
                        () => addToExpression('('),
                        backgroundColor: theme.colors.white16,
                      ),
                    ),

                    const LabGap.s8(),
                    Expanded(
                      child: _buildKey(
                        context,
                        ')',
                        () => addToExpression(')'),
                        backgroundColor: theme.colors.white16,
                      ),
                    ),
                  ],
                ),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(
                  context,
                  '±',
                  () => addToExpression('±'),
                  backgroundColor: theme.colors.white16,
                ),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(
                  context,
                  '%',
                  () => addToExpression('%'),
                  backgroundColor: theme.colors.white16,
                ),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(
                  context,
                  '÷',
                  () => addToExpression('÷'),
                  gradient: theme.colors.blurple33, // Reversed gradient
                  useLargeText: true,
                ),
              ),
            ],
          ),
          const LabGap.s8(),

          // Row 2: 7, 8, 9, ×
          Row(
            children: [
              Expanded(
                child: _buildKey(context, '7', () => addToExpression('7')),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(context, '8', () => addToExpression('8')),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(context, '9', () => addToExpression('9')),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(
                  context,
                  '×',
                  () => addToExpression('×'),
                  gradient: theme.colors.blurple33, // Reversed gradient
                  useLargeText: true,
                ),
              ),
            ],
          ),
          const LabGap.s8(),

          // Row 3: 4, 5, 6, -
          Row(
            children: [
              Expanded(
                child: _buildKey(context, '4', () => addToExpression('4')),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(context, '5', () => addToExpression('5')),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(context, '6', () => addToExpression('6')),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(
                  context,
                  '-',
                  () => addToExpression('-'),
                  gradient: theme.colors.blurple33, // Reversed gradient
                  useLargeText: true,
                ),
              ),
            ],
          ),
          const LabGap.s8(),

          // Row 4: 1, 2, 3, +
          Row(
            children: [
              Expanded(
                child: _buildKey(context, '1', () => addToExpression('1')),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(context, '2', () => addToExpression('2')),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(context, '3', () => addToExpression('3')),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(
                  context,
                  '+',
                  () => addToExpression('+'),
                  gradient: theme.colors.blurple33, // Reversed gradient
                  useLargeText: true,
                ),
              ),
            ],
          ),
          const LabGap.s8(),

          // Row 5: (, 0, ), =
          Row(
            children: [
              Expanded(
                child: _buildKey(context, '0', () => addToExpression('0')),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(
                  context,
                  '.',
                  () => addToExpression('.'),
                  useLargeText: true,
                ),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(
                  context,
                  '⌫',
                  deleteLast,
                  icon: theme.icons.characters.backspace,
                ),
              ),
              const LabGap.s8(),
              Expanded(
                child: _buildKey(
                  context,
                  '=',
                  calculate,
                  gradient: theme.colors.blurple, // Reversed gradient
                  icon: theme.icons.characters.check,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(
    BuildContext context,
    String value,
    VoidCallback onTap, {
    String? icon,
    Gradient? gradient,
    Color? backgroundColor,
    bool useLargeText = false,
  }) {
    final theme = LabTheme.of(context);

    return TapBuilder(
      onTap: onTap,
      builder: (context, state, hasFocus) {
        return LabContainer(
          height: theme.sizes.s48,
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                (gradient == null ? theme.colors.gray33 : null),
            gradient: gradient,
            borderRadius: theme.radius.asBorderRadius().rad16,
          ),
          child: Center(
            child: icon != null
                ? LabIcon(
                    icon,
                    size: value == '⌫' ? LabIconSize.s20 : LabIconSize.s14,
                    outlineColor: value == '⌫'
                        ? theme.colors.white
                        : theme.colors.whiteEnforced,
                    outlineThickness: value == '⌫'
                        ? LabLineThicknessData.normal().medium
                        : LabLineThicknessData.normal().thick,
                  )
                : useLargeText
                ? LabText.h2(value, color: theme.colors.white)
                : LabText.med16(value, color: theme.colors.white),
          ),
        );
      },
    );
  }

  Widget _buildCursor(LabThemeData theme, bool visible) {
    return Opacity(
      opacity: visible ? 1.0 : 0.0,
      child: LabContainer(
        width: theme.sizes.s2,
        height: theme.sizes.s24,
        decoration: BoxDecoration(color: theme.colors.white),
      ),
    );
  }

  String _formatNumber(double number) {
    if (number == number.toInt().toDouble()) {
      return number.toInt().toString();
    }

    // Round to 10 decimal places and remove trailing zeros
    String formatted = number.toStringAsFixed(10);
    formatted = formatted.replaceAll(RegExp(r'0+$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');

    return formatted;
  }

  String _formatNumberForDisplay(
    String numberString, {
    required int maxDecimals,
  }) {
    try {
      final number = double.parse(numberString);
      if (number == number.toInt().toDouble()) {
        return number.toInt().toString();
      }

      // Round to specified decimal places and remove trailing zeros
      String formatted = number.toStringAsFixed(maxDecimals);
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');

      return formatted;
    } catch (e) {
      return numberString; // Return original if parsing fails
    }
  }
}
