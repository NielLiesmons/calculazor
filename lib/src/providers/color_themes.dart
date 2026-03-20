import 'package:zaplab_design/zaplab_design.dart';

/// Ocean theme colors for the Nielculator app
class ColorThemes {
  /// Get the Ocean theme color override
  static LabColorsOverride? getOverride(String themeName) {
    if (themeName == 'Ocean') {
      return _getOceanTheme();
    }
    return null; // Use default colors for other themes
  }

  /// Ocean theme - LabBase will handle light/dark mode automatically
  static LabColorsOverride _getOceanTheme() {
    return LabColorsOverride(
      // Primary colors - Ocean blue gradients
      blurple: LinearGradient(
        colors: [Color(0xFF00956B), Color(0xFF1F749C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      blurple66: LinearGradient(
        colors: [
          Color(0xFF00956B).withValues(alpha: 0.66),
          Color(0xFF1F749C).withValues(alpha: 0.66),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      blurple33: LinearGradient(
        colors: [
          Color(0xFF00956B).withValues(alpha: 0.33),
          Color(0xFF1F749C).withValues(alpha: 0.33),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      blurple16: LinearGradient(
        colors: [
          Color(0xFF00956B).withValues(alpha: 0.16),
          Color(0xFF1F749C).withValues(alpha: 0.16),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      blurpleColor: Color(0xFF128D8C),
      blurpleColor66: Color(0xFF128D8C).withValues(alpha: 0.66),
      blurpleColor33: Color(0xFF128D8C).withValues(alpha: 0.33),
      blurpleLightColor: Color(0xFF128D8C),
      blurpleLightColor66: Color(0xFF128D8C).withValues(alpha: 0.66),

      // Gold colors - Ocean sunset orange
      gold: LinearGradient(
        colors: [Color(0xFFE08B2A), Color(0xFFCF585C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      gold66: LinearGradient(
        colors: [
          Color(0xFFE08B2A).withValues(alpha: 0.66),
          Color(0xFFCF585C).withValues(alpha: 0.66),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      gold33: LinearGradient(
        colors: [
          Color(0xFFE08B2A).withValues(alpha: 0.33),
          Color(0xFFCF585C).withValues(alpha: 0.33),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      gold16: LinearGradient(
        colors: [
          Color(0xFFE08B2A).withValues(alpha: 0.16),
          Color(0xFFCF585C).withValues(alpha: 0.16),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      goldColor: Color(0xFFD87143),
      goldColor66: Color(0xFFD87143).withValues(alpha: 0.66),

      // Rouge colors - Ocean coral
      rouge: LinearGradient(
        colors: [Color(0xFFCF58B6), Color(0xFFDB465F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rouge66: LinearGradient(
        colors: [
          Color(0xFFCF58B6).withValues(alpha: 0.66),
          Color(0xFFDB465F).withValues(alpha: 0.66),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rouge33: LinearGradient(
        colors: [
          Color(0xFFCF58B6).withValues(alpha: 0.33),
          Color(0xFFDB465F).withValues(alpha: 0.33),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rouge16: LinearGradient(
        colors: [
          Color(0xFFCF58B6).withValues(alpha: 0.16),
          Color(0xFFDB465F).withValues(alpha: 0.16),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
