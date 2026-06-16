import 'constants.dart';

class Calculations {
  /// Calcul K232 = Absorbance_232 / (Masse_K232 × 4)
  static double calculateK232(double absorbance232, double masse232) {
    if (masse232 == 0) return 0;
    return absorbance232 / (masse232 * 4);
  }

  /// Calcul K270 = Absorbance_270 / (Masse_K270 × 4)
  static double calculateK270(double absorbance270, double masse270) {
    if (masse270 == 0) return 0;
    return absorbance270 / (masse270 * 4);
  }

  /// Calcul K274 = Absorbance_274 / (Masse_K270 × 4)
  static double calculateK274(double absorbance274, double masse270) {
    if (masse270 == 0) return 0;
    return absorbance274 / (masse270 * 4);
  }

  /// Calcul K266 = Absorbance_266 / (Masse_K270 × 4)
  static double calculateK266(double absorbance266, double masse270) {
    if (masse270 == 0) return 0;
    return absorbance266 / (masse270 * 4);
  }

  /// Calcul Delta K = K270 - ((K274 + K266) / 2)
  static double calculateDeltaK(double k270, double k274, double k266) {
    return k270 - ((k274 + k266) / 2);
  }

  /// Vérifier si un paramètre est conforme
  static bool isParameterCompliant(String parameter, double value) {
    switch (parameter) {
      case 'acidite':
        return value <= AppConstants.maxAcidity;
      case 'k232':
        return value <= AppConstants.maxK232;
      case 'k270':
        return value <= AppConstants.maxK270;
      case 'deltaK':
        return value <= AppConstants.maxDeltaK;
      default:
        return false;
    }
  }

  /// Vérifier si l'analyse complète est conforme
  static bool isAnalysisCompliant({
    required double acidite,
    required double k232,
    required double k270,
    required double deltaK,
  }) {
    return acidite <= AppConstants.maxAcidity &&
           k232 <= AppConstants.maxK232 &&
           k270 <= AppConstants.maxK270 &&
           deltaK <= AppConstants.maxDeltaK;
  }

  /// Obtenir la liste des paramètres non conformes
  static List<String> getNonCompliantParameters({
    required double acidite,
    required double k232,
    required double k270,
    required double deltaK,
  }) {
    List<String> nonCompliant = [];
    
    if (acidite > AppConstants.maxAcidity) {
      nonCompliant.add('Acidité libre');
    }
    if (k232 > AppConstants.maxK232) {
      nonCompliant.add('K232');
    }
    if (k270 > AppConstants.maxK270) {
      nonCompliant.add('K270');
    }
    if (deltaK > AppConstants.maxDeltaK) {
      nonCompliant.add('Delta K');
    }
    
    return nonCompliant;
  }

  /// Formatter un résultat avec le nombre de décimales approprié
  static String formatResult(double value) {
    return value.toStringAsFixed(2);
  }
}