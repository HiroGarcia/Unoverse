class Config {
  final Pontos pontos;

  Config({required this.pontos});

  factory Config.fromMap(Map<String, dynamic> map) {
    return Config(pontos: Pontos.fromMap(map['pontos'] ?? {}));
  }

  Map<String, dynamic> toMap() {
    return {'pontos': pontos.toMap()};
  }
}

class Pontos {
  final int primeiro;
  final int segundo;
  final int terceiro;

  Pontos({
    required this.primeiro,
    required this.segundo,
    required this.terceiro,
  });

  factory Pontos.fromMap(Map<String, dynamic> map) {
    return Pontos(
      primeiro: map['primeiro'] ?? 3,
      segundo: map['segundo'] ?? 2,
      terceiro: map['terceiro'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {'primeiro': primeiro, 'segundo': segundo, 'terceiro': terceiro};
  }
}
