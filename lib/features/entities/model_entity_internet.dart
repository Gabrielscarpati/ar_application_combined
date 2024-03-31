class ModelEntityInternet {
  final String imagePath;
  final String modelPath;
  final String id;

  ModelEntityInternet({
    required this.imagePath,
    required this.modelPath,
    required this.id,
  });

  factory ModelEntityInternet.fromJson(Map<String, dynamic> json) {
    return ModelEntityInternet(
      imagePath: json['imagePath'],
      modelPath: json['modelPath'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'modelPath': modelPath,
      'id': id,
    };
  }

  ModelEntityInternet copyWith({
    String? imagePath,
    String? modelPath,
    String? id,
  }) {
    return ModelEntityInternet(
      imagePath: imagePath ?? this.imagePath,
      modelPath: modelPath ?? this.modelPath,
      id: id ?? this.id,
    );
  }
}
