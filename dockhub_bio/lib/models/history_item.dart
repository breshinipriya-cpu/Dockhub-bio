class HistoryItem {
  final String protein;
  final String pdbId;
  final String ligand;
  final String dockingScore;
  final DateTime dateTime;
  final String? resultJson;

  const HistoryItem({
    required this.protein,
    required this.pdbId,
    required this.ligand,
    required this.dockingScore,
    required this.dateTime,
    this.resultJson,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      protein: json['protein'] ?? '',
      pdbId: json['pdbId'] ?? '',
      ligand: json['ligand'] ?? '',
      dockingScore: json['dockingScore'] ?? 'N/A',
      dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now(),
      resultJson: json['resultJson'],
    );
  }

  Map<String, dynamic> toJson() => {
        'protein': protein,
        'pdbId': pdbId,
        'ligand': ligand,
        'dockingScore': dockingScore,
        'dateTime': dateTime.toIso8601String(),
        'resultJson': resultJson,
      };
}

class SavedResult {
  final String protein;
  final String pdbId;
  final String ligand;
  final String dockingScore;
  final DateTime dateTime;
  final String resultJson;

  const SavedResult({
    required this.protein,
    required this.pdbId,
    required this.ligand,
    required this.dockingScore,
    required this.dateTime,
    required this.resultJson,
  });

  factory SavedResult.fromJson(Map<String, dynamic> json) {
    return SavedResult(
      protein: json['protein'] ?? '',
      pdbId: json['pdbId'] ?? '',
      ligand: json['ligand'] ?? '',
      dockingScore: json['dockingScore'] ?? 'N/A',
      dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now(),
      resultJson: json['resultJson'] ?? '{}',
    );
  }

  Map<String, dynamic> toJson() => {
        'protein': protein,
        'pdbId': pdbId,
        'ligand': ligand,
        'dockingScore': dockingScore,
        'dateTime': dateTime.toIso8601String(),
        'resultJson': resultJson,
      };
}
