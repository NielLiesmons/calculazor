import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zaplab_design/zaplab_design.dart';
import 'package:tap_builder/tap_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:math' as math;

class GeometryCalculatorTab extends HookConsumerWidget {
  const GeometryCalculatorTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = LabTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TapBuilder(
            onTap: () => LabModal.show(
              context,
              children: const [_RightTriangleEditor()],
            ),
            builder: (context, state, hasFocus) {
              return LabContainer(
                padding: const LabEdgeInsets.symmetric(
                  horizontal: LabGapSize.s16,
                  vertical: LabGapSize.s12,
                ),
                decoration: BoxDecoration(
                  color: theme.colors.white8,
                  borderRadius: theme.radius.asBorderRadius().rad12,
                  border: Border.all(
                    color: theme.colors.white33,
                    width: LabLineThicknessData.normal().thin,
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/right-triangle-icon.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                    const LabGap.s12(),
                    LabText.med16('Right Triangle', color: theme.colors.white),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RightTriangleEditor extends HookConsumerWidget {
  const _RightTriangleEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = LabTheme.of(context);
    final aController = useTextEditingController();
    final bController = useTextEditingController();
    final cController = useTextEditingController();
    final alphaController = useTextEditingController();
    final betaController = useTextEditingController();

    void solve() {
      double? a = _parse(aController.text);
      double? b = _parse(bController.text);
      double? c = _parse(cController.text);
      double? alpha = _parse(alphaController.text);
      double? beta = _parse(betaController.text);

      const deg = math.pi / 180;
      if (alpha != null && alpha > 180) alpha = null;
      if (beta != null && beta > 180) beta = null;

      bool changed = true;
      while (changed) {
        changed = false;
        if (a != null && b != null && c == null) {
          c = math.sqrt(a * a + b * b);
          cController.text = _fmt(c);
          changed = true;
        }
        if (a != null && c != null && b == null && c > a) {
          b = math.sqrt(c * c - a * a);
          bController.text = _fmt(b);
          changed = true;
        }
        if (b != null && c != null && a == null && c > b) {
          a = math.sqrt(c * c - b * b);
          aController.text = _fmt(a);
          changed = true;
        }
        if (alpha != null && beta == null) {
          beta = 90 - alpha;
          betaController.text = _fmt(beta);
          changed = true;
        }
        if (beta != null && alpha == null) {
          alpha = 90 - beta;
          alphaController.text = _fmt(alpha);
          changed = true;
        }
        if (a != null && c != null && alpha == null) {
          alpha = math.acos(a / c) * 180 / math.pi;
          alphaController.text = _fmt(alpha);
          changed = true;
        }
        if (b != null && c != null && alpha == null) {
          alpha = math.asin(b / c) * 180 / math.pi;
          alphaController.text = _fmt(alpha);
          changed = true;
        }
        if (a != null && c != null && b == null) {
          b = c * math.sin(math.acos(a / c));
          bController.text = _fmt(b);
          changed = true;
        }
        if (b != null && c != null && a == null) {
          a = c * math.cos(math.asin(b / c));
          aController.text = _fmt(a);
          changed = true;
        }
        if (a != null && alpha != null && c == null) {
          c = a / math.cos(alpha * deg);
          cController.text = _fmt(c);
          changed = true;
        }
        if (b != null && alpha != null && c == null) {
          c = b / math.sin(alpha * deg);
          cController.text = _fmt(c);
          changed = true;
        }
        if (a != null && alpha != null && b == null) {
          b = a * math.tan(alpha * deg);
          bController.text = _fmt(b);
          changed = true;
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabContainer(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            borderRadius: theme.radius.asBorderRadius().rad8,
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/right-triangle.png',
            fit: BoxFit.contain,
          ),
        ),
        const LabGap.s20(),
        _ParamField(label: 'a', controller: aController, theme: theme),
        const LabGap.s8(),
        _ParamField(label: 'b', controller: bController, theme: theme),
        const LabGap.s8(),
        _ParamField(label: 'c', controller: cController, theme: theme),
        const LabGap.s8(),
        _ParamField(label: 'α (°)', controller: alphaController, theme: theme),
        const LabGap.s8(),
        _ParamField(label: 'β (°)', controller: betaController, theme: theme),
        const LabGap.s20(),
        LabButton(text: 'Solve', onTap: solve),
      ],
    );
  }

  static double? _parse(String s) {
    if (s.trim().isEmpty) return null;
    return double.tryParse(s.trim().replaceAll(',', '.'));
  }

  static String _fmt(double v) {
    if (v == v.toInt().toDouble()) return v.toInt().toString();
    String s = v.toStringAsFixed(4);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }
}

class _ParamField extends StatelessWidget {
  const _ParamField({
    required this.label,
    required this.controller,
    required this.theme,
  });

  final String label;
  final TextEditingController controller;
  final LabThemeData theme;

  Future<void> _openInputModal(BuildContext context) async {
    await LabInputTextModal.show(
      context,
      controller: controller,
      placeholder: '0',
      title: label,
      singleLine: true,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onDone: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return TapBuilder(
      onTap: () => _openInputModal(context),
      builder: (context, state, hasFocus) {
        return LabContainer(
          padding: const LabEdgeInsets.symmetric(
            horizontal: LabGapSize.s12,
            vertical: LabGapSize.s10,
          ),
          decoration: BoxDecoration(
            color: theme.colors.black33,
            borderRadius: theme.radius.asBorderRadius().rad8,
            border: Border.all(
              color: theme.colors.white33,
              width: LabLineThicknessData.normal().thin,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 44,
                child: LabText.med14(label, color: theme.colors.white66),
              ),
              const LabGap.s8(),
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    final text = value.text;
                    return LabText.reg16(
                      text.isEmpty ? '—' : text,
                      color: text.isEmpty
                          ? theme.colors.white33
                          : theme.colors.white,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
