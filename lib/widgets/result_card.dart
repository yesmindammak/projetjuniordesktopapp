import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final bool? compliant;
  final String? norm;

  const ResultCard(this.label, this.value, {this.compliant, this.norm, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color tileColor;
    Icon? icon;

    if (compliant == null) {
      tileColor = Colors.white;
    } else if (compliant!) {
      tileColor = AppColors.successGreen.withOpacity(0.1);
      icon = const Icon(Icons.check, color: AppColors.successGreen);
    } else {
      tileColor = AppColors.errorRed.withOpacity(0.12);
      icon = const Icon(Icons.close, color: AppColors.errorRed);
    }

    return Card(
      color: tileColor,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: icon,
        title: Text(label),
        subtitle: norm != null ? Text('Norme : $norm') : null,
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}