class Analysis {
  final int? id;
  final String codeEchantillon;
  final String nomClient;
  final String codeClient;
  final String? quantiteHuile;
  final DateTime dateReception;
  final DateTime dateAnalyse;
  
  // Mesures
  final double aciditeLibre;
  final double masseK232;
  final double absorbance232;
  final double masseK270;
  final double absorbance270;
  final double absorbance274;
  final double absorbance266;
  
  // Résultats calculés
  final double k232Calcule;
  final double k270Calcule;
  final double k274Calcule;
  final double k266Calcule;
  final double deltaKCalcule;
  
  // Conformité
  final bool conforme;
  
  // Métadonnées
  final DateTime dateCreation;
  final String? cheminPdf;

  Analysis({
    this.id,
    required this.codeEchantillon,
    required this.nomClient,
    required this.codeClient,
    this.quantiteHuile,
    required this.dateReception,
    required this.dateAnalyse,
    required this.aciditeLibre,
    required this.masseK232,
    required this.absorbance232,
    required this.masseK270,
    required this.absorbance270,
    required this.absorbance274,
    required this.absorbance266,
    required this.k232Calcule,
    required this.k270Calcule,
    required this.k274Calcule,
    required this.k266Calcule,
    required this.deltaKCalcule,
    required this.conforme,
    required this.dateCreation,
    this.cheminPdf,
  });

  // Convertir en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code_echantillon': codeEchantillon,
      'nom_client': nomClient,
      'code_client': codeClient,
      'quantite_huile': quantiteHuile,
      'date_reception': dateReception.toIso8601String(),
      'date_analyse': dateAnalyse.toIso8601String(),
      'acidite_libre': aciditeLibre,
      'masse_k232': masseK232,
      'absorbance_232': absorbance232,
      'masse_k270': masseK270,
      'absorbance_270': absorbance270,
      'absorbance_274': absorbance274,
      'absorbance_266': absorbance266,
      'k232_calcule': k232Calcule,
      'k270_calcule': k270Calcule,
      'k274_calcule': k274Calcule,
      'k266_calcule': k266Calcule,
      'delta_k_calcule': deltaKCalcule,
      'conforme': conforme ? 1 : 0,
      'date_creation': dateCreation.toIso8601String(),
      'chemin_pdf': cheminPdf,
    };
  }

  // Créer depuis Map (SQLite)
  factory Analysis.fromMap(Map<String, dynamic> map) {
    return Analysis(
      id: map['id'] as int?,
      codeEchantillon: map['code_echantillon'] as String,
      nomClient: map['nom_client'] as String,
      codeClient: map['code_client'] as String,
      quantiteHuile: map['quantite_huile'] as String?,
      dateReception: DateTime.parse(map['date_reception'] as String),
      dateAnalyse: DateTime.parse(map['date_analyse'] as String),
      aciditeLibre: map['acidite_libre'] as double,
      masseK232: map['masse_k232'] as double,
      absorbance232: map['absorbance_232'] as double,
      masseK270: map['masse_k270'] as double,
      absorbance270: map['absorbance_270'] as double,
      absorbance274: map['absorbance_274'] as double,
      absorbance266: map['absorbance_266'] as double,
      k232Calcule: map['k232_calcule'] as double,
      k270Calcule: map['k270_calcule'] as double,
      k274Calcule: map['k274_calcule'] as double,
      k266Calcule: map['k266_calcule'] as double,
      deltaKCalcule: map['delta_k_calcule'] as double,
      conforme: (map['conforme'] as int) == 1,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      cheminPdf: map['chemin_pdf'] as String?,
    );
  }

  // Créer une copie avec modifications
  Analysis copyWith({
    int? id,
    String? codeEchantillon,
    String? nomClient,
    String? codeClient,
    String? quantiteHuile,
    DateTime? dateReception,
    DateTime? dateAnalyse,
    double? aciditeLibre,
    double? masseK232,
    double? absorbance232,
    double? masseK270,
    double? absorbance270,
    double? absorbance274,
    double? absorbance266,
    double? k232Calcule,
    double? k270Calcule,
    double? k274Calcule,
    double? k266Calcule,
    double? deltaKCalcule,
    bool? conforme,
    DateTime? dateCreation,
    String? cheminPdf,
  }) {
    return Analysis(
      id: id ?? this.id,
      codeEchantillon: codeEchantillon ?? this.codeEchantillon,
      nomClient: nomClient ?? this.nomClient,
      codeClient: codeClient ?? this.codeClient,
      quantiteHuile: quantiteHuile ?? this.quantiteHuile,
      dateReception: dateReception ?? this.dateReception,
      dateAnalyse: dateAnalyse ?? this.dateAnalyse,
      aciditeLibre: aciditeLibre ?? this.aciditeLibre,
      masseK232: masseK232 ?? this.masseK232,
      absorbance232: absorbance232 ?? this.absorbance232,
      masseK270: masseK270 ?? this.masseK270,
      absorbance270: absorbance270 ?? this.absorbance270,
      absorbance274: absorbance274 ?? this.absorbance274,
      absorbance266: absorbance266 ?? this.absorbance266,
      k232Calcule: k232Calcule ?? this.k232Calcule,
      k270Calcule: k270Calcule ?? this.k270Calcule,
      k274Calcule: k274Calcule ?? this.k274Calcule,
      k266Calcule: k266Calcule ?? this.k266Calcule,
      deltaKCalcule: deltaKCalcule ?? this.deltaKCalcule,
      conforme: conforme ?? this.conforme,
      dateCreation: dateCreation ?? this.dateCreation,
      cheminPdf: cheminPdf ?? this.cheminPdf,
    );
  }
}